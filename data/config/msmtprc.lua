require "functions"

no=[[
### no auth
auth on
tls off
tls_starttls off
tls_certcheck off
#########]]

ssl=[[
### SSL
auth on
tls on
tls_starttls off
tls_certcheck off
#########]]

tls=[[
### TLS
auth on
tls on
tls_starttls on
tls_certcheck off
#########]]

auth={
   ["NO"] = no,
   ["SSL"] = ssl,
   ["TLS"] = tls,
}

function myget(this, sds, oids)
   if not oids then oids = _G end -- Si no se especifica tabla de OIDs se supone global
   
   -- Sustituimos subidentificadores por OIDs
   local t=string.gsub(this.tmpl, "%$(%w+)", function (k) return oids[k] or "" end)
   -- Sustituimos OIDs por valor
   t=string.gsub(t, "%$([%.%d]+)", function (k) local v=access.get(sds, k) return v end)
   -- new:
   -- Sustituimos cadenas de autenticacion
   t=string.gsub(t, "auth=(%a+)", function (k) return auth[k] or "" end)

   return t
end

local this  = {
   file     = "/etc/msmtprc",
   --get      = tmpl_get,
   get      = myget,
   save     = tmpl_save,
   --restart  = tmpl_service_restart,
   --service = "",
   tmpl     = [[
# NO EDITAR ESTE FICHERO

###########################################################################
#
# /etc/msmtprc
#
#   - created by AGS
#
###########################################################################

# Set default values for all following accounts.
defaults
logfile /var/log/msmtp.zlog
#tls_force_sslv3 on
timeout 5

# cuenta zigor
account zigor
host cuarentena.zigor.com
port 25
#from eventosequiposremotos@zigor.com
from sws1000@zigor.com
# ok si todo comentado
#auth off
#tls off
#tls_certcheck off
#tls_starttls off
#user eventos
#password eer

# cuenta de usuario
account user
host $$zigorNetSmtp.0
from $$zigorNetSmtpEmail.0
auth=$$zigorNetSmtpAuth.0
user $$zigorNetSmtpUser.0
password $$zigorNetSmtpPass.0

# Set a default account
account default : zigor
]]

}

return this
