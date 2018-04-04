# script para sed (-f)

# marcar para gettext de la forma: _g(...)

###
# marcar ) en todos los finales de display...
#s/display[^=]*=[ ]*"[^"]*"/&)/g

# marcar _g( en cada campo deseado:
#s/display[ ]*=[ ]*/&_g(/g
#s/display_lcd[ ]*=[ ]*/&_g(/g
#s/display_sms[ ]*=[ ]*/&_g(/g

# marcar etiquetas <tt> ... </tt>
#s/<tt>/&'.._g("/g
#s/<\/tt>/")&/g

### o mejor:

# marcar en los campos: display=, display_lcd=, display_sms=
s/display[ ]*=[ ]*"\([^"]*\)"/display = _g("\1")/
s/display_lcd[ ]*=[ ]*"\([^"]*\)"/display_lcd = _g("\1")/
s/display_sms[ ]*=[ ]*"\([^"]*\)"/display_sms = _g("\1")/

# marcar en las etiquetas <tt> ... </tt>
s/<tt>\(.*\)<\/tt>/<tt>'.._g("\1")..'<\/tt>/
