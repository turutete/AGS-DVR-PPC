#ifndef QUERYIF_H

#define QUERYIF_H

#define TYPE_QUERYIF	 (query_if_get_type ())
#define QUERYIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_QUERYIF, QueryIf))
#define IS_QUERYIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_QUERYIF))
#define QUERYIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_QUERYIF, QueryIfIface))
                                                                                           
typedef struct _QueryIf	QueryIf;
typedef struct _QueryIfIface QueryIfIface;

typedef int (*QueryRowCallback) (GArray *fields, gpointer user_data);

struct _QueryIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  int (*exec)(QueryIf *self, char *qstr, int qlen, char ***col_names, QueryRowCallback cb, gpointer user_data);
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup queryif queryif
 * \ingroup interfaces
 */
/*@{*/
GType query_if_get_type(void);

inline int query_exec(QueryIf *self, char *qstr, int qlen, char ***col_names, QueryRowCallback cb, gpointer user_data);
/*@}*/

#endif /* QUERYIF_H */
