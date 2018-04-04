# script para sed (-f)

# marcar para gettext de la forma: _g(...)

# marcar todos los: [[...]]
s/\[\[/_g(\[\[/
s/\]\]/\]\])/

# marcar en las definiciones de etiquetas: eti_... = { "XXX",... }
/eti.*=/s/"\([^"]*\)"/_g("\1")/g

# eliminar si acaso los templates sin texto susceptible de traduccion
