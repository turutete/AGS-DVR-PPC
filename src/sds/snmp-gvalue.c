/**
   \file snmp-gvalue.c
   \todo
   - Implementar soporte para mas conversiones en el marshaller.
 */ 
#include <glib-2.0/glib-object.h>
#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include "snmp-gvalue.h"
#include <ags-valuetypes.h>

#undef  G_LOG_DOMAIN
#define G_LOG_DOMAIN "snmp-gvalue"

#ifdef AGS_DEBUG
#undef  ags_debug
#define ags_debug(level, format,...)  if(level<AGS_DEBUG) g_log(G_LOG_DOMAIN, G_LOG_LEVEL_DEBUG, ("%s: " format), __func__, ##__VA_ARGS__)
#else
#define ags_debug(...) 
#endif

gboolean snmp_gvalue_demarshall(struct variable_list  *vb, GValue **v) {
  gboolean can_convert = TRUE;
  char snmp_type=vb->type;

  switch(snmp_type) {
  case ASN_OCTET_STR:
    *v=g_new0(GValue, 1);
    g_value_init(*v, G_TYPE_STRING);
    {
      GString *aux=g_string_new_len(vb->val.string, vb->val_len);
      aux=g_string_append_c(aux, '\0');
      g_value_set_string(*v, aux->str);
      g_string_free(aux, TRUE);
    }
    break;
  case ASN_OBJECT_ID:
    *v=g_new0(GValue, 1);
    g_value_init(*v, AGS_TYPE_OBJID);
    {
      GString *gs_oid=g_string_sized_new(128);
      g_string_truncate(gs_oid, 0);
      oid *node_oid=vb->val.objid;
      size_t node_oid_len=vb->val_len / sizeof(oid); /* tamaño en bytes! */
      int i;
      for(i=0;i<node_oid_len;i++) {
	g_string_append_printf(gs_oid, ".%ld", *(node_oid+i));
      }
      gs_oid=g_string_append_c(gs_oid, '\0');
      g_value_set_objid(*v, gs_oid->str);
      g_string_free(gs_oid, TRUE);
    }
    gchar *aux=g_strdup_value_contents(*v);
    ags_debug(1, "OBJID=%s", aux);
    free(aux);
    break;
  case ASN_INTEGER:
    *v=g_new0(GValue, 1);
    g_value_init(*v, G_TYPE_INT);
    g_value_set_int(*v, *vb->val.integer);
    break;
  case ASN_COUNTER:
    *v=g_new0(GValue, 1);
    g_value_init(*v, AGS_TYPE_COUNTER32);
    g_value_set_counter32(*v, *vb->val.integer);
    break;
  case ASN_GAUGE:
    *v=g_new0(GValue, 1);
    g_value_init(*v, AGS_TYPE_GAUGE32);
    g_value_set_gauge32(*v, *vb->val.integer);
    break;
  case ASN_TIMETICKS:
    *v=g_new0(GValue, 1);
    g_value_init(*v, AGS_TYPE_TIMETICKS);
    g_value_set_timeticks(*v, *vb->val.integer);
    break;
  case ASN_NULL:
    *v=NULL;
    break;
  default:
    can_convert = FALSE;
    *v=NULL;
    break;
  }
  if(can_convert) {
  }

  return can_convert;
}

gboolean snmp_gvalue_marshall(struct snmp_gvalue **snmp_gv, GValue *v) {
  gboolean can_convert = TRUE;
  char snmp_type;
  gpointer snmp_data;
  guint snmp_len;

  *snmp_gv=NULL;

  if(v) {
    switch(G_VALUE_TYPE(v)) {
    case G_TYPE_STRING:
      snmp_type=ASN_OCTET_STR; 
      /*     snmp_type='s'; */
      snmp_data=g_value_peek_pointer(v);
      snmp_len=strlen(snmp_data);
      break;
    case AGS_TYPE_OBJID:
      snmp_type=ASN_OBJECT_ID; 
      /*     snmp_type='s'; */
      oid node_oid[MAX_OID_LEN];
      size_t node_oid_len=MAX_OID_LEN;
      read_objid(g_value_get_objid(v), node_oid, &node_oid_len);
      snmp_data=node_oid;
      snmp_len=node_oid_len * sizeof(oid); /* tamaño en bytes! */
      break;
    case G_TYPE_INT:
      snmp_type=ASN_INTEGER; 
      /*     snmp_type='i'; */
      snmp_data=&(v->data[0]);
      snmp_len=sizeof(int);
      break;
    case AGS_TYPE_COUNTER32:
      snmp_type=ASN_COUNTER;
      snmp_data=&(v->data[0]);
      snmp_len=sizeof(int);
      break;
    case AGS_TYPE_GAUGE32:
      snmp_type=ASN_GAUGE;
      snmp_data=&(v->data[0]);
      snmp_len=sizeof(int);
      break;
    case AGS_TYPE_TIMETICKS:
      snmp_type=ASN_TIMETICKS;
      snmp_data=&(v->data[0]);
      snmp_len=sizeof(int);
    break;
    default:
    can_convert = FALSE;
    break;
    }
  } else {
    snmp_type=ASN_NULL;
    snmp_data=NULL;
    snmp_len=0;
  }

  if(can_convert) {
    (*snmp_gv)=g_new(struct snmp_gvalue, 1);
    (*snmp_gv)->type=snmp_type;
    (*snmp_gv)->data=snmp_data;
    (*snmp_gv)->len=snmp_len;
  }

  return can_convert;
}

