#ifndef TRAPIF_H

#define TRAPIF_H

#define TYPE_TRAPIF	 (trap_if_get_type ())
#define TRAPIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_TRAPIF, TrapIf))
#define IS_TRAPIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_TRAPIF))
#define TRAPIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_TRAPIF, TrapIfIface))
                                                                                           
typedef struct _TrapIf	TrapIf;
typedef struct _TrapIfIface TrapIfIface;

struct _TrapIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  int (*add_trap)  (TrapIf *self, char* t);          /**< Añade un trap */
  int (*add_member)(TrapIf *self, char* t, char* m); /**< Añade un miembro a un trap */
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup trapif trapif
 * \ingroup interfaces
 */
/*@{*/
GType trap_if_get_type(void);

inline int trap_add   (TrapIf *self, char* t);
inline int trap_member(TrapIf *self, char* t, char* m);
/*@}*/

#endif /* TRAPIF_H */
