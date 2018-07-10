require "functions"

function xscreensaver_restart(this, sds, oids)
   -- XXX (en principio parecia no hacia falta restart pero...)
   if not oids then oids = _G end -- Si no se especifica tabla de OIDs se supone global
   local v = access.get(sds, oids["zigorSysBacklightTimeout"]..".0")
   -- stop
   cmd="killall -KILL xscreensaver"
   print(cmd)
   os.execute(cmd)
   -- start
   if v~=0 then
      cmd="/usr/local/zigor/activa/tools/xscreensaver.sh &"
      print(cmd)
      os.execute(cmd)
   end
end

function xscreensaver_get(this, sds, oids)
   if not oids then oids = _G end -- Si no se especifica tabla de OIDs se supone global

   local t=string.gsub(this.tmpl, "%$(%d)", function (k)
	 local v = access.get(sds, oids["zigorSysBacklightTimeout"]..".0")
	 if k=="2" then v=v+1 end  -- idea de apagado black 1 minuto después del screensaver seleccionado
	 return v
      end)

   return t
end

local this  = {
   file     = "/home/genjur/.xscreensaver",
   --get      = tmpl_get,
   get      = xscreensaver_get,
   save     = tmpl_save,
   --restart  = tmpl_service_restart,
   --_service = "",
   restart  = xscreensaver_restart,
   tmpl     = [[
########################
# NO EDITAR ESTE FICHERO
# Created by AGS.
########################
# XScreenSaver Preferences File
# Written by xscreensaver-demo 5.20 for genjur on Fri Jan  9 09:13:10 2015.
# http://www.jwz.org/xscreensaver/

timeout:  0:$1:00
cycle:    0:02:00
lock:   False
lockTimeout:  0:05:00
passwdTimeout:  0:00:30
visualID: default
installColormap:    True
verbose:  False
timestamp:  True
splash:   True
splashDuration: 0:00:05
demoCommand:  xscreensaver-demo
prefsCommand: xscreensaver-demo -prefs
nice:   10
memoryLimit:  0
fade:   False
unfade:   False
fadeSeconds:  0:00:03
fadeTicks:  20
captureStderr:  True
ignoreUninstalledPrograms:False
font:   *-medium-r-*-140-*-m-*
dpmsEnabled:  True
dpmsQuickOff: True
dpmsStandby:  0:$2:00
dpmsSuspend:  0:$2:00
dpmsOff:  0:$2:00
grabDesktopImages:  True
grabVideoFrames:    False
chooseRandomImages: False
imageDirectory: /home/genjur/test-images

mode:   one
selected: 0

textMode: file
textLiteral:  XScreenSaver
textFile: /etc/gentoo-release
textProgram:  fortune
textURL:  http://planet.gentoo.org/rss20.xml

programs:                     \
  default-n:      xv -root -rmode 5 -random -viewonly       \
          -wloop -wait 3 $HOME/screensaver/*.jpg   \n\

pointerPollTime:    0:00:05
pointerHysteresis:  10
windowCreationTimeout:0:00:30
initialDelay: 0:00:00
GetViewPortIsFullOfLies:False
procInterrupts: True
xinputExtensionDev: False
overlayStderr:  False

]]

}

return this
