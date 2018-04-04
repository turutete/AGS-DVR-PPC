#ifndef LIMITSIF_H

#define LIMITSIF_H 

#define TYPE_LIMITSIF	 (limits_if_get_type ())
#define LIMITSIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_LIMITSIF, LimitsIf))
#define IS_LIMITSIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_LIMITSIF))
#define LIMITSIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_LIMITSIF, LimitsIfIface))
                                                                                           
typedef struct _LimitsIf	LimitsIf;
typedef struct _LimitsIfIface LimitsIfIface;

struct _LimitsIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  gboolean (*add_limit)(LimitsIf *self, GParamSpec *limit);
  gboolean (*check_limit)(LimitsIf *self, char *k, GValue *v);
  gboolean (*set_limit)(LimitsIf *self, char *k, char *name);
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup limitsif limitsif
 * \ingroup interfaces
 */
/*@{*/
GType limits_if_get_type(void);

inline gboolean limits_add(LimitsIf *self, GParamSpec *limit);
inline gboolean limits_check(LimitsIf *self, char *k, GValue *v);
inline gboolean limits_set(LimitsIf *self, char *k, char *name);
/*@}*/

#endif /* LIMITSIF_H */
