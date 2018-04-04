/**
 * \file accessif.c 
 * Interface access.
 */

#include <glib.h>
#include <glib-object.h>
#include "accessif.h"

GType 
access_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (AccessIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "AccessIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline 
GValue*
access_get(AccessIf *self, char *k) {
  return ACCESSIF_GET_IFACE(self)->get(self, k);  
}

inline 
GString*
access_get_string(AccessIf *self, char *k) {
  return ACCESSIF_GET_IFACE(self)->get_string(self, k);
}

inline 
int
access_set(AccessIf *self, char *k, GValue *v) {
  return ACCESSIF_GET_IFACE(self)->set(self, k, v);
}

