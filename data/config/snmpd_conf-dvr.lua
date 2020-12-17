require "functions"

function snmpd_conf_get(this, sds, oids)
   if not oids then oids = _G end -- Si no se especifica tabla de OIDs se supone global

   -- Sustituimos subidentificadores por OIDs
   local t=string.gsub(this.tmpl, "%$(%w+)", function (k) return oids[k] or "$" .. k end)
   -- Sustituimos OIDs por valor
   t=string.gsub(t, "%$([%.%d]+)", function (k) local v=access.get(sds, k) return v end)

   t=string.gsub(t, "_DISABLE_SNMP_", function (k)
                                         if access.get(sds, zigorNetEnableSnmp .. ".0")==2 then
                                            return "agentaddress localhost:161"
                                         else
                                            return ""
                                         end
                                      end)
   return t
end

local this  = {
   file     = "/etc/snmp/snmpd.conf",
   get      = snmpd_conf_get,
   save     = tmpl_save,   
   restart  = tmpl_service_restart,
   _service = "snmpd",
   tmpl     = [[
# NO EDITAR ESTE FICHERO

###########################################################################
#
# snmpd.conf
#
#   - created by AGS
#
###########################################################################
# SECTION: System Information Setup
#
#   This section defines some of the information reported in
#   the "system" mib group in the mibII tree.

sysname  $$zigorSysName.0
sysdescr $$zigorSysDescr.0
# XXX sysobjectid 

# syslocation: The [typically physical] location of the system.
#   Note that setting this value here means that when trying to
#   perform an snmp SET operation to the sysLocation.0 variable will make
#   the agent return the "notWritable" error code.  IE, including
#   this token in the snmpd.conf file will disable write access to
#   the variable.
#   arguments:  location_string

syslocation  $$zigorSysLocation.0

# syscontact: The contact information for the administrator
#   Note that setting this value here means that when trying to
#   perform an snmp SET operation to the sysContact.0 variable will make
#   the agent return the "notWritable" error code.  IE, including
#   this token in the snmpd.conf file will disable write access to
#   the variable.
#   arguments:  contact_string

syscontact  $$zigorSysContact.0



# sysservices: The proper value for the sysServices object.
#   arguments:  sysservices_number

sysservices 76
sysservices 76


###########################################################################
# SECTION: Access Control Setup
#
#   This section defines who is allowed to talk to your running
#   snmp agent.

# rwuser: a SNMPv3 read-write user
#   arguments:  user [noauth|auth|priv] [restriction_oid]

#rwuser  root   noauth
#rwuser  root  

# rouser: a SNMPv3 read-only user
#   arguments:  user [noauth|auth|priv] [restriction_oid]

#rouser  bigthor  

# rocommunity: a SNMPv1/SNMPv2c read-only access community name
#   arguments:  community [default|hostname|network/bits] [oid]

#rocommunity  user

# rwcommunity: a SNMPv1/SNMPv2c read-write access community name
#   arguments:  community [default|hostname|network/bits] [oid]

#rwcommunity  admin

###
# Configuración de acceso

# (NAME es SECURITY)
# com2sec NAME    SOURCE    COMMUNITY
com2sec   zadmin  default   zadmin
com2sec   admin   default   $$zigorSysPasswordPass.4
com2sec   zms     default   $$zigorSysPasswordPass.3
com2sec   user    default   $$zigorSysPasswordPass.2
com2sec   public  default   $$zigorSysPasswordPass.1

# (NAME es GROUP)
# group NAME        MODEL   SECURITY
group   grp_zadmin  v2c     zadmin
group   grp_admin   v2c     admin
group   grp_zms     v2c     zms
group   grp_user    v2c     user
group   grp_public  v2c     public

# (NAME es VIEW, para READ/WRITE/NOTIFY)
# view NAME       TYPE       SUBTREE [MASK]
###
### XXX
### Primera implementacion que solo restringe la escritura para aquellas variables definidas en ficheros .lxml
### que definen visualizacion gtk2 para cada nivel de acceso, y no se desean poder editar.
### Asi pues no queda restringido el mismo acceso a visualizacion y edicion estrictamente por snmp.
###
### ZADMIN (nivel de acceso total fijo, ZigorADMIN)
view   vw_zadmin   included   .1

### ADMIN (nivel 4)
view   vw_admin   included   .1

### ZMS (nivel 3)
###--read access:
view   vw_zms     included   $zigorExperiment
view   vw_zms     excluded   $zigorSysPasswordPass.4
###... XXX
###--write access:
view   vw_zmsW    included   $zigorExperiment

### USER (nivel 2)
###--read access:
view   vw_user    included   $zigorExperiment
view   vw_user    excluded   $zigorSysPasswordPass.4
view   vw_user    excluded   $zigorSysPasswordPass.3
###... XXX
###--write access:
view   vw_userW   included   $zigorExperiment
view   vw_userW   excluded   $zigorSysCode.0
view   vw_userW   included   $zigorDvrParamVRedNom.0
view   vw_userW   excluded   $zigorDvrParamVMinDVR.0
view   vw_userW   excluded   $zigorDvrParamNumEquipos.0
view   vw_userW   excluded   $zigorDvrParamFactor.0
view   vw_userW   included   $zigorDvrParamFrecNom.0
view   vw_userW   excluded   $zigorDvrParamHuecoNom.0
view   vw_userW   excluded   $zigorAlarmCfgSeverity
view   vw_userW   excluded   $zigorCtrlParamDemo.0

### PUBLIC (nivel 1)
###--read access:
view   vw_public  included   $zigorExperiment
view   vw_public  excluded   $zigorSysPasswordPass.4
view   vw_public  excluded   $zigorSysPasswordPass.3
view   vw_public  excluded   $zigorSysPasswordPass.2
###... XXX
###--write access:
view   vw_publicW included   $zigorSysPasswordPass.1
view   vw_publicW included   $zigorCtrlParamState.0

# access GROUP      CONTEXT MODEL LEVEL  PREFX READ       WRITE       NOTIFY
access   grp_zadmin ""      v2c   noauth exact vw_zadmin  vw_zadmin   vw_zadmin
access   grp_admin  ""      v2c   noauth exact vw_admin   vw_admin    vw_admin
access   grp_zms    ""      v2c   noauth exact vw_zms     vw_zmsW     none
access   grp_user   ""      v2c   noauth exact vw_user    vw_userW    none
access   grp_public ""      v2c   noauth exact vw_public  vw_publicW  none

###########################################################################
# SECTION: Trap Destinations
#
#   Here we define who the agent will send traps to.

# trapsink: A SNMPv1 trap receiver
#   arguments: host [community] [portnum]

###trapsink  localhost  

# trap2sink: A SNMPv2c trap receiver
#   arguments: host [community] [portnum]

###trap2sink  localhost
trap2sink  udp:65162
trap2sink  udp:65163


# informsink: A SNMPv2c inform (acknowledged trap) receiver
#   arguments: host [community] [portnum]

##informsink  localhost

# trapcommunity: Default trap sink community to use
#   arguments: community-string

trapcommunity  $$zigorSysPasswordPass.1

# authtrapenable: Should we send traps when authentication failures occur
#   arguments: 1 | 2   (1 = yes, 2 = no)

authtrapenable  1



###########################################################################
# SECTION: Monitor Various Aspects of the Running Host
#
#   The following check up on various aspects of a host.

# proc: Check for processes that should be running.
#     proc NAME [MAX=0] [MIN=0]
#   
#     NAME:  the name of the process to check for.  It must match
#            exactly (ie, http will not find httpd processes).
#     MAX:   the maximum number allowed to be running.  Defaults to 0.
#     MIN:   the minimum number to be running.  Defaults to 0.
#   
#   The results are reported in the prTable section of the UCD-SNMP-MIB tree
#   Special Case:  When the min and max numbers are both 0, it assumes
#   you want a max of infinity and a min of 1.

proc  apache2  
proc  sshd  

# disk: Check for disk space usage of a partition.
#   The agent can check the amount of available disk space, and make
#   sure it is above a set limit.  
#   
#    disk PATH [MIN=100000]
#   
#    PATH:  mount path to the disk in question.
#    MIN:   Disks with space below this value will have the Mib's errorFlag set.
#           Can be a raw byte value or a percentage followed by the %
#           symbol.  Default value = 100000.
#   
#   The results are reported in the dskTable section of the UCD-SNMP-MIB tree

disk  / 

# load: Check for unreasonable load average values.
#   Watch the load average levels on the machine.
#   
#    load [1MAX=12.0] [5MAX=12.0] [15MAX=12.0]
#   
#    1MAX:   If the 1 minute load average is above this limit at query
#            time, the errorFlag will be set.
#    5MAX:   Similar, but for 5 min average.
#    15MAX:  Similar, but for 15 min average.
#   
#   The results are reported in the laTable section of the UCD-SNMP-MIB tree

load  5 5 5



###########################################################################
# SECTION: Agent Operating Mode
#
#   This section defines how the agent will operate when it
#   is running.

# master: Should the agent operate as a master agent or not.
#   Currently, the only supported master agent type for this token
#   is "agentx".
#   
#   arguments: (on|yes|agentx|all|off|no)

master  yes

# Incrementar este valor si el servidor muere
# por "broken pipe" (SIGPIPE)
AgentXTimeout 90

_DISABLE_SNMP_
]]

}

return this
