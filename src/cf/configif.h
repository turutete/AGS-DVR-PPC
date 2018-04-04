#ifndef CONFIGIF_H

#define CONFIGIF_H

#define TYPE_CONFIGIF	 (config_if_get_type ())
#define CONFIGIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_CONFIGIF, ConfigIf))
#define IS_CONFIGIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_CONFIGIF))
#define CONFIGIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_CONFIGIF, ConfigIfIface))
                                                                                           
typedef struct _ConfigIf	ConfigIf;
typedef struct _ConfigIfIface ConfigIfIface;

typedef void* CfTable; /* dependiente de implementación */

struct _ConfigIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  CfTable (*add_table)(ConfigIf *self, CfTable cft, const char *k);
  CfTable (*get_table)(ConfigIf *self, CfTable cft, const char *k);
  GValue *(*get)(ConfigIf *self, CfTable cft, const char *k);
  int (*set)(ConfigIf *self, CfTable cft, const char *k, GValue *v);
  char *(*getnextkey)(ConfigIf *self, CfTable cft, const char *k);
  gboolean (*check_table)(ConfigIf *self, CfTable cft);
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup configif configif
 * \ingroup interfaces
 */
/*@{*/
GType config_if_get_type (void);

inline CfTable  config_add_table(ConfigIf *self, CfTable cft, const char *k);
inline CfTable  config_get_table(ConfigIf *self, CfTable cft, const char *k);
inline GValue*  config_get(ConfigIf *self, CfTable cft, const char *k);
inline int      config_set(ConfigIf *self, CfTable cft, const char *k, GValue *v);
inline gchar*   config_getnextkey(ConfigIf *self, CfTable cft, const char *k);
inline gboolean config_check_table(ConfigIf *self, CfTable cft);

/** helpers */
inline gchar*   config_get_string(ConfigIf *self, CfTable cft, const char *k);
inline int      config_set_string(ConfigIf *self, CfTable cft, const char *k, gchar *s);
inline gint     config_get_int(ConfigIf *self, CfTable cft, const char *k);
inline int      config_set_int(ConfigIf *self, CfTable cft, const char *k, int i);
inline gpointer config_get_pointer(ConfigIf *self, CfTable cft, const char *k);
inline int      config_set_pointer(ConfigIf *self, CfTable cft, const char *k, gpointer p);
inline GObject* config_get_object(ConfigIf *self, CfTable cft, const char *k);
inline int      config_set_object(ConfigIf *self, CfTable cft, const char *k, GObject* o);
inline gboolean config_get_boolean(ConfigIf *self, CfTable cft, const char *k);
inline int      config_set_boolean(ConfigIf *self, CfTable cft, const char *k, gboolean p);
/*@}*/


#endif /* CONFIGIF_H */
