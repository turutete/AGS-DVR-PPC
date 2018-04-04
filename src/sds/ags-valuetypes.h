#ifndef __AGS_VALUE_H__
#define __AGS_VALUE_H__

#include <glib-object.h>
#include <gobject/gvaluecollector.h>
#include <ags-type.h>

G_BEGIN_DECLS

/**/
#define G_VALUE_HOLDS_COUNTER32(value)	 (G_TYPE_CHECK_VALUE_TYPE ((value), AGS_TYPE_COUNTER32))
#define G_VALUE_HOLDS_GAUGE32(value)	 (G_TYPE_CHECK_VALUE_TYPE ((value), AGS_TYPE_GAUGE32))
#define G_VALUE_HOLDS_TIMETICKS(value)	 (G_TYPE_CHECK_VALUE_TYPE ((value), AGS_TYPE_TIMETICKS))
#define G_VALUE_HOLDS_OBJID(value)	 (G_TYPE_CHECK_VALUE_TYPE ((value), AGS_TYPE_OBJID))

/**/
void                  g_value_set_counter32 (GValue *value, glong v_long);
glong                 g_value_get_counter32 (const GValue *value);
void                  g_value_set_gauge32   (GValue *value, glong v_long);
glong                 g_value_get_gauge32   (const GValue *value);
void                  g_value_set_timeticks (GValue *value, glong v_long);
glong                 g_value_get_timeticks (const GValue *value);
void                  g_value_set_objid     (GValue *value, const gchar *v_string);
G_CONST_RETURN gchar* g_value_get_objid     (const GValue *value);

G_END_DECLS

#endif /*  __AGS_VALUE_H__ */
