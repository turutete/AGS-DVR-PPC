/*
 * FreeModbus Libary: Win32 Port
 * Copyright (C) 2006 Christian Walter <wolti@sil.at>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * File: $Id: porttcp.c,v 1.1 2007/09/12 10:15:56 wolti Exp $
 */

/*
 * Design Notes:
 *
 * The xMBPortTCPInit function allocates a socket and binds the socket to
 * all available interfaces ( bind with INADDR_ANY ). In addition it
 * creates an array of event objects which is used to check the state of
 * the clients. On event object is used to handle new connections or
 * closed ones. The other objects are used on a per client basis for
 * processing.
 */

 /**********************************************************
 *	Linux TCP support.
 *	Based on Walter's project.
 *	Modified by Steven Guo <gotop167@163.com>
 ***********************************************************/

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <netinet/in.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>

#include "port.h"

//#include <netinet/tcp.h>	/* jur: SOL_TCP */
//#include <signal.h>		/* jur: SIGALRM signal... */

/* ----------------------- Modbus includes ----------------------------------*/
#include "mb.h"
#include "mbport.h"



/* ----------------------- MBAP Header --------------------------------------*/
#define MB_TCP_UID          6
#define MB_TCP_LEN          4
#define MB_TCP_FUNC         7

/* ----------------------- Defines  -----------------------------------------*/
#define MB_TCP_DEFAULT_PORT 502 /* TCP listening port. */
#define MB_TCP_POOL_TIMEOUT 50  /* pool timeout for event waiting. */
#define MB_TCP_READ_TIMEOUT 1000        /* Maximum timeout to wait for packets. */
#define MB_TCP_READ_CYCLE   100 /* Time between checking for new data. */

#define MB_TCP_DEBUG        1   /* Set to 1 for additional debug output. */

#define MB_TCP_BUF_SIZE     ( 256 + 7 ) /* Must hold a complete Modbus TCP frame. */

#define EV_CONNECTION       0
#define EV_CLIENT           1
#define EV_NEVENTS          EV_CLIENT + 1

/* ----------------------- Static variables ---------------------------------*/
SOCKET          xListenSocket;
SOCKET          xClientSocket = INVALID_SOCKET;
static fd_set   allset;

static UCHAR    aucTCPBuf[MB_TCP_BUF_SIZE];
static USHORT   usTCPBufPos;
static USHORT   usTCPFrameBytesLeft;

char* ips_validas[NUM_IPS_VALIDAS]={"",""}; //ips entrantes validas para modbus.

/* ----------------------- External functions -------------------------------*/
CHAR           *WsaError2String( int dwError );

/* ----------------------- Static functions ---------------------------------*/
BOOL            prvMBTCPPortAddressToString( SOCKET xSocket, CHAR * szAddr, USHORT usBufSize );
CHAR           *prvMBTCPPortFrameToString( UCHAR * pucFrame, USHORT usFrameLen );
static BOOL     prvbMBPortAcceptClient( void );
static void     prvvMBPortReleaseClient( void );

// jur:
extern int com_reset_timeout;
extern int debuglevel;
//#define printd(level, ...) (level<=debuglevel) ? printf(__VA_ARGS__) : 0
#define printd(level, ...) (level<=debuglevel) ? printf("%d: ",level) / printf(__VA_ARGS__) : 0

/* ----------------------- Begin implementation -----------------------------*/

/*(jur) alarm KO (imagino por el uso del main_loop de glib...)
void alarm_handler(int n) {
   printf("alarm_handler\n"); fflush(stdout);
}
*/

BOOL
xMBTCPPortInit( USHORT usTCPPort )
{
    USHORT          usPort;
    struct sockaddr_in serveraddr;
    int yes=1;  //jur

    if( usTCPPort == 0 )
    {
        usPort = MB_TCP_DEFAULT_PORT;
    }
    else
    {
        usPort = ( USHORT ) usTCPPort;
    }
    memset( &serveraddr, 0, sizeof( serveraddr ) );
    serveraddr.sin_family = AF_INET;
    serveraddr.sin_addr.s_addr = htonl( INADDR_ANY );
    serveraddr.sin_port = htons( usPort );
    if( ( xListenSocket = socket( AF_INET, SOCK_STREAM, IPPROTO_TCP ) ) == -1 )
    {
	fprintf( stderr, "Create socket failed.\r\n" );
        return FALSE;
    }
    //else if( bind( xListenSocket, ( struct sockaddr * )&serveraddr, sizeof( serveraddr ) ) == -1 )
    else {
       //(jur) intento evitar 'bind socket failed' (uso de SO_REUSEADDR)
       if (setsockopt(xListenSocket, SOL_SOCKET, SO_REUSEADDR , &yes, sizeof(yes)) == -1) {
          fprintf( stderr, "setsockopt SO_REUSEADDR failed.\r\n" );
       }
       if( bind( xListenSocket, ( struct sockaddr * )&serveraddr, sizeof( serveraddr ) ) == -1 )
    {
        fprintf( stderr, "Bind socket failed.\r\n" );
        return FALSE;
    }
    else if( listen( xListenSocket, 5 ) == -1 )
    {
        fprintf( stderr, "Listen socket failed.\r\n" );
        return FALSE;
    }
    }  //else
    FD_ZERO( &allset );
    FD_SET( xListenSocket, &allset );

    //signal(SIGALRM, alarm_handler);  //(jur) KO

    return TRUE;
}

void
vMBTCPPortClose(  )
{
    // Close all client sockets.
    if( xClientSocket != SOCKET_ERROR )
    {
        prvvMBPortReleaseClient(  );
    }
    // Close the listener socket.
    if( xListenSocket != SOCKET_ERROR )
    {
        close( xListenSocket );
    }
}

void
vMBTCPPortDisable( void )
{
    /* Close all client sockets. */
    if( xClientSocket != SOCKET_ERROR )
    {
        prvvMBPortReleaseClient(  );
    }
}

/*! \ingroup port_win32tcp
 *
 * \brief Pool the listening socket and currently connected Modbus TCP clients
 *   for new events.
 * \internal
 *
 * This function checks if new clients want to connect or if already connected
 * clients are sending requests. If a new client is connected and there are
 * still client slots left (The current implementation supports only one)
 * then the connection is accepted and an event object for the new client
 * socket is activated (See prvbMBPortAcceptClient() ).
 * Events for already existing clients in \c FD_READ and \c FD_CLOSE. In case of
 * an \c FD_CLOSE the client connection is released (See prvvMBPortReleaseClient() ).
 * In case of an \c FD_READ command the existing data is read from the client
 * and if a complete frame has been received the Modbus Stack is notified.
 *
 * \return FALSE in case of an internal I/O error. For example if the internal
 *   event objects are in an invalid state. Note that this does not include any
 *   client errors. In all other cases returns TRUE.
 */
BOOL
xMBPortTCPPool( void )
{
    int             n;
    fd_set          fread;
    struct timeval  tval;

    //(jur) esto es timeout para el select del while(1) (5us); y el select de aceptar cliente es bloqueante
    tval.tv_sec = 0;
    tval.tv_usec = 5000;
    int             ret;
    USHORT          usLength;

    //jur:
    int optval;
    socklen_t optlen = sizeof(optval);
    int count=0;
    static int sec_count=0;

    //printd(2, "xMBPortTCPPool\n"); fflush(stdout);
    printf("xMBPortTCPPool\n" ); fflush(stdout);  //JC



    //Añado esta variable porque en el caso de que prvbMBPortAcceptClient retorne false porque la IP entrante no es valida, no debemos
    //entrar al while porque de lo contrario la aplicacion se bloquea.JC.
    BOOL estamos_conectados = TRUE;

    if( xClientSocket == INVALID_SOCKET )
    {
        /* Accept to client */
        printd(1, "Accept to client.\n");  fflush(stdout); //jur
        if( ( n = select( xListenSocket + 1, &allset, NULL, NULL, NULL ) ) < 0 )
        {
            if( errno == EINTR )
            {
                ;
            }
            else
            {
                ;
            }
        }
        if( FD_ISSET( xListenSocket, &allset ) )
        {
        	//( void )prvbMBPortAcceptClient(  );JC
        	estamos_conectados = prvbMBPortAcceptClient(  );
        }

    }
    printf("Entro en el while.estamos_conectados = %d\n", estamos_conectados ); fflush(stdout);  //JC
    //while( TRUE )JC
    while(TRUE && estamos_conectados)
    {
    	//(jur) nuestra implementacion de "KEEPALIVE". Cerrar socket ante ese timeout de inactividad de tramas
    	count=count+1;
    	if(count>200000) {  //aprox. 1seg con ese delay para el select
    			count=0;
    			sec_count=sec_count+1;
    			if(sec_count>=com_reset_timeout) {
                    sec_count=0;
                    close( xClientSocket );
                    xClientSocket = INVALID_SOCKET;
                    //printd(2, "return por inactividad!\n"); fflush(stdout);
                    printf("return del while por inactividad.\n" ); fflush(stdout);  //JC
                    return TRUE;
    			}
    			printd(2, "while true (%d/%d)\n", sec_count, com_reset_timeout); fflush(stdout);  //jur
       }

       /*(jur) test
       getsockopt(xClientSocket, SOL_SOCKET, SO_ERROR, &optval, &optlen);
       printf("SO_ERROR is %s\n", optval);
       printf("errno is %d\n", errno);
       */

        FD_ZERO( &fread );
        FD_SET( xClientSocket, &fread );
        if( ( ( ret = select( xClientSocket + 1, &fread, NULL, NULL, &tval ) ) == SOCKET_ERROR )
            || !ret )
        {
            //fprintf( stderr, "continue.\n" ); fflush(stdout);  //jur. ret==0 si time out.
            continue;
        }
        if( ret > 0 )
        {
            //fprintf( stderr, "ret>0.\n" ); fflush(stdout);  //jur
            if( FD_ISSET( xClientSocket, &fread ) )
            {
                if( ( ( ret =recv( xClientSocket, &aucTCPBuf[usTCPBufPos], usTCPFrameBytesLeft,
                              0 ) ) == SOCKET_ERROR ) || ( !ret ) )
                {
                    //fprintf( stderr, "recv ERROR.\n" );
                    fprintf( stderr, "recv ERROR: %d\n", ret ); fflush(stdout);
                    //jur. Tb entra cuando time out del KEEPALIVE! OK! Recordar ajustar en /proc/sys/net/ipv4/keepalive... (en arranquesistema p.ej.) o aqui directamente...
		    // xq la idea es q el select marcado para lectura cuando timeout de keepalive da lectura y luego la lectura recv se marca como error, osea q parece ok como se recoge el error de keepalive...
		    // PERO observo en pruebas q no entra siempre!!!!!! ... ??? Igual hay q recoger algun otro estado ademas de SOCKET_ERROR? (SOCKET_ERROR=-1 en port.h)
		    // recv: These calls return the number of bytes received, or -1 if an error occurred. The return value will be 0 when the peer has performed an orderly shutdown.
		    // Luego esta bien asi! ... ?
                    // Vease TCP Keepalive Howto
                    // Al final uso de timeout de inactividad ;-)

                    sec_count=0;
                    close( xClientSocket );
                    xClientSocket = INVALID_SOCKET;
                    printf("return del while y cierre de socket.\n" ); fflush(stdout);  //JC
                    return TRUE;
                }
                //alarm(15);  //(jur) Refresco del timeout de recepcion de tramas. KO
                sec_count=0;

                usTCPBufPos += ret;
                usTCPFrameBytesLeft -= ret;
                if( usTCPBufPos >= MB_TCP_FUNC )
                {
                    /* Length is a byte count of Modbus PDU (function code + data) and the
                     * unit identifier. */
                    usLength = aucTCPBuf[MB_TCP_LEN] << 8U;
                    usLength |= aucTCPBuf[MB_TCP_LEN + 1];

                    /* Is the frame already complete. */
                    if( usTCPBufPos < ( MB_TCP_UID + usLength ) )
                    {
                        usTCPFrameBytesLeft = usLength + MB_TCP_UID - usTCPBufPos;
                    }
                    /* The frame is complete. */
                    else if( usTCPBufPos == ( MB_TCP_UID + usLength ) )
                    {
                        printd(2, "The frame is complete.\n" ); fflush(stdout); //jur
                        ( void )xMBPortEventPost( EV_FRAME_RECEIVED );
                        printf("return del while por frame completo.\n" ); fflush(stdout);  //JC
                        return TRUE;
                    }
                    /* This can not happend because we always calculate the number of bytes
                     * to receive. */
                    else
                    {
                        printd(2, "before assert!\n"); fflush(stdout);
                        printf("assert.\n" ); fflush(stdout);  //JC
                        assert( usTCPBufPos <= ( MB_TCP_UID + usLength ) );
                    }
                }
            }
			else
			{
				printf("not FD_ISSET.\n" ); fflush(stdout);  //JC
				fprintf( stderr, "not FD_ISSET.\n" );  //jur
			}
    }
	else
	{
		printf("not ret>0.\n" ); fflush(stdout);  //JC
		fprintf( stderr, "not ret>0.\n" );  //jur. Aqui no llegara en realidad sino al 'continue' (o con <1)
	}
    }
    printf("Ya fuera del while.\n" ); fflush(stdout);  //JC
    printd(2, "after while(true)\n"); fflush(stdout);
    return TRUE;
}

/*!
 * \ingroup port_win32tcp
 * \brief Receives parts of a Modbus TCP frame and if complete notifies
 *    the protocol stack.
 * \internal
 *
 * This function reads a complete Modbus TCP frame from the protocol stack.
 * It starts by reading the header with an initial request size for
 * usTCPFrameBytesLeft = MB_TCP_FUNC. If the header is complete the
 * number of bytes left can be calculated from it (See Length in MBAP header).
 * Further read calls are issued until the frame is complete.
 *
 * \return \c TRUE if part of a Modbus TCP frame could be processed. In case
 *   of a communication error the function returns \c FALSE.
 */

BOOL
xMBTCPPortGetRequest( UCHAR ** ppucMBTCPFrame, USHORT * usTCPLength )
{
    *ppucMBTCPFrame = &aucTCPBuf[0];
    *usTCPLength = usTCPBufPos;

    /* Reset the buffer. */
    usTCPBufPos = 0;
    usTCPFrameBytesLeft = MB_TCP_FUNC;
    return TRUE;
}

BOOL
xMBTCPPortSendResponse( const UCHAR * pucMBTCPFrame, USHORT usTCPLength )
{
    BOOL            bFrameSent = FALSE;
    BOOL            bAbort = FALSE;
    int             res;
    int             iBytesSent = 0;
    int             iTimeOut = MB_TCP_READ_TIMEOUT;

    do
    {
        res = send( xClientSocket, &pucMBTCPFrame[iBytesSent], usTCPLength - iBytesSent, 0 );
        switch ( res )
        {
        case -1:
            if( iTimeOut > 0 )
            {
                iTimeOut -= MB_TCP_READ_CYCLE;
                usleep( MB_TCP_READ_CYCLE );
            }
            else
            {
                bAbort = TRUE;
            }
            break;
        case 0:
            prvvMBPortReleaseClient(  );
            bAbort = TRUE;
            break;
        default:
            iBytesSent += res;
            break;
        }
    }
    while( ( iBytesSent != usTCPLength ) && !bAbort );

    bFrameSent = iBytesSent == usTCPLength ? TRUE : FALSE;

    return bFrameSent;
}

void
prvvMBPortReleaseClient(  )
{
    fprintf( stderr, "prvvMBPortReleaseClient.\n" );  //jur
    ( void )recv( xClientSocket, &aucTCPBuf[0], MB_TCP_BUF_SIZE, 0 );

    ( void )close( xClientSocket );
    xClientSocket = INVALID_SOCKET;
}

BOOL
prvbMBPortAcceptClient(  )
{
    SOCKET          xNewSocket;
    BOOL            bOkay;
    //jur:
    int optval;
    socklen_t optlen = sizeof(optval);
    int yes=1;

    struct sockaddr_in address;
    int addrlen = sizeof(address);


    /* Check if we can handle a new connection. */
    printf("prvbMBPortAcceptClient.\n" ); fflush(stdout);  //jur

    if( xClientSocket != INVALID_SOCKET )
    {
        fprintf( stderr, "can't accept new client. all connections in use.\n" );
        bOkay = FALSE;
    }
    //JC comentado>>>>>   else if( ( xNewSocket = accept( xListenSocket, NULL, NULL ) ) == INVALID_SOCKET )
    else
    {
    	xNewSocket = accept( xListenSocket, 	( struct sockaddr * )&address, (socklen_t*)&addrlen);

    	if( xNewSocket < 0)
    	{
    		if((errno == ENETDOWN || errno == EPROTO || errno == ENOPROTOOPT || errno == EHOSTDOWN ||errno == ENONET || errno == EHOSTUNREACH || errno == EOPNOTSUPP || errno == ENETUNREACH))
    		{
    			printf("prvbMBPortAcceptClient. Fallo en el accept no grave.accept=%d, errno = %d.\n",xNewSocket,errno ); fflush(stdout);  //JC
    		}
    		else
    		{
    			printf("prvbMBPortAcceptClient. Fallo en el accept grave.accept=%d, errno = %d.\n",xNewSocket,errno ); fflush(stdout);  //JC
    		}
    		bOkay = FALSE;
    	}
    	else
    	{
			//Si no hay IPs entrantes configuradas, no hay que chequear nada.
			BOOL check_ips 	= FALSE;
			BOOL ip_valida 	= FALSE;

			if(ips_validas != NULL)
			{
				int i=0;
				for(i=0; i < NUM_IPS_VALIDAS; i++)
				{
					if(strcmp(ips_validas[i], "") != 0)
					{
						check_ips = TRUE;
						break;
					}

				}
			}

			if (check_ips)
			{
				//Se comprueba la validez de las IPs entrantes
				char ip_string[16]={0};
				inet_ntop(AF_INET, &(address.sin_addr),ip_string,sizeof(ip_string));
				printf("prvbMBPortAcceptClient. ip_valida de entrada = %s \n",ip_string ); fflush(stdout);  //JC
				int i=0;
				for(i=0; i < NUM_IPS_VALIDAS; i++)
				{
					if(strcmp(ips_validas[i], ip_string) == 0)
					{
						//al menos hay una ip configurada para ser chequeada.
						printf("match de ip %s.\n",ip_string ); fflush(stdout);  //jur
						ip_valida = TRUE;
						break;
					}
				}
			}
			else
			{
				//si no hay que chequear la ip es porque no hay ninguna ip configurada y cualquiera se admite.
				ip_valida = TRUE;
			}

			if(ip_valida)
			{
				printf("prvbMBPortAcceptClient. ip_valida, conectado\n" ); fflush(stdout);  //JC

				printd(2, "xClientSocket = xNewSocket.\n" ); fflush(stdout);  //jur
				xClientSocket = xNewSocket;
				usTCPBufPos = 0;
				usTCPFrameBytesLeft = MB_TCP_FUNC;
				bOkay = TRUE;
			}
			else
			{

				printf("prvbMBPortAcceptClient. (???)Rechazo de la conexion. IP no valida\n" ); fflush(stdout);  //JC
				close( xClientSocket );
				xClientSocket = INVALID_SOCKET;
				bOkay = FALSE;

			}

       // -->>jur
       /* Intento de uso de TCP keepalive para deteccion conexion perdida
       // El tema es que no siempre se detectaba la inactividad via latido TCP
       // (quiza como se leia en articulo, por culpa de los switches/routers de la red...)
       getsockopt(xClientSocket, SOL_SOCKET, SO_KEEPALIVE, &optval, &optlen);
       printf("SO_KEEPALIVE is %s\n", (optval ? "ON" : "OFF")); fflush(stdout);

       if (setsockopt(xClientSocket, SOL_SOCKET, SO_KEEPALIVE, &yes, sizeof(yes)) == -1) {
          fprintf( stderr, "setsockopt SO_KEEPALIVE failed.\r\n" );
       }

       getsockopt(xClientSocket, SOL_SOCKET, SO_KEEPALIVE, &optval, &optlen);
       printf("SO_KEEPALIVE is %s\n", (optval ? "ON" : "OFF")); fflush(stdout);

       // time:
       yes=10;
       if (setsockopt(xClientSocket, SOL_TCP, TCP_KEEPIDLE, &yes, sizeof(yes)) == -1) {
          fprintf( stderr, "setsockopt TCP_KEEPCNT failed.\r\n" );
       }
       // intvl:
       yes=5;
       if (setsockopt(xClientSocket, SOL_TCP, TCP_KEEPINTVL, &yes, sizeof(yes)) == -1) {
          fprintf( stderr, "setsockopt TCP_KEEPCNT failed.\r\n" );
       }
       // probes:
       yes=2;
       if (setsockopt(xClientSocket, SOL_TCP, TCP_KEEPCNT, &yes, sizeof(yes)) == -1) {
          fprintf( stderr, "setsockopt TCP_KEEPCNT failed.\r\n" );
       }
       */

       /* Al final mejor uso de timer de inactividad para resetear conexion */
       //alarm(5);  // seconds. KO
       // <<--jur
    	}
    }

    if (bOkay)
    	printf("prvbMBPortAcceptClient. Return TRUE\n" );
	else
		printf("prvbMBPortAcceptClient. Return FALSE\n" );

    fflush(stdout);

    return bOkay;
}

void xMBTCPValidIps(char** ips, int num_of_ips)
{
	if (ips != NULL)
	{
		int i=0;
		for(i=0; i<NUM_IPS_VALIDAS; i++)
		{
			if (ips_validas[i] != NULL)
			{
				ips_validas[i] = ips[i];
				printf("ip_validas[%d] = %s\n",i,ips_validas[i] ); fflush(stdout);

			}
		}
	}
}
