#!/bin/bash
# extraer textos a traducir de los ficheros que los contienen
if [ $# -ne 2 ];
then
   echo "Usage: $0 profile_name lxml_level"
   exit
fi
##########
PROFILE=$1
LEVEL=$2

OUT=$PROFILE.ppot
OUT2=$PROFILE.pot
##########

###FILE=ui-sunzet.glade
###xgettext --sort-output --keyword=translatable -o $OUT ../ui/$FILE

FILE=ui-$PROFILE-$LEVEL.lxml
###echo "" >>$OUT
echo "" >$OUT
./xgettext-lxml.sed ../ui/$FILE >>$OUT

FILE=$PROFILE-gtk2ui.lua
./xgettext-xxx-gtk2ui.sed $FILE >>$OUT

FILE=displays-$PROFILE.lua
./xgettext.lua $FILE >>$OUT

FILE=script-gtk2ui-$PROFILE.lua
./xgettext.lua $FILE >>$OUT

FILE=script-curs2x16-$PROFILE.lua
./xgettext.lua $FILE >>$OUT

FILE=factory-$PROFILE.lua
./xgettext.lua $FILE >>$OUT

FILE=edit.lua
./xgettext.lua $FILE >>$OUT

FILE=script-snmpd-$PROFILE.lua
./xgettext.lua $FILE >>$OUT

FILE=ui-$PROFILE.glade
#FILE=ui-xxx.glade
xgettext --sort-output --keyword=translatable -o $OUT2 ../ui/$FILE

xgettext --add-comments --no-location -C --from-code UTF-8 -k_ -j -o $OUT2 $OUT

#rm $OUT

###
echo "----------"
echo "NOTAS: (vease manual gettext)"
echo "Editar la plantilla de catalogo resultante (.pot) para establecer el charset sobretodo"
echo "Content-Type: text/plain; charset=UTF-8\n"
echo ""
echo "Ahora COPIAR plantilla a fichero de catalogo incluyendo codigo de idioma (2 letras: en.po, sunzet100-en.po etc)"
echo "Rellenar info de traduccion en catalogo (vease tb msginit)"
echo ""
echo "Hacer las traducciones"
echo ""
echo "Convertir a formato BINARIO (.mo) con: msgfmt en.po -o en.mo; y copiar a /usr/share/locale/en/LC_MESSAGES"
echo "ojo dar nombre segun textdomain a utilizar, p.ej: sunzet.mo"
echo ""
echo "ojo, sino existe el locale crearlo o copiarlo (/usr/lib/locale)"
echo ""
echo "Actualizaciones de catalogos tras actualizacion de plantilla: msgmerge -o file def.po ref.pot"
echo "OJO mirar para que en cadenas nuevas no haga sugerencia de traduccion con #fuzzy"
echo ""
echo "Para pasar a traducir, mejor pasar en formato DOS: unix2dos -n xxx.pot xxx.pot.txt"
echo "----------"
