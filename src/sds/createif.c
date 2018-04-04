/**
 * \file createif.c 
 * Interface create.
 */

#include <glib.h>
#include <glib-object.h>
#include "createif.h"

GType 
create_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (CreateIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "CreateIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

/**
 * Añade una nueva variable al SDS.
 */
inline 
int
create_add(CreateIf *self, char *k, char *name) {
  return CREATEIF_GET_IFACE(self)->add_value(self, k,name); 
}
