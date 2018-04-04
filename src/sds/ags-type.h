#ifndef __AGS_TYPE_H__
#define __AGS_TYPE_H__

#include <glib-object.h>
#include <ags-cf.h>

G_BEGIN_DECLS

/**/
#define AGS_TYPE_COUNTER32 G_TYPE_MAKE_FUNDAMENTAL( G_TYPE_RESERVED_USER_FIRST+0 )
#define AGS_TYPE_GAUGE32   G_TYPE_MAKE_FUNDAMENTAL( G_TYPE_RESERVED_USER_FIRST+1 )
#define AGS_TYPE_TIMETICKS G_TYPE_MAKE_FUNDAMENTAL( G_TYPE_RESERVED_USER_FIRST+2 )
#define AGS_TYPE_OBJID     G_TYPE_MAKE_FUNDAMENTAL( G_TYPE_RESERVED_USER_FIRST+3 )

/**/
void ags_type_init(void);
char *find_file_in_path (const char* filename, const char* path, const char* envvar);
void set_object_props(GObject *obj, ConfigIf *cfif, CfTable props_cft);

G_END_DECLS

#endif /* __AGS_TYPE_H__ */
