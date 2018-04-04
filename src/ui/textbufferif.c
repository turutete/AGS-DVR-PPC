/**
   \file textbufferif.c 
   Interface textbuffer.
 */

#include <glib.h>
#include <glib-object.h>
#include "textbufferif.h"

GType 
textbuffer_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (TextbufferIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "TextbufferIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline
gchar*
textbuffer_get(TextbufferIf *self, gint* len) {
  return TEXTBUFFERIF_GET_IFACE(self)->get(self, len);
}

inline
void
textbuffer_set(TextbufferIf *self, const gchar* text, gint len) {
  TEXTBUFFERIF_GET_IFACE(self)->set(self, text, len);
}
