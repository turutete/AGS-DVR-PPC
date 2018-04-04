/**
 * \file queryif.c 
 * Interface query.
 */

#include <glib.h>
#include <glib-object.h>
#include "queryif.h"

GType 
query_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (QueryIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "QueryIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline 
int
query_exec(QueryIf *self, char *qstr, int qlen, char ***col_names, QueryRowCallback cb, gpointer user_data) {
  return QUERYIF_GET_IFACE(self)->exec(self, qstr, qlen, col_names, cb, user_data);
}
