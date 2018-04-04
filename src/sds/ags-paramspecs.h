#ifndef __AGS_PARAMSPECS_H__

#define __AGS_PARAMSPECS_H__

#include <glib-object.h>
#include <ags-valuetypes.h>

G_BEGIN_DECLS

/**/
#define	AGS_TYPE_PARAM_COUNTER32		  (ags_param_spec_types[0])
#define AGS_IS_PARAM_SPEC_COUNTER32(pspec)        (G_TYPE_CHECK_INSTANCE_TYPE ((pspec), AGS_TYPE_PARAM_COUNTER32))
#define AGS_PARAM_SPEC_COUNTER32(pspec)           (G_TYPE_CHECK_INSTANCE_CAST ((pspec), AGS_TYPE_PARAM_COUNTER32, AGSParamSpecCounter32))
#define	AGS_TYPE_PARAM_GAUGE32		          (ags_param_spec_types[1])
#define AGS_IS_PARAM_SPEC_GAUGE32(pspec)          (G_TYPE_CHECK_INSTANCE_TYPE ((pspec), AGS_TYPE_PARAM_GAUGE32))
#define AGS_PARAM_SPEC_GAUGE32(pspec)             (G_TYPE_CHECK_INSTANCE_CAST ((pspec), AGS_TYPE_PARAM_GAUGE32, AGSParamSpecGauge32))
#define	AGS_TYPE_PARAM_TIMETICKS                  (ags_param_spec_types[2])
#define AGS_IS_PARAM_SPEC_TIMETICKS(pspec)        (G_TYPE_CHECK_INSTANCE_TYPE ((pspec), AGS_TYPE_PARAM_TIMETICKS))
#define AGS_PARAM_SPEC_TIMETICKS(pspec)           (G_TYPE_CHECK_INSTANCE_CAST ((pspec), AGS_TYPE_PARAM_TIMETICKS, AGSParamSpecTimeticks))
#define	AGS_TYPE_PARAM_OBJID                      (ags_param_spec_types[3])
#define AGS_IS_PARAM_SPEC_OBJID(pspec)            (G_TYPE_CHECK_INSTANCE_TYPE ((pspec), AGS_TYPE_PARAM_OBJID))
#define AGS_PARAM_SPEC_OBJID(pspec)               (G_TYPE_CHECK_INSTANCE_CAST ((pspec), AGS_TYPE_PARAM_OBJID, AGSParamSpecObjid))

/**/
typedef struct _AGSParamSpecCounter32 AGSParamSpecCounter32;
typedef struct _AGSParamSpecGauge32   AGSParamSpecGauge32;
typedef struct _AGSParamSpecTimeticks AGSParamSpecTimeticks;
typedef struct _AGSParamSpecObjid     AGSParamSpecObjid;

struct _AGSParamSpecCounter32 
{
  GParamSpec    parent_instance;
  glong         minimum;
  glong         maximum;
  glong         default_value;
};
struct _AGSParamSpecGauge32 
{
  GParamSpec    parent_instance;
  glong         minimum;
  glong         maximum;
  glong         default_value;
};
struct _AGSParamSpecTimeticks
{
  GParamSpec    parent_instance;
  glong         minimum;
  glong         maximum;
  glong         default_value;
};
struct _AGSParamSpecObjid
{
  GParamSpec    parent_instance;
  
  gchar        *default_value;
  gchar        *cset_first;
  gchar        *cset_nth;
  gchar         substitutor;
  guint         null_fold_if_empty : 1;
  guint         ensure_non_null : 1;
};

/**/
GParamSpec*	ags_param_spec_counter32	 (const gchar	 *name,
						  const gchar	 *nick,
						  const gchar	 *blurb,
						  glong		  minimum,
						  glong		  maximum,
						  glong		  default_value,
						  GParamFlags	  flags);
GParamSpec*	ags_param_spec_gauge32	         (const gchar	 *name,
						  const gchar	 *nick,
						  const gchar	 *blurb,
						  glong		  minimum,
						  glong		  maximum,
						  glong		  default_value,
						  GParamFlags	  flags);
GParamSpec*	ags_param_spec_timeticks         (const gchar	 *name,
						  const gchar	 *nick,
						  const gchar	 *blurb,
						  glong		  minimum,
						  glong		  maximum,
						  glong		  default_value,
						  GParamFlags	  flags);
GParamSpec*	ags_param_spec_objid    	 (const gchar	 *name,
					          const gchar	 *nick,
					          const gchar	 *blurb,
					          const gchar	 *default_value,
					          GParamFlags	  flags);

GOBJECT_VAR GType *ags_param_spec_types;

G_END_DECLS

#endif /* __AGS_PARAMSPECS_H__ */
