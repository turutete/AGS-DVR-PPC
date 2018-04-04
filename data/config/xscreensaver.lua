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
	 if k=="2" then v=v+1 end  -- idea de apagado black 1 minuto despu�s del screensaver seleccionado
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

timeout:	0:$1:00
cycle:		0:02:00
lock:		False
lockTimeout:	0:05:00
passwdTimeout:	0:00:30
visualID:	default
installColormap:    True
verbose:	False
timestamp:	True
splash:		True
splashDuration:	0:00:05
demoCommand:	xscreensaver-demo
prefsCommand:	xscreensaver-demo -prefs
nice:		10
memoryLimit:	0
fade:		False
unfade:		False
fadeSeconds:	0:00:03
fadeTicks:	20
captureStderr:	True
ignoreUninstalledPrograms:False
font:		*-medium-r-*-140-*-m-*
dpmsEnabled:	True
dpmsQuickOff:	True
dpmsStandby:	0:$2:00
dpmsSuspend:	0:$2:00
dpmsOff:	0:$2:00
grabDesktopImages:  True
grabVideoFrames:    False
chooseRandomImages: False
imageDirectory:	/home/genjur/test-images

mode:		one
selected:	16

textMode:	file
textLiteral:	XScreenSaver
textFile:	/etc/gentoo-release
textProgram:	fortune
textURL:	http://planet.gentoo.org/rss20.xml

programs:								      \
				maze -root				    \n\
- GL: 				superquadrics -root			    \n\
				attraction -root			    \n\
				blitspin -root				    \n\
				greynetic -root				    \n\
				helix -root				    \n\
				hopalong -root				    \n\
				imsmap -root				    \n\
-				noseguy -root				    \n\
-				pyro -root				    \n\
				qix -root				    \n\
-				rocks -root				    \n\
				rorschach -root				    \n\
				decayscreen -root			    \n\
				flame -root				    \n\
				halo -root				    \n\
				slidescreen -root -grid-size 402 -ibw 5	    \n\
				pedal -root				    \n\
				bouboule -root				    \n\
-				braid -root				    \n\
				coral -root				    \n\
				deco -root				    \n\
				drift -root				    \n\
-				fadeplot -root				    \n\
				galaxy -root				    \n\
				goop -root				    \n\
				grav -root				    \n\
				ifs -root				    \n\
- GL: 				jigsaw -root				    \n\
				julia -root				    \n\
-				kaleidescope -root			    \n\
- GL: 				moebius -root				    \n\
				moire -root				    \n\
- GL: 				morph3d -root				    \n\
				mountain -root				    \n\
				munch -root				    \n\
				penrose -root				    \n\
- GL: 				pipes -root				    \n\
				rd-bomb -root				    \n\
- GL: 				rubik -root				    \n\
-				sierpinski -root			    \n\
				slip -root				    \n\
- GL: 				sproingies -root			    \n\
				starfish -root				    \n\
				strange -root				    \n\
				swirl -root				    \n\
				triangle -root				    \n\
				xjack -root				    \n\
				xlyap -root				    \n\
- GL: 				atlantis -root				    \n\
				bsod -root -no-nt -no-2k -no-amiga	      \
				  -no-glados -no-nvidia -no-mac -no-mac1      \
				  -no-macsbug -no-macx -no-os390 -no-vms      \
				  -no-hvx -no-blitdamage -no-atm	      \
				  -no-solaris -no-sco -no-hpux -no-tru64    \n\
- GL: 				bubble3d -root				    \n\
- GL: 				cage -root				    \n\
-				crystal -root				    \n\
				cynosure -root				    \n\
				discrete -root				    \n\
				distort -root				    \n\
				epicycle -root				    \n\
				flow -root				    \n\
- GL: 				glplanet -root				    \n\
				interference -root			    \n\
				kumppa -root				    \n\
- GL: 				lament -root				    \n\
				moire2 -root				    \n\
- GL: 				sonar -root				    \n\
- GL: 				stairs -root				    \n\
				truchet -root				    \n\
-				vidwhacker -root			    \n\
				blaster -root				    \n\
				bumps -root				    \n\
				ccurve -root				    \n\
				compass -root				    \n\
				deluxe -root				    \n\
-				demon -root				    \n\
- GL: 				extrusion -root				    \n\
-				loop -root				    \n\
				penetrate -root				    \n\
				petri -root				    \n\
				phosphor -root				    \n\
- GL: 				pulsar -root				    \n\
				ripples -root				    \n\
				shadebobs -root				    \n\
- GL: 				sierpinski3d -root			    \n\
				spotlight -root				    \n\
				squiral -root				    \n\
				wander -root				    \n\
-				webcollage -root			    \n\
				xflame -root				    \n\
				xmatrix -root				    \n\
- GL: 				gflux -root				    \n\
-				nerverot -root				    \n\
				xrayswarm -root				    \n\
				xspirograph -root			    \n\
- GL: 				circuit -root				    \n\
- GL: 				dangerball -root			    \n\
- GL: 				dnalogo -root				    \n\
- GL: 				engine -root				    \n\
- GL: 				flipscreen3d -root			    \n\
- GL: 				gltext -root				    \n\
- GL: 				menger -root				    \n\
- GL: 				molecule -root				    \n\
				rotzoomer -root				    \n\
				speedmine -root				    \n\
- GL: 				starwars -root				    \n\
- GL: 				stonerview -root			    \n\
				vermiculate -root			    \n\
				whirlwindwarp -root			    \n\
				zoom -root				    \n\
				anemone -root				    \n\
				apollonian -root			    \n\
- GL: 				boxed -root				    \n\
- GL: 				cubenetic -root				    \n\
- GL: 				endgame -root				    \n\
				euler2d -root				    \n\
				fluidballs -root			    \n\
- GL: 				flurry -root				    \n\
- GL: 				glblur -root				    \n\
- GL: 				glsnake -root				    \n\
				halftone -root				    \n\
- GL: 				juggler3d -root				    \n\
- GL: 				lavalite -root				    \n\
-				polyominoes -root			    \n\
- GL: 				queens -root				    \n\
- GL: 				sballs -root				    \n\
- GL: 				spheremonics -root			    \n\
-				thornbird -root				    \n\
				twang -root				    \n\
- GL: 				antspotlight -root			    \n\
				apple2 -root				    \n\
- GL: 				atunnel -root				    \n\
				barcode -root				    \n\
- GL: 				blinkbox -root				    \n\
- GL: 				blocktube -root				    \n\
- GL: 				bouncingcow -root			    \n\
				cloudlife -root				    \n\
- GL: 				cubestorm -root				    \n\
				eruption -root				    \n\
- GL: 				flipflop -root				    \n\
- GL: 				flyingtoasters -root			    \n\
				fontglide -root				    \n\
- GL: 				gleidescope -root			    \n\
- GL: 				glknots -root				    \n\
- GL: 				glmatrix -root				    \n\
- GL: 				glslideshow -root			    \n\
- GL: 				hypertorus -root			    \n\
- GL: 				jigglypuff -root			    \n\
				metaballs -root				    \n\
- GL: 				mirrorblob -root			    \n\
				piecewise -root				    \n\
- GL: 				polytopes -root				    \n\
				pong -root				    \n\
				popsquares -root			    \n\
- GL: 				surfaces -root				    \n\
				xanalogtv -root				    \n\
-				abstractile -root			    \n\
				anemotaxis -root			    \n\
- GL: 				antinspect -root			    \n\
				fireworkx -root				    \n\
				fuzzyflakes -root			    \n\
				interaggregate -root			    \n\
				intermomentary -root			    \n\
				memscroller -root			    \n\
- GL: 				noof -root				    \n\
				pacman -root				    \n\
- GL: 				pinion -root				    \n\
- GL: 				polyhedra -root				    \n\
- GL: 				providence -root			    \n\
				substrate -root				    \n\
				wormhole -root				    \n\
- GL: 				antmaze -root				    \n\
- GL: 				boing -root				    \n\
				boxfit -root				    \n\
- GL: 				carousel -root				    \n\
				celtic -root				    \n\
- GL: 				crackberg -root				    \n\
- GL: 				cube21 -root				    \n\
				fiberlamp -root				    \n\
- GL: 				fliptext -root				    \n\
- GL: 				glhanoi -root				    \n\
- GL: 				tangram -root				    \n\
- GL: 				timetunnel -root			    \n\
- GL: 				glschool -root				    \n\
- GL: 				topblock -root				    \n\
- GL: 				cubicgrid -root				    \n\
				cwaves -root				    \n\
- GL: 				gears -root				    \n\
- GL: 				glcells -root				    \n\
- GL: 				lockward -root				    \n\
				m6502 -root				    \n\
- GL: 				moebiusgears -root			    \n\
- GL: 				voronoi -root				    \n\
- GL: 				hypnowheel -root			    \n\
- GL: 				klein -root				    \n\
-				lcdscrub -root				    \n\
- GL: 				photopile -root				    \n\
- GL: 				skytentacles -root			    \n\
- GL: 				rubikblocks -root			    \n\
- GL: 				companioncube -root			    \n\
- GL: 				hilbert -root				    \n\
- GL: 				tronbit -root				    \n\


pointerPollTime:    0:00:05
pointerHysteresis:  10
windowCreationTimeout:0:00:30
initialDelay:	0:00:00
GetViewPortIsFullOfLies:False
procInterrupts:	True
xinputExtensionDev: False
overlayStderr:	True

]]

}

return this
