#include <glib-2.0/glib-object.h>
#include <ags-valuetypes.h>
#include <string.h>

/**/
static void
value_transform_memcpy_data0 (const GValue *src_value,
                              GValue       *dest_value)
{
  memcpy (&dest_value->data[0], &src_value->data[0], sizeof (src_value->data[0]));
}
#define value_transform_counter32_counter32 value_transform_memcpy_data0
#define value_transform_gauge32_gauge32     value_transform_memcpy_data0
#define value_transform_timeticks_timeticks value_transform_memcpy_data0

/**/
#define DEFINE_SPRINTF(func_name, from_member, format)                      \
static void                                                                 \
value_transform_##func_name (const GValue *src_value,                       \
                             GValue       *dest_value)                      \
{                                                                           \
  dest_value->data[0].v_pointer = g_strdup_printf ((format),                \
						   src_value->data[0].from_member);             \
} extern void glib_dummy_decl (void)
DEFINE_SPRINTF (long_string,    v_long,   "%ld");

/**/
static void
value_transform_timeticks_string(const GValue *src_value,
				 GValue       *dest_value)
{
  int dd,hh,mm,ss,cc;
  gulong tt = src_value->data[0].v_long;

  cc = tt % 100;
  tt = tt / 100;
  dd = tt / 86400;
  tt = tt % 86400;
  hh = tt / 3600;
  tt = tt % 3600;
  mm = tt / 60;
  ss = tt % 60;

  dest_value->data[0].v_pointer = g_strdup_printf ("(%d) %d:%02d:%02d.%02d",dd, hh,mm,ss,cc);
}

static void
value_transform_string_string (const GValue *src_value,
                               GValue       *dest_value)
{
  dest_value->data[0].v_pointer = g_strdup (src_value->data[0].v_pointer);
}

static void
value_transform_string_int(const GValue *src_value,
			   GValue       *dest_value)
{
  dest_value->data[0].v_int = atoi(src_value->data[0].v_pointer);
}

/**/
void
ags_value_transforms_init (void) 
{
  g_value_register_transform_func (AGS_TYPE_COUNTER32,  G_TYPE_STRING, value_transform_long_string);
  g_value_register_transform_func (AGS_TYPE_GAUGE32,    G_TYPE_STRING, value_transform_long_string);
  g_value_register_transform_func (AGS_TYPE_TIMETICKS,  G_TYPE_STRING, value_transform_timeticks_string);
  g_value_register_transform_func (AGS_TYPE_OBJID,      G_TYPE_STRING, value_transform_string_string);

  g_value_register_transform_func (G_TYPE_STRING,       G_TYPE_INT,    value_transform_string_int);
}
