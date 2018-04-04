#include <ags-valuetypes.h>

/**/
static void
value_init_long0 (GValue *value)
{
  value->data[0].v_long = 0;
}

static void
value_copy_long0 (const GValue *src_value,
		  GValue       *dest_value)
{
  dest_value->data[0].v_long = src_value->data[0].v_long;
}
static gchar*
value_collect_long (GValue      *value,
		    guint        n_collect_values,
		    GTypeCValue *collect_values,
		    guint        collect_flags)
{
  value->data[0].v_long = collect_values[0].v_long;
  
  return NULL;
}

static gchar*
value_lcopy_long (const GValue *value,
		  guint         n_collect_values,
		  GTypeCValue  *collect_values,
		  guint         collect_flags)
{
  glong *long_p = collect_values[0].v_pointer;
  
  if (!long_p)
    return g_strdup_printf ("value location for `%s' passed as NULL", G_VALUE_TYPE_NAME (value));
  
  *long_p = value->data[0].v_long;
  
  return NULL;
}

static gpointer
value_peek_pointer0 (const GValue *value)
{
  return value->data[0].v_pointer;
}

static void
value_init_string (GValue *value)
{
  value->data[0].v_pointer = NULL;
}

static void
value_free_string (GValue *value)
{
  if (!(value->data[1].v_uint & G_VALUE_NOCOPY_CONTENTS))
    g_free (value->data[0].v_pointer);
}

static void
value_copy_string (const GValue *src_value,
		   GValue	*dest_value)
{
  dest_value->data[0].v_pointer = g_strdup (src_value->data[0].v_pointer);
}

static gchar*
value_collect_string (GValue	  *value,
		      guint        n_collect_values,
		      GTypeCValue *collect_values,
		      guint        collect_flags)
{
  if (!collect_values[0].v_pointer)
    value->data[0].v_pointer = NULL;
  else if (collect_flags & G_VALUE_NOCOPY_CONTENTS)
    {
      value->data[0].v_pointer = collect_values[0].v_pointer;
      value->data[1].v_uint = G_VALUE_NOCOPY_CONTENTS;
    }
  else
    value->data[0].v_pointer = g_strdup (collect_values[0].v_pointer);
  
  return NULL;
}

static gchar*
value_lcopy_string (const GValue *value,
		    guint         n_collect_values,
		    GTypeCValue  *collect_values,
		    guint         collect_flags)
{
  gchar **string_p = collect_values[0].v_pointer;
  
  if (!string_p)
    return g_strdup_printf ("value location for `%s' passed as NULL", G_VALUE_TYPE_NAME (value));
  
  if (!value->data[0].v_pointer)
    *string_p = NULL;
  else if (collect_flags & G_VALUE_NOCOPY_CONTENTS)
    *string_p = value->data[0].v_pointer;
  else
    *string_p = g_strdup (value->data[0].v_pointer);
  
  return NULL;
}

/**/
void
ags_value_types_init(void)
{
  GTypeInfo info = {
    0,				/* class_size */
    NULL,			/* base_init */
    NULL,			/* base_destroy */
    NULL,			/* class_init */
    NULL,			/* class_destroy */
    NULL,			/* class_data */
    0,				/* instance_size */
    0,				/* n_preallocs */
    NULL,			/* instance_init */
    NULL,			/* value_table */
  };
  const GTypeFundamentalInfo finfo = { G_TYPE_FLAG_DERIVABLE, };
  GType type;

  /* AGS_TYPE_COUNTER32 */
  {
    static const GTypeValueTable value_table = {
      value_init_long0,		/* value_init */
      NULL,			/* value_free */
      value_copy_long0,		/* value_copy */
      NULL,                     /* value_peek_pointer */
      "l",			/* collect_format */
      value_collect_long,	/* collect_value */
      "p",			/* lcopy_format */
      value_lcopy_long,		/* lcopy_value */
    };
    info.value_table = &value_table;
    type = g_type_register_fundamental (AGS_TYPE_COUNTER32, "agscounter32", &info, &finfo, 0);
    g_assert (type == AGS_TYPE_COUNTER32);
  }
  /* AGS_TYPE_GAUGE32 */
  {
    static const GTypeValueTable value_table = {
      value_init_long0,		/* value_init */
      NULL,			/* value_free */
      value_copy_long0,		/* value_copy */
      NULL,                     /* value_peek_pointer */
      "l",			/* collect_format */
      value_collect_long,	/* collect_value */
      "p",			/* lcopy_format */
      value_lcopy_long,		/* lcopy_value */
    };
    info.value_table = &value_table;
    type = g_type_register_fundamental (AGS_TYPE_GAUGE32, "agsgauge32", &info, &finfo, 0);
    g_assert (type == AGS_TYPE_GAUGE32);
  }
  /* AGS_TYPE_TIMETICKS */
  {
    static const GTypeValueTable value_table = {
      value_init_long0,		/* value_init */
      NULL,			/* value_free */
      value_copy_long0,		/* value_copy */
      NULL,                     /* value_peek_pointer */
      "l",			/* collect_format */
      value_collect_long,	/* collect_value */
      "p",			/* lcopy_format */
      value_lcopy_long,		/* lcopy_value */
    };
    info.value_table = &value_table;
    type = g_type_register_fundamental (AGS_TYPE_TIMETICKS, "agstimeticks", &info, &finfo, 0);
    g_assert (type == AGS_TYPE_TIMETICKS);
  }
  /* AGS_TYPE_OBJID
   */
  {
    static const GTypeValueTable value_table = {
      value_init_string,	/* value_init */
      value_free_string,	/* value_free */
      value_copy_string,	/* value_copy */
      value_peek_pointer0,	/* value_peek_pointer */
      "p",			/* collect_format */
      value_collect_string,	/* collect_value */
      "p",			/* lcopy_format */
      value_lcopy_string,	/* lcopy_value */
    };
    info.value_table = &value_table;
    type = g_type_register_fundamental (AGS_TYPE_OBJID, "agsobjid", &info, &finfo, 0);
    g_assert (type == AGS_TYPE_OBJID);
  }
}

/**/
void
g_value_set_counter32 (GValue *value,
		  glong	  v_long)
{
  g_return_if_fail (G_VALUE_HOLDS_COUNTER32 (value));
  
  value->data[0].v_long = v_long;
}

glong
g_value_get_counter32 (const GValue *value)
{
  g_return_val_if_fail (G_VALUE_HOLDS_COUNTER32 (value), 0);
  
  return value->data[0].v_long;
}
void
g_value_set_gauge32 (GValue *value,
		     glong	  v_long)
{
  g_return_if_fail (G_VALUE_HOLDS_GAUGE32 (value));
  
  value->data[0].v_long = v_long;
}

glong
g_value_get_gauge32 (const GValue *value)
{
  g_return_val_if_fail (G_VALUE_HOLDS_GAUGE32 (value), 0);
  
  return value->data[0].v_long;
}
void
g_value_set_timeticks (GValue *value,
		       glong	  v_long)
{
  g_return_if_fail (G_VALUE_HOLDS_TIMETICKS (value));
  
  value->data[0].v_long = v_long;
}

glong
g_value_get_timeticks (const GValue *value)
{
  g_return_val_if_fail (G_VALUE_HOLDS_TIMETICKS (value), 0);
  
  return value->data[0].v_long;
}

void
g_value_set_objid (GValue	*value,
		    const gchar *v_objid)
{
  g_return_if_fail (G_VALUE_HOLDS_OBJID (value));
  
  if (value->data[1].v_uint & G_VALUE_NOCOPY_CONTENTS)
    value->data[1].v_uint = 0;
  else
    g_free (value->data[0].v_pointer);
  value->data[0].v_pointer = g_strdup (v_objid);
}

G_CONST_RETURN gchar*
g_value_get_objid (const GValue *value)
{
  g_return_val_if_fail (G_VALUE_HOLDS_OBJID (value), NULL);
  
  return value->data[0].v_pointer;
}

glong g_value_compare (GValue *a, GValue *b)
{
  glong res=1; /* por defecto, no iguales */

  /* si los 2 nulos, devolvemos igualdad */
  if(a==NULL && b==NULL)
    return 0;

  g_return_val_if_fail (G_IS_VALUE (a), res);
  g_return_val_if_fail (G_IS_VALUE (b), res);

  GType type = G_VALUE_TYPE(a);
  
  if( G_VALUE_TYPE(b)==type ) { /* Mismo tipo? */
    switch(type) {
    case G_TYPE_INT:
    case AGS_TYPE_COUNTER32:
    case AGS_TYPE_GAUGE32:
    case AGS_TYPE_TIMETICKS:
      /* comparar valor */
      res = (a->data[0].v_long) - (b->data[0].v_long);
      break;
    case G_TYPE_STRING:
    case AGS_TYPE_OBJID:
      /* comparar cadena */
      if(a->data[0].v_pointer && b->data[0].v_pointer)
	res = strcmp(a->data[0].v_pointer, b->data[0].v_pointer);
      break;      
    default:
      break;
    }
  }
  
  return res;
}
