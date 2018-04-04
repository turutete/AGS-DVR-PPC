#ifndef CREATEIF_H

#define CREATEIF_H

#define TYPE_CREATEIF	 (create_if_get_type ())
#define CREATEIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_CREATEIF, CreateIf))
#define IS_CREATEIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_CREATEIF))
#define CREATEIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_CREATEIF, CreateIfIface))

typedef struct _CreateIf	CreateIf;
typedef struct _CreateIfIface CreateIfIface;

struct _CreateIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  int (*add_value)(CreateIf *self, char *k, char *name);
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup createif createif
 * \ingroup interfaces
 */
/*@{*/
GType create_if_get_type(void);

inline int create_add(CreateIf *self, char *k, char *name);
/*@}*/

#endif /* CREATEIF_H */
