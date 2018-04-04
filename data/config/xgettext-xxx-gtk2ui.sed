#!/usr/bin/sed -nf

# 'xgettext' via sed
# extraer cadenas marcadas en xxx-gtk2ui.lua

# extraer todos los 'title="XXX"'
/title[ ]*=[ ]*"/ {
###s/^.*title[ ]*=[ ]*"\([^"]*\)".*$/msgid "\1"/
s/^.*title[ ]*=[ ]*"\([^"]*\)".*$/_("\1")/
###a\
###msgstr ""\
###
p
}

# extraer 'name="XXX"' despues de 'root_rules'
/root_rules/ {
N
###s/^.*name[ ]*=[ ]*"\([^"]*\)".*$/msgid "\1"/
s/^.*name[ ]*=[ ]*"\([^"]*\)".*$/_("\1")/
###a\
###msgstr ""\
###
p
}

# extraer textos con marcas de gettext '_g("XXX")'
# solo una marca por linea
/_g("/ {
###s/^.*_g("\([^"]*\)".*$/msgid "\1"/g
s/^.*_g("\([^"]*\)".*$/_("\1")/g
###a\
###msgstr ""\
###
p
}
