#! /bin/bash
#
# Este script genera automáticamente la documentación de AGS
# y la publica en el servidor HTTPS.
# NOTA: Por seguridad, ¡¡¡NO se ejecuta código del repositorio!!!

REPOS="$1"
REV="$2"

PATH=/usr/bin

VAR_PATH=/var/zigor/ags/
DOX_PATH=${VAR_PATH}/dox/

# Estos directorios, obtenidos con "checkouts"
TRUNK_PATH=${VAR_PATH}/trunk/
TOOLS_PATH=${TRUNK_PATH}/doc/tools/
DOC_HTML=${TRUNK_PATH}/doc/sources/html

cd ${TRUNK_PATH}
umask 007

# de uno en uno
while test -f .locked; do
  sleep 1s
done
touch .locked

# actualizamos "trunk"
svn update

# generamos los fuentes "a mano" (sin usar SCons)
gobs=`find ${TRUNK_PATH}/src -type f -name '*.gob'`
for g in ${gobs}
  do
  (cd `dirname "$g"` ; gob2 --no-gnu --no-self-alias --no-private-header "$g")
done

# "clean" html
rm -rf ${DOC_HTML}

# generamos documentación Doxygen
cp ${TOOLS_PATH}/doxygen.conf ${TRUNK_PATH}
doxygen doxygen.conf

# "clean" dox
rm -rf ${DOX_PATH}

# movemos documentación Doxygen en punto accesible HTTP
mkdir -p ${DOX_PATH}
mv ${DOC_HTML} ${DOX_PATH}

##
# DIGRAPHS
##
mkdir -p ${DOX_PATH}/digraphs
for p in ${TRUNK_PATH}/profiles/*.py
  do
  profile=`basename ${p/.py/}`
  echo ">>> $profile"
  (cd ${TRUNK_PATH} ; python ${TOOLS_PATH}/proftree.py $profile | neato | dot -Tps > ${DOX_PATH}/digraphs/pt-$profile.ps )
  for a in ${TRUNK_PATH}/data/config/$profile-*.lua
    do
    app=`basename ${a/.lua/}`
    echo ">>> $app"
    export LUA_PATH="?;?.lua"
    (cd ${TRUNK_PATH}/data/config ; lua ${TOOLS_PATH}/conftree.lua $app 1 | dot -Tps > ${DOX_PATH}/digraphs/ct-$app.ps )
    echo "<<< $app"
  done
  for c in ${TRUNK_PATH}/data/config/script-curs*-$profile.lua
    do
    curs=`basename ${c/.lua/}`
    echo ">>> $curs"
    export LUA_PATH="?;?.lua"
    (cd ${TRUNK_PATH}/data/config ; lua ${TOOLS_PATH}/menutree.lua $curs | dot -Tps > ${DOX_PATH}/digraphs/mt-$curs.ps )
    echo ">>> $curs"
  done
  echo "<<< $profile"
done

# XXX ¿insertar digraphs en TRAC?

# creamos index.html de documentación y digraphs
(cd ${DOX_PATH} ; tree -T "Documentación AGS r${REV}" -d -H . >index.html)
(cd ${DOX_PATH}/digraphs ; tree -T "Gráficas AGS r${REV}" -H . >index.html)

rm -f .locked
