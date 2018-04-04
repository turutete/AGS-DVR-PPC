#ifndef RECTIFICADOR_H
	#define RECTIFICADOR_H
	/*estados Magnetek del rectificador*/
	enum STATE {START_DELAY_RUN=0,START_DELAY_END,POWER_UP,POWER_RUN,PROTECTION};

	typedef struct _tipo_EstadoRectificador tipo_EstadoRectificador;
	
	struct _tipo_EstadoRectificador {
	  gchar version[5];
	  gint mode16;
	  guint tamb;
	  guint trad;
	  gint vsal;
	  gint isal;
	  guint minutes;
	  
	  char limit;
	  char mode24;
	  char ps_state;
	  char fault;
	  char mag_sal;
	  
	  gint error_com;	/*error de comunicaciones*/
	  gint contador;	/*contador de error de comunicaciones*/
	  gint incremento;	/*incremento de cuenta*/
	
	  guint c_mode16;	/*consigna de remote_mode*/
	  guint c_mode24;	/*consigna de operation_mode*/
	  
	  guint estadoEnatel;	/* Estado de los módulos Enatel	*/
	  guint32 milisegundosTrabajo;	/* Cuenta parcial de milisegundos trabajando	*/
	  guint horasTrabajo;	/* Horas de trabajo	*/
	};
#endif

