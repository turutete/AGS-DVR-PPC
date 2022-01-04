require "functions"

function lighttpd_start()
   os.execute("lighttpd -f /etc/lighttpd/lighttpd.conf")
end

function lighttpd_stop()
   os.execute("killall lighttpd")
end

function lighttpd_restart()
   lighttpd_stop()
   lighttpd_start()
end

local this  = {
   file     = "/etc/lighttpd/lighttpd.conf",
   get      = tmpl_get,
   save     = tmpl_save,
   start    = lighttpd_start,
   stop     = lighttpd_stop,
   restart  = lighttpd_restart,
   tmpl     = [[
# NO EDITAR ESTE FICHERO

# Created by AGS.

# Variable de activacion, presente solo para forzar 
# notificacion del cambio al guardar template $$zigorNetEnableHTTP.0

server.modules += ( "mod_proxy", "mod_websocket", "mod_cgi", "mod_alias" )

server.document-root = "/usr/local/zigor/activa/www/html" 

$HTTP["url"] =~ "^/cgi-bin/" {
    alias.url += ( "/cgi-bin" => "/usr/local/zigor/activa/www/cgi-bin" )
    cgi.assign = ( "" => "" )
}

server.username = "ags" 
server.groupname = "users" 
server.tag = ""

server.port = $$zigorNetPortHttp.0

mimetype.assign = (
  ".html" => "text/html", 
  ".css" => "text/css",
  ".txt" => "text/plain",
  ".jpg" => "image/jpeg",
  ".png" => "image/png",
  ".js" => "text/javascript" 
)

index-file.names = ( "index.html" )

websocket.server = (
                     # WebSocket-TCP Proxy
                     "^\/tcp_proxy\/*" => ( "host" => "localhost",
                                        "port" => $$zigorNetPortVnc.0,
                                        "proto" => "tcp",
                                        "type" => "binary",
                                        "subproto" => "binary",
                                        ),

                   )

websocket.ping_interval = 5 # send PING per 5 secs
websocket.timeout = 30      # disconnect a client when not to recv PONG for 30 secs
websocket.debug = 0

]]

}

return this
