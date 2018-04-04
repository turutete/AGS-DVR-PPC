#ifndef ACCESSXIF_H

#define ACCESSXIF_H

#define TYPE_ACCESSXIF	 (accessx_if_get_type ())
#define ACCESSXIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_ACCESSXIF, AccessxIf))
#define IS_ACCESSXIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_ACCESSXIF))
#define ACCESSXIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_ACCESSXIF, AccessxIfIface))
                                                                                           
typedef struct _AccessxIf	AccessxIf;
typedef struct _AccessxIfIface AccessxIfIface;

struct _AccessxIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  GValue *(*getnext)(AccessxIf *self, char *k);
  char *(*getnextkey)(AccessxIf *self, char *k);
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup accessxif accessxif
 * \ingroup interfaces
 */
/*@{*/
GType accessx_if_get_type(void);

inline GValue* accessx_getnext(AccessxIf *self, char *k);
inline char* accessx_getnextkey(AccessxIf *self, char *k);
/*@}*/

#endif  /* ACCESSXIF_H */
