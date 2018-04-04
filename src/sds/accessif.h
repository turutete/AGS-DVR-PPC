#ifndef ACCESSIF_H

#define ACCESSIF_H

#define TYPE_ACCESSIF	 (access_if_get_type ())
#define ACCESSIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_ACCESSIF, AccessIf))
#define IS_ACCESSIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_ACCESSIF))
#define ACCESSIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_ACCESSIF, AccessIfIface))
                                                                                           
typedef struct _AccessIf	AccessIf;
typedef struct _AccessIfIface AccessIfIface;

struct _AccessIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  GValue *(*get)(AccessIf *self, char *k);
  GString *(*get_string)(AccessIf *self, char *k);
  int (*set)(AccessIf *self, char *k, GValue *v);
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup accessif accessif
 * \ingroup interfaces
 */
/*@{*/
GType access_if_get_type(void);

inline GValue* access_get(AccessIf *self, char *k);
inline GString* access_get_string(AccessIf *self, char *k);
inline int access_set(AccessIf *self, char *k, GValue *v);
/*@}*/

#endif /* ACCESSIF_H */
