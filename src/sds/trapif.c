/**
 * \file trapif.c 
 * Interface trap.
 */

#include <glib.h>
#include <glib-object.h>
#include "trapif.h"

GType 
trap_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (TrapIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "TrapIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline 
int
trap_add(TrapIf *self, char* t) {
  return TRAPIF_GET_IFACE(self)->add_trap(self, t);
}

inline 
int
trap_member(TrapIf *self, char* t, char* m) {
  return TRAPIF_GET_IFACE(self)->add_member(self, t, m);
}
