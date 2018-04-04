/**
   \file configif.c 
   Interface config.
   \todo
   - getnext (para tablas)
 */

#include <glib.h>
#include <glib-object.h>
#include <gmodule.h> /* XXX */
#include <config.h>
#include <ags-cf.h>
#include "configif.h"

#undef  G_LOG_DOMAIN
#define G_LOG_DOMAIN "configif"

#ifdef AGS_DEBUG
#undef  ags_debug
#define ags_debug(level, format,...)  if(level<AGS_DEBUG) g_log(G_LOG_DOMAIN, G_LOG_LEVEL_DEBUG, ("%s: " format), __func__, ##__VA_ARGS__)
#else
#define ags_debug(...) 
#endif


GType 
config_if_get_type (void) {
  static GType this_type = 0;
  if (! this_type) {
    static const GTypeInfo this_info = {
      sizeof (ConfigIfIface),  /* class_size */
      NULL,	  /* base_init */
      NULL,	  /* base_finalize */
      NULL,
      NULL,	  /* class_finalize */
      NULL,	  /* class_data */
      0,
      0,	   /* n_preallocs */
      NULL
    };
    
    this_type = g_type_register_static (G_TYPE_INTERFACE, "ConfigIf", &this_info, 0);
    g_type_interface_add_prerequisite (this_type, G_TYPE_OBJECT);
  }
  return this_type;
}

inline
CfTable
config_add_table(ConfigIf *self, CfTable cft, const char *k) {
  return CONFIGIF_GET_IFACE(self)->add_table(self, cft, k);  
}

inline
CfTable
config_get_table(ConfigIf *self, CfTable cft, const char *k) {
  return CONFIGIF_GET_IFACE(self)->get_table(self, cft,  k);  
}

inline 
GValue*
config_get(ConfigIf *self, CfTable cft, const char *k) {
  return CONFIGIF_GET_IFACE(self)->get(self, cft, k);  
}

inline 
int
config_set(ConfigIf *self, CfTable cft, const char *k, GValue *v) {
  return CONFIGIF_GET_IFACE(self)->set(self, cft, k, v);
}

inline
char*
config_getnextkey(ConfigIf *self, CfTable cft, const char *k) {
  return CONFIGIF_GET_IFACE(self)->getnextkey(self, cft, k);
}
inline
gboolean
config_check_table(ConfigIf *self, CfTable cft) {
  return CONFIGIF_GET_IFACE(self)->check_table(self, cft);
}

/* helpers */
inline
gchar*
config_get_string(ConfigIf *self, CfTable cft, const char *k) {
  GValue *v=CONFIGIF_GET_IFACE(self)->get(self, cft, k);
  gchar *string=(gchar*)g_value_get_string(v);
  free(v);

  return string;
}

inline
int
config_set_string(ConfigIf *self, CfTable cft, const char *k, gchar *s) {
  GValue v={ G_TYPE_STRING, };
  g_value_set_string(&v, s );
  return CONFIGIF_GET_IFACE(self)->set(self, cft, k, &v);
}


inline
gint
config_get_int(ConfigIf *self, CfTable cft, const char *k) {
  GValue *v=CONFIGIF_GET_IFACE(self)->get(self, cft, k);
  gint integer=g_value_get_int(v);
  free(v);

  return integer;
}

inline
int
config_set_int(ConfigIf *self, CfTable cft, const char *k, int i) {
  GValue v={ G_TYPE_INT, };
  g_value_set_int(&v, i);
  return CONFIGIF_GET_IFACE(self)->set(self, cft, k, &v);
}

inline
gpointer
config_get_pointer(ConfigIf *self, CfTable cft, const char *k) {
  GValue *v=CONFIGIF_GET_IFACE(self)->get(self, cft, k);
  gpointer pointer=g_value_get_pointer(v);
  free(v);

  return pointer;
}

inline
int
config_set_pointer(ConfigIf *self, CfTable cft, const char *k, gpointer p) {
  GValue v={ G_TYPE_POINTER, };
  g_value_set_pointer(&v, p);
  return CONFIGIF_GET_IFACE(self)->set(self, cft, k, &v);
}
inline
GObject*
config_get_object(ConfigIf *self, CfTable cft, const char *k) {
  GValue *v=CONFIGIF_GET_IFACE(self)->get(self, cft, k);
  GObject* object=g_value_get_object(v);
  free(v);

  return object;
}

inline
int
config_set_object(ConfigIf *self, CfTable cft, const char *k, GObject* obj) {
  GValue v={ G_TYPE_OBJECT, };
  g_value_set_object(&v, obj);
  return CONFIGIF_GET_IFACE(self)->set(self, cft, k, &v);
}

inline
gboolean
config_get_boolean(ConfigIf *self, CfTable cft, const char *k) {
  GValue *v=CONFIGIF_GET_IFACE(self)->get(self, cft, k);
  gboolean boolean=g_value_get_boolean(v);
  free(v);

  return boolean;
}

inline
int
config_set_boolean(ConfigIf *self, CfTable cft, const char *k, gboolean b) {
  GValue v={ G_TYPE_BOOLEAN, };
  g_value_set_boolean(&v, b);
  return CONFIGIF_GET_IFACE(self)->set(self, cft, k, &v);
}

/* XXX helpers */
GObject* config_load_module(ConfigIf *self, char *mod_name, CfTable ags_table) {
  GValue *v;
  GModule *modulo;
  char *mod_filename=NULL;
  char *mod_newname;
  char *dep_global;
  char aux[40];
  char *error;
  void* (*new)();
  GObject* (*mod_new)(char*, AgsCf*, CfTable*);
  GObject *mod_obj; /* módulos objeto */
  CfTable mod_table;

  /* si ya cargado, devolvemos objeto */
  v=config_get(self, NULL, mod_name); /* ref count++ */
  if(v) {
    mod_obj=g_value_get_object(v);
    g_object_unref(mod_obj);       /* ref count-- */
    ags_debug(1,"Ya cargado %s=%p", mod_name, mod_obj);
    free(v);
    return mod_obj;
  }

  mod_table=config_get_table(self, ags_table, mod_name);
  if(! config_check_table(self, mod_table) )
    g_error("No se encontró configuración de %s", mod_name);

  /* cargar dependencias */
  CfTable dep_table=config_get_table(self, mod_table, "depends");
  if(config_check_table(self, dep_table)) {
    char *dep_name=NULL;
    while(dep_name=config_getnextkey(self, dep_table, dep_name)) {
      dep_global=config_get_string(self, dep_table, dep_name);
      /* cargamos dependencia */
      ags_debug(2,"Dependencia %s->%s=%s", mod_name, dep_name, dep_global);
      mod_obj=config_load_module(self, dep_global, ags_table);
      if(dep_global)
	free(dep_global);
      /* establecemos variable=objeto_módulo en tabla del módulo */
/*       g_value_unset(v); */
/*       g_value_init(v, G_TYPE_OBJECT); */
/*       g_value_set_object(v, mod_obj); */
      ags_debug(2,"%s depends %s=%p", mod_name, dep_name, mod_obj);
      config_set_object(self, mod_table, dep_name, mod_obj); /* ref count++ */
      g_object_unref(mod_obj);                                          /* ref count-- */
      free(v);
    }
  }

  /* cargar módulo */
  mod_filename=config_get_string(self, mod_table, "mod_filename");
  mod_newname=config_get_string(self, mod_table, "mod_new");
  if(!mod_newname) {
    mod_newname=mod_filename;
  }

  if(!mod_newname) {
    g_error("Error, no se especificó ni mod_filename ni mod_newname para %s.", mod_name);
  }

  g_message("Cargando módulo: %s...", mod_filename);
  GString *mod_varname=g_string_new(mod_filename);
  g_string_append(mod_varname, "_so"); /* nombre de variable global para guardar módulo (.so) */
  GString *mod_constructorname=g_string_new(mod_newname);
  free(mod_newname);
  g_string_append(mod_constructorname, "_new");
  /*   si ya cargado, no cargamos módulo */
  v=config_get(self, NULL, mod_varname->str);
  if(v) {
    modulo=g_value_get_pointer(v);
    ags_debug(1,"Ya cargado %s=%p", mod_varname->str, modulo);
    free(v);
  } else {
    sprintf(aux, "%s%s.%s", AGS_MOD_PREFIX, mod_filename, G_MODULE_SUFFIX);
    free(mod_filename);    
    
    gchar* found=find_file_in_path(aux, AGS_MOD_PATH, "AGS_MOD_PATH");

    modulo=g_module_open(found, G_MODULE_BIND_LAZY);
    if(!modulo) {
      g_warning("No se pudo cargar %s, error %s. Probando introspectiva.", aux, g_module_error() );
      modulo=g_module_open(NULL, G_MODULE_BIND_LAZY); /* Introspectiva */
    } else 
      free(found);
  } 

  /* guardamos nombre=<modulo> en la configuración global */
  ags_debug(2,"global %s=%p", mod_varname->str, modulo);
  config_set_pointer(self, NULL, mod_varname->str, modulo);
  g_string_free(mod_varname, TRUE);

  if(! g_module_symbol(modulo, mod_constructorname->str, (gpointer*)&new) ) {
    g_error("%s", g_module_error());
  }
  g_string_free(mod_constructorname, TRUE);
  g_message("Obteniendo constructor de módulo objeto: %s...", mod_name);
  mod_new=new();
  
  /* guardamos nombre=<objeto> en la configuración global */
  g_message("Creando módulo objeto: %s...", mod_name);
  mod_obj = mod_new(mod_name, AGS_CF(self), ags_table); /* ref count = 1 */
  g_message("Creado módulo objeto: %s=%p...", mod_name, mod_obj);
  config_set_object(self, NULL, mod_name, mod_obj); /* ref count++ */
  g_object_unref(mod_obj);                                     /* ref count-- */

  return mod_obj;
}
