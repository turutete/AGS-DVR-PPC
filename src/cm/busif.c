/**
   \file busif.c 
   Interface bus.
 */

#include <glib.h>
#include <glib-object.h>
#include "busif.h"

GType 
bus_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (BusIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "BusIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline
int
bus_write(BusIf *self, gchar* obj_name, gchar* poll_da) {
  return BUSIF_GET_IFACE(self)->write(self, obj_name, poll_da);
}

inline
int
bus_write2(BusIf* self, gchar* obj_name, gchar* poll_da, GValueArray * m, GValueArray * v) {
  return BUSIF_GET_IFACE(self)->write2(self, obj_name, poll_da, m, v);
}
