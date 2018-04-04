#ifndef BUSMAGIF_H

#include <glib-2.0/glib-object.h>
#include <ags-cf.h>
#include <rectificador.h>  /*tipo_EstadoRectificador*/

#define BUSMAGIF_H

#define TYPE_BUSMAGIF	 (busmag_if_get_type ())
#define BUSMAGIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_BUSMAGIF, BusMagIf))
#define IS_BUSMAGIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_BUSMAGIF))
#define BUSMAGIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_BUSMAGIF, BusMagIfIface))
                                                                                           
typedef struct _BusMagIf	BusMagIf;
typedef struct _BusMagIfIface BusMagIfIface;

struct _BusMagIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  int (*write) (BusMagIf* self, gchar da, gchar com, gchar* param, guint8 len, guint8 prioridad);
  tipo_EstadoRectificador (*lee_rec) (BusMagIf* self, guint n_rec);
	void (*escribe_milisegundosTrabajo) (BusMagIf* self, guint n_rec, guint32 milis);
	void (*escribe_horasTrabajo) (BusMagIf* self, guint n_rec, guint horas);
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup busmagif busmagif
 * \ingroup interfaces
 */
/*@{*/
GType busmag_if_get_type (void);

inline int busmag_write(BusMagIf* self, gchar da, gchar com, gchar* param, guint8 len, guint8 prioridad);
inline tipo_EstadoRectificador busmag_lee_rec(BusMagIf* self, guint n_rec);
inline void busmag_escribe_milisegundosTrabajo(BusMagIf* self, guint n_rec, guint32 milis);
inline void busmag_escribe_horasTrabajo(BusMagIf* self, guint n_rec, guint horas);
/*@}*/


#endif /* BUSMAGIF_H */
