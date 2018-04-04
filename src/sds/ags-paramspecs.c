#include <ags-paramspecs.h>

/**/
static void
param_long_init (GParamSpec *pspec)
{
  GParamSpecLong *lspec = G_PARAM_SPEC_LONG (pspec);
  
  lspec->minimum = 0x7fffffff;
  lspec->maximum = 0x80000000;
  lspec->default_value = 0;
}

static void
param_long_set_default (GParamSpec *pspec,
			GValue     *value)
{
  value->data[0].v_long = G_PARAM_SPEC_LONG (pspec)->default_value;
}

static gboolean
param_long_validate (GParamSpec *pspec,
		     GValue     *value)
{
  GParamSpecLong *lspec = G_PARAM_SPEC_LONG (pspec);
  glong oval = value->data[0].v_long;
  
  value->data[0].v_long = CLAMP (value->data[0].v_long, lspec->minimum, lspec->maximum);
  
  return value->data[0].v_long != oval;
}

static gint
param_long_values_cmp (GParamSpec   *pspec,
		       const GValue *value1,
		       const GValue *value2)
{
  if (value1->data[0].v_long < value2->data[0].v_long)
    return -1;
  else
    return value1->data[0].v_long > value2->data[0].v_long;
}

static void
param_string_init (GParamSpec *pspec)
{
  GParamSpecString *sspec = G_PARAM_SPEC_STRING (pspec);
  
  sspec->default_value = NULL;
  sspec->cset_first = NULL;
  sspec->cset_nth = NULL;
  sspec->substitutor = '_';
  sspec->null_fold_if_empty = FALSE;
  sspec->ensure_non_null = FALSE;
}

static void
param_string_finalize (GParamSpec *pspec)
{
  GParamSpecString *sspec = G_PARAM_SPEC_STRING (pspec);
  GParamSpecClass *parent_class = g_type_class_peek (g_type_parent (G_TYPE_PARAM_STRING));
  
  g_free (sspec->default_value);
  g_free (sspec->cset_first);
  g_free (sspec->cset_nth);
  sspec->default_value = NULL;
  sspec->cset_first = NULL;
  sspec->cset_nth = NULL;
  
  parent_class->finalize (pspec);
}

static void
param_string_set_default (GParamSpec *pspec,
			  GValue     *value)
{
  value->data[0].v_pointer = g_strdup (G_PARAM_SPEC_STRING (pspec)->default_value);
}

static gboolean
param_string_validate (GParamSpec *pspec,
		       GValue     *value)
{
  GParamSpecString *sspec = G_PARAM_SPEC_STRING (pspec);
  gchar *string = value->data[0].v_pointer;
  guint changed = 0;
  
  if (string && string[0])
    {
      gchar *s;
      
      if (sspec->cset_first && !strchr (sspec->cset_first, string[0]))
	{
	  string[0] = sspec->substitutor;
	  changed++;
	}
      if (sspec->cset_nth)
	for (s = string + 1; *s; s++)
	  if (!strchr (sspec->cset_nth, *s))
	    {
	      *s = sspec->substitutor;
	      changed++;
	    }
    }
  if (sspec->null_fold_if_empty && string && string[0] == 0)
    {
      g_free (value->data[0].v_pointer);
      value->data[0].v_pointer = NULL;
      changed++;
      string = value->data[0].v_pointer;
    }
  if (sspec->ensure_non_null && !string)
    {
      value->data[0].v_pointer = g_strdup ("");
      changed++;
      string = value->data[0].v_pointer;
    }
  
  return changed;
}

static gint
param_string_values_cmp (GParamSpec   *pspec,
			 const GValue *value1,
			 const GValue *value2)
{
  if (!value1->data[0].v_pointer)
    return value2->data[0].v_pointer != NULL ? -1 : 0;
  else if (!value2->data[0].v_pointer)
    return value1->data[0].v_pointer != NULL;
  else
    return strcmp (value1->data[0].v_pointer, value2->data[0].v_pointer);
}


/**/
GType *ags_param_spec_types = NULL;

void
ags_param_spec_type_init(void)
{
  const guint n_types = 4;
  GType type, *spec_types, *spec_types_bound;
  
  ags_param_spec_types = g_new0 (GType, n_types);
  spec_types = ags_param_spec_types;
  spec_types_bound = ags_param_spec_types + n_types;
  
  /* AGS_TYPE_PARAM_COUNTER32
   */
  {
    static const GParamSpecTypeInfo pspec_info = {
      sizeof (AGSParamSpecCounter32),  /* instance_size */
      16,                       /* n_preallocs */
      param_long_init,          /* instance_init */
      AGS_TYPE_COUNTER32,		/* value_type */
      NULL,			/* finalize */
      param_long_set_default,	/* value_set_default */
      param_long_validate,	/* value_validate */
      param_long_values_cmp,	/* values_cmp */
    };
    type = g_param_type_register_static ("AGSParamCounter32", &pspec_info);
    *spec_types++ = type;
    g_assert (type == AGS_TYPE_PARAM_COUNTER32);
  }
  /* AGS_TYPE_PARAM_GAUGE32
   */
  {
    static const GParamSpecTypeInfo pspec_info = {
      sizeof (AGSParamSpecGauge32),  /* instance_size */
      16,                       /* n_preallocs */
      param_long_init,          /* instance_init */
      AGS_TYPE_GAUGE32,		/* value_type */
      NULL,			/* finalize */
      param_long_set_default,	/* value_set_default */
      param_long_validate,	/* value_validate */
      param_long_values_cmp,	/* values_cmp */
    };
    type = g_param_type_register_static ("AGSParamGauge32", &pspec_info);
    *spec_types++ = type;
    g_assert (type == AGS_TYPE_PARAM_GAUGE32);
  }
  /* AGS_TYPE_PARAM_TIMETICKS
   */
  {
    static const GParamSpecTypeInfo pspec_info = {
      sizeof (AGSParamSpecTimeticks),  /* instance_size */
      16,                       /* n_preallocs */
      param_long_init,          /* instance_init */
      AGS_TYPE_TIMETICKS,		/* value_type */
      NULL,			/* finalize */
      param_long_set_default,	/* value_set_default */
      param_long_validate,	/* value_validate */
      param_long_values_cmp,	/* values_cmp */
    };
    type = g_param_type_register_static ("AGSParamTimeticks", &pspec_info);
    *spec_types++ = type;
    g_assert (type == AGS_TYPE_PARAM_TIMETICKS);
  }
  /* AGS_TYPE_PARAM_OBJID
   */
  {
    static const GParamSpecTypeInfo pspec_info = {
      sizeof (AGSParamSpecObjid),	/* instance_size */
      16,				/* n_preallocs */
      param_string_init,		/* instance_init */
      AGS_TYPE_OBJID,			/* value_type */
      param_string_finalize,		/* finalize */
      param_string_set_default,		/* value_set_default */
      param_string_validate,		/* value_validate */
      param_string_values_cmp,		/* values_cmp */
    };
    type = g_param_type_register_static ("AGSParamObjid", &pspec_info);
    *spec_types++ = type;
    g_assert (type == AGS_TYPE_PARAM_OBJID);
  }
}

/**/
GParamSpec*
ags_param_spec_counter32 (const gchar *name,
			  const gchar *nick,
			  const gchar *blurb,
			  glong	minimum,
			  glong	maximum,
			  glong	default_value,
			  GParamFlags	flags)
{
  AGSParamSpecCounter32 *lspec;

  g_return_val_if_fail (default_value >= minimum && default_value <= maximum, NULL);

  lspec = g_param_spec_internal (AGS_TYPE_PARAM_COUNTER32,
				 name,
				 nick,
				 blurb,
				 flags);
  
  lspec->minimum = minimum;
  lspec->maximum = maximum;
  lspec->default_value = default_value;
  
  return G_PARAM_SPEC (lspec);
}

GParamSpec*
ags_param_spec_gauge32 (const gchar *name,
			const gchar *nick,
			const gchar *blurb,
			glong	minimum,
			glong	maximum,
			glong	default_value,
			GParamFlags	flags)
{
  AGSParamSpecGauge32 *lspec;

  g_return_val_if_fail (default_value >= minimum && default_value <= maximum, NULL);

  lspec = g_param_spec_internal (AGS_TYPE_PARAM_GAUGE32,
				 name,
				 nick,
				 blurb,
				 flags);
  
  lspec->minimum = minimum;
  lspec->maximum = maximum;
  lspec->default_value = default_value;
  
  return G_PARAM_SPEC (lspec);
}

GParamSpec*
ags_param_spec_timeticks (const gchar *name,
			const gchar *nick,
			const gchar *blurb,
			glong	minimum,
			glong	maximum,
			glong	default_value,
			GParamFlags	flags)
{
  AGSParamSpecTimeticks *lspec;

  g_return_val_if_fail (default_value >= minimum && default_value <= maximum, NULL);

  lspec = g_param_spec_internal (AGS_TYPE_PARAM_TIMETICKS,
				 name,
				 nick,
				 blurb,
				 flags);
  
  lspec->minimum = minimum;
  lspec->maximum = maximum;
  lspec->default_value = default_value;
  
  return G_PARAM_SPEC (lspec);
}

GParamSpec*
ags_param_spec_objid (const gchar *name,
		      const gchar *nick,
		      const gchar *blurb,
		      const gchar *default_value,
		      GParamFlags  flags)
{
  AGSParamSpecObjid *sspec = g_param_spec_internal (AGS_TYPE_PARAM_OBJID,
						    name,
						    nick,
						    blurb,
						    flags);
  g_free (sspec->default_value);
  sspec->default_value = g_strdup (default_value);
  
  return G_PARAM_SPEC (sspec);
}
