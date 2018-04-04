#ifndef BUSIF_H

#include <glib-2.0/glib-object.h>
#include <ags-cf.h>

#define BUSIF_H

#define TYPE_BUSIF	 (bus_if_get_type ())
#define BUSIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_BUSIF, BusIf))
#define IS_BUSIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_BUSIF))
#define BUSIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_BUSIF, BusIfIface))
                                                                                           
typedef struct _BusIf	BusIf;
typedef struct _BusIfIface BusIfIface;

struct _BusIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  int (*write) (BusIf* self, gchar* obj_name, gchar* poll_da);
  int (*write2) (BusIf* self, gchar* obj_name, gchar* poll_da, GValueArray * m, GValueArray * v);
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup busif busif
 * \ingroup interfaces
 */
/*@{*/
GType bus_if_get_type (void);

inline int bus_write(BusIf* self, gchar* obj_name, gchar* poll_da);
inline int bus_write2(BusIf* self, gchar* obj_name, gchar* poll_da, GValueArray * m, GValueArray * v);
/*@}*/


#endif /* BUSIF_H */
