#include <glib-2.0/glib.h>
#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>

struct snmp_gvalue {
  gchar type;
  gpointer data;  
  guint len;
};

gboolean snmp_gvalue_demarshall(struct variable_list *vb, GValue **v);
gboolean snmp_gvalue_marshall(struct snmp_gvalue **snmp_gv, GValue *v);
