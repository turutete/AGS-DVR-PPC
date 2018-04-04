#ifndef TREESTOREIF_H

#include <glib-2.0/glib-object.h>
#include <ags-cf.h>

#define TREESTOREIF_H

#define TYPE_TREESTOREIF	 (treestore_if_get_type ())
#define TREESTOREIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_TREESTOREIF, TreestoreIf))
#define IS_TREESTOREIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_TREESTOREIF))
#define TREESTOREIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_TREESTOREIF, TreestoreIfIface))
                                                                                           
typedef struct _TreestoreIf	 TreestoreIf;
typedef struct _TreestoreIfIface TreestoreIfIface;

typedef void* TsRow; /* dependiente de implementación */

typedef struct _SelectData SelectData;

struct _SelectData {
  GArray*   array;
  ConfigIf* cfif;
  CfTable   rules;
};

struct _TreestoreIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  GArray*  (*select)           (TreestoreIf* self, ConfigIf *cfif, CfTable rules);
  void     (*new_iter)         (TreestoreIf* self, TsRow *row);
  void     (*free_iter)        (TreestoreIf* self, TsRow row);
  gboolean (*first)            (TreestoreIf* self, TsRow row);
  gboolean (*children)         (TreestoreIf* self, TsRow child_row, TsRow row);
  gboolean (*next)             (TreestoreIf* self, TsRow row);
  void     (*get_value)        (TreestoreIf* self, TsRow, gint col, GValue* v);
  void     (*set_value)        (TreestoreIf* self, TsRow, gint col, GValue* v);
  GType    (*get_column_type)  (TreestoreIf* self, gint col);
  
  void     (*append)           (TreestoreIf* self, TsRow row, TsRow parent_row);
  gint     (*get_column_number)(TreestoreIf* self, gchar* name);
  gboolean (*copy)             (TreestoreIf* self, TsRow src, TsRow dst);

  void     (*remove)           (TreestoreIf* self, TsRow row);
  /*
    (*remove) ();
    
    (*get_n_columns) ();
    (*parent) ();
    (*get_n_children) ();
    (*nth_children) ();    
  */

  /*< signals >*/
  /*
    "row-changed"
   */
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup treestoreif treestoreif
 * \ingroup interfaces
 */
/*@{*/
GType treestore_if_get_type (void);

inline GArray*  treestore_select            (TreestoreIf* self, ConfigIf *cfif, CfTable rules);
inline void     treestore_new_iter          (TreestoreIf* self, TsRow *row);
inline void     treestore_free_iter         (TreestoreIf* self, TsRow row);
inline gboolean treestore_first             (TreestoreIf* self, TsRow row);
inline gboolean treestore_children          (TreestoreIf* self, TsRow child_row, TsRow row);
inline gboolean treestore_next              (TreestoreIf* self, TsRow row);
inline void     treestore_get_value         (TreestoreIf* self, TsRow, gint col, GValue* v);
inline void     treestore_set_value         (TreestoreIf* self, TsRow, gint col, GValue* v);
inline GType    treestore_get_column_type   (TreestoreIf* self, gint col);

inline void     treestore_append            (TreestoreIf* self, TsRow row, TsRow parent_row);
inline gint     treestore_get_column_number (TreestoreIf* self, gchar* name);

inline void     treestore_remove            (TreestoreIf* self, TsRow row);

/* prototipos "callbacks" */
typedef gboolean (*TreestoreForeachFunc)    (TreestoreIf* self, TsRow row, gpointer data);

/* helpers */
inline gchar*   treestore_get_string        (TreestoreIf* self, TsRow row, gint col);
inline GValue*  treestore_get_gvalue        (TreestoreIf* self, TsRow row, gint col);
inline void     treestore_set_gvalue        (TreestoreIf* self, TsRow row, gint col, GValue* v);
inline void     treestore_foreach           (TreestoreIf* self, TreestoreForeachFunc func, gpointer user_data);
gboolean        copy                        (TreestoreIf* self, TsRow src, TsRow dst);
/*@}*/


#endif /* TREESTOREIF_H */
