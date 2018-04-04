/**
   \file interpreterif.c 
   Interface interpreter.
 */

#include <glib.h>
#include <glib-object.h>
#include "interpreterif.h"

GType 
interpreter_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (InterpreterIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "InterpreterIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline
GValue*
interpreter_run(InterpreterIf *self, gchar* text, gint len, gchar* name, AgsCf* cf, CfTable cft) {
  return INTERPRETERIF_GET_IFACE(self)->run(self, text, len, name, cf, cft);
}
inline
void
interpreter_stream(InterpreterIf *self, GIOChannel *io) {
  return INTERPRETERIF_GET_IFACE(self)->stream(self, io);
}
