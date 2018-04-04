/**
   \file treestoreif.c 
   Interface treestore.
   \todo
   - getnext (para tablas)
 */

#include <glib.h>
#include <glib-object.h>
#include "treestoreif.h"

GType 
treestore_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (TreestoreIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "TreestoreIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline
GArray*
treestore_select(TreestoreIf *self, ConfigIf *cfif, CfTable rules) {
  return TREESTOREIF_GET_IFACE(self)->select(self, cfif, rules);
}

inline
void
treestore_new_iter(TreestoreIf *self, TsRow *row) {
  return TREESTOREIF_GET_IFACE(self)->new_iter(self, row);
}
inline
void
treestore_free_iter(TreestoreIf *self, TsRow row) {
  return TREESTOREIF_GET_IFACE(self)->free_iter(self, row);
}
inline
gboolean
treestore_first(TreestoreIf *self, TsRow row) {
  return TREESTOREIF_GET_IFACE(self)->first(self, row);
}
inline
gboolean
treestore_children(TreestoreIf *self, TsRow child_row, TsRow row) {
  return TREESTOREIF_GET_IFACE(self)->children(self, child_row, row);
}
inline
gboolean
treestore_next(TreestoreIf *self, TsRow row) {
  return TREESTOREIF_GET_IFACE(self)->next(self, row);
}
inline
void
treestore_get_value(TreestoreIf *self, TsRow row, gint col, GValue* v) {
  return TREESTOREIF_GET_IFACE(self)->get_value(self, row, col, v);
}
inline
void
treestore_set_value(TreestoreIf *self, TsRow row, gint col, GValue* v) {
  return TREESTOREIF_GET_IFACE(self)->set_value(self, row, col, v);
}
inline
GType
treestore_get_column_type(TreestoreIf *self, gint col) {
  return TREESTOREIF_GET_IFACE(self)->get_column_type(self, col);
}
inline
void
treestore_append(TreestoreIf* self, TsRow row, TsRow parent_row) {
  return TREESTOREIF_GET_IFACE(self)->append(self, row, parent_row);
}
inline
gint
treestore_get_column_number(TreestoreIf* self, gchar* name) {
  return TREESTOREIF_GET_IFACE(self)->get_column_number(self, name);
}
inline
gboolean
treestore_copy(TreestoreIf* self, TsRow src, TsRow dst) {
  return TREESTOREIF_GET_IFACE(self)->copy(self, src, dst);
}
inline
void
treestore_remove(TreestoreIf* self, TsRow row) {
  return TREESTOREIF_GET_IFACE(self)->remove(self, row);
}

/* helpers */
inline
gchar*
treestore_get_string(TreestoreIf* self, TsRow row, gint col) {
  GValue v={0,};
  gchar* ret=NULL;

  treestore_get_value(self, row, col, &v);
  if(G_VALUE_HOLDS_STRING(&v))
    ret=g_value_get_string(&v);

  return ret;
}
inline
GValue*
treestore_get_gvalue(TreestoreIf* self, TsRow row, gint col) {
  GValue  v={0,};
  GValue* ret=NULL;

  treestore_get_value(self, row, col, &v);
  if(G_VALUE_HOLDS_BOXED(&v))
    ret=g_value_get_boxed(&v);

  return ret;
}
inline
void
treestore_set_gvalue(TreestoreIf* self, TsRow row, gint col, GValue* v) {
  GValue box={0,};
  g_value_init(&box, G_TYPE_VALUE);
  g_value_set_static_boxed(&box, v);
  treestore_set_value(self, row, col, &box);
}
/* foreach (Depth-first) */
static
gboolean
_treestore_foreach_child(TreestoreIf* self, TreestoreForeachFunc func, gpointer user_data, TsRow row) {
  if(!row) /* XXX*/
    return FALSE;

  func(self, row, user_data);
  
  TsRow child_row;
  treestore_new_iter(self, &child_row);
  if(treestore_children(self, child_row, row)) {
    if(_treestore_foreach_child(self, func, user_data, child_row)) {
      treestore_free_iter(self, child_row);
      return TRUE;
    }
  }
  /* clean */
  treestore_free_iter(self, child_row);

  while(treestore_next(self, row))
    return _treestore_foreach_child(self, func, user_data, row);
  
  return FALSE;
}
inline
void
treestore_foreach(TreestoreIf* self, TreestoreForeachFunc func, gpointer user_data) {
  TsRow row;
  treestore_new_iter(self, &row);
  if(!treestore_first(self, row))
    return; /* XXX warning, treestore vacio */

  _treestore_foreach_child(self, func, user_data, row);

  treestore_free_iter(self, row);
}
