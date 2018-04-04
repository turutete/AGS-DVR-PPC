#!/usr/bin/sed -nf

# 'xgettext' via sed
# extraer cadenas marcadas en ui-xxx.lxml

# extraer todos los 'name="XXX"'
/name[ ]*=[ ]*"/ {
###s/^.*name[ ]*=[ ]*"\([^"]*\)".*$/msgid "\1"/
s/^.*name[ ]*=[ ]*"\([^"]*\)".*$/_("\1")/
# y eliminar lineas con $
/\$/d
###a\
###msgstr ""\
###
p
}
