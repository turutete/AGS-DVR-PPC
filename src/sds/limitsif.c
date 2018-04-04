/**
 * \file limitsif.c 
 * Interface limits.
 */

#include <glib.h>
#include <glib-object.h>
#include "limitsif.h"

GType 
limits_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (LimitsIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "LimitsIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline 
gboolean
limits_add(LimitsIf *self, GParamSpec *limit) {
  return LIMITSIF_GET_IFACE(self)->add_limit(self, limit);  
}

inline
gboolean
limits_set(LimitsIf *self, char *k, char *name) {
  return LIMITSIF_GET_IFACE(self)->set_limit(self, k, name);
}

inline 
gboolean
limits_check(LimitsIf *self, char *k, GValue *v) {
  return LIMITSIF_GET_IFACE(self)->check_limit(self, k, v);
}
