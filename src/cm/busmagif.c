/**
   \file busmagif.c 
   Interface bus.
 */

#include <glib.h>
#include <glib-object.h>
#include "busmagif.h"

GType 
busmag_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (BusMagIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "BusMagIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline
int
busmag_write(BusMagIf *self, gchar da, gchar com, gchar* param, guint8 len, guint8 prioridad) {
  return BUSMAGIF_GET_IFACE(self)->write(self, da, com, param, len, prioridad);
}

inline
tipo_EstadoRectificador
busmag_lee_rec(BusMagIf *self, guint n_rec) {
  return BUSMAGIF_GET_IFACE(self)->lee_rec(self, n_rec);
}

inline
void
busmag_escribe_milisegundosTrabajo(BusMagIf* self, guint n_rec, guint32 milis) {
  BUSMAGIF_GET_IFACE(self)->escribe_milisegundosTrabajo(self, n_rec, milis);
}

inline
void
busmag_escribe_horasTrabajo(BusMagIf* self, guint n_rec, guint horas) {
  BUSMAGIF_GET_IFACE(self)->escribe_horasTrabajo(self, n_rec, horas);
}
