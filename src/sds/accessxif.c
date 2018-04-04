/**
 * \file accessxif.c 
 * Interface accessx (access eXtendida).
 */

#include <glib.h>
#include <glib-object.h>
#include "accessxif.h"

GType 
accessx_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (AccessxIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "AccessxIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline 
GValue*
accessx_getnext(AccessxIf *self, char *k) {
  return ACCESSXIF_GET_IFACE(self)->getnext(self, k);  
}

inline 
char*
accessx_getnextkey(AccessxIf *self, char *k) {
  return ACCESSXIF_GET_IFACE(self)->getnextkey(self, k);  
}

