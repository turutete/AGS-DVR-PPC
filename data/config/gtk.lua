loadlualib("gtk")
do
   gtk.colorize_as_empty  = function(w) gtk.colorize(w, x"FFFF", x"FFFF", x"FFFF") end
   gtk.colorize_as_valid  = function(w) gtk.colorize(w, x"AFFF", x"FFFF", x"AFFF") end
   gtk.colorize_as_invalid= function(w) gtk.colorize(w, x"FFFF", x"AFFF", x"AFFF") end
end
