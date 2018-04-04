#include <ags-type.h>

/**/
void
ags_type_init(void)
{
  static gboolean init = FALSE;

  if(!init) {
    g_type_init();
    ags_value_types_init();
    ags_param_spec_type_init();
    ags_value_transforms_init();
    init = TRUE;
  }
}

/* XXX meter en otro fuente */
static char *
find_file_in_pathstring (const char* filename, const char* pathstring)
{
  gchar *aux;
  gchar *basename;
  gchar *path_filename; /* nombre de fichero con ruta */
  gchar **parts;
  gint i;
  
  parts = g_strsplit(pathstring, G_SEARCHPATH_SEPARATOR_S, 255);
  for (path_filename = NULL, i = 0; parts[i] != NULL && path_filename == NULL; i++) {
    basename=g_path_get_basename(filename);
    aux = g_build_filename(parts[i], basename, NULL);
    g_free(basename);
    
    if ( g_file_test(aux, G_FILE_TEST_IS_REGULAR) ) /* existe y es un fichero? */
      path_filename=g_strdup(aux);
	 
    g_free(aux);
  }

  g_strfreev(parts);

  return path_filename;
}
static char*
find_file_in_pathenv (const char* filename, const char *pathenv)
{
  gchar *env;
  env = g_getenv(pathenv);
  if (env == NULL) {
    return NULL;
  }

  return find_file_in_pathstring(filename, env);
}
char*
find_file_in_path (const char* filename, const char *path, const char *envvar)
{
  gchar* path_filename=NULL;

  if(path)
    path_filename=find_file_in_pathstring(filename, path);
  if(!path_filename && envvar)
    path_filename=find_file_in_pathenv(filename, envvar);
  
  return path_filename;
}
void set_object_props(GObject *obj, ConfigIf *cfif, CfTable props_cft)
{
  gboolean r=FALSE;
  gchar *prop_name=NULL;
  GValue *prop_val=NULL;
  
  if(config_check_table(cfif, props_cft)) {
    while(prop_name=config_getnextkey(cfif, props_cft, prop_name)) {
      prop_val=config_get(cfif, props_cft, prop_name);
      if(prop_val) {
	g_object_set_property(obj, prop_name, prop_val);      
	g_value_unset(prop_val);
	free(prop_val);
      }
    }
  }
}
