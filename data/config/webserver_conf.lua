require "functions"

function lighttpd_restart()
   os.execute("killall lighttpd")
   os.execute("lighttpd -f /etc/lighttpd/lighttpd.conf")
end

local this  = {
   file     = "/etc/lighttpd/lighttpd.conf",
   get      = tmpl_get,
   save     = tmpl_save,
   restart  = lighttpd_restart,
   tmpl     = [[
# NO EDITAR ESTE FICHERO

# Created by AGS.

server.modules += ( "mod_proxy", "mod_websocket", "mod_cgi", "mod_alias" )

server.document-root = "/usr/local/zigor/activa/www/html" 

$HTTP["url"] =~ "^/cgi-bin/" {
    alias.url += ( "/cgi-bin" => "/usr/local/zigor/activa/www/cgi-bin" )
    cgi.assign = ( "" => "" )
}

server.username = "ags" 
server.groupname = "users" 

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
