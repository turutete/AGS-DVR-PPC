/**
   \mainpage

   \section ags Arquitectura de Gestión de Sistemas
   
      \subsection gobject Librería gobject

     AGS está implementado sobre la librería gobject. gobject ofrece un marco de trabajo ("framework") orientado a objetos en C,
     los principales elementos de este entorno son:
        - Sistema de tipos.
	- Implementación de los tipos fundamentales (enteros, etc.).
	- Implementación de un tipo base para OO (GObject)
	- Sistema de señales como mecanismo de notificación entre objetos.
	- Sistema de parámetros (propiedades).
     
      \subsection modtypes Tipos de módulos
         - SDS
	 - GW
	 - CM
	 - UI
      \subsection cf Módulos de configuración
         XXX
      \subsection mvs M/V/C
         XXX
      \subsection signals Señales
         XXX
      \subsection stores Stores
         XXX
      \subsection buffers Buffers
         XXX
      \subsection gtk2 GTK2
         XXX
      \subsection secmans Manuales      
      - \ref refmans
*/
/**
   \page refmans Manuales de referencia (r77)

     - SDS
      - \subpage sdscoreglib
      - \subpage sdsxsnmp
     - GW
      - \subpage gwsnmp
     - CM
      - \subpage cmmibinit
      - \subpage cmscript
      - \subpage cmtextbuffer
      - \subpage cmzigorobj
      - \subpage cmzigorbus
      - \subpage cmzigormng
     - UI
      - \subpage uigtk2
      - \subpage gtk2gladelo
      - \subpage gtk2treestore
      - \subpage gtk2treeview
      - \subpage gtk2xml2tm
      - \subpage gtk2poll
      - \subpage gtk2table (deprecated)
      - \subpage gtk2pixbufs
      - \subpage gtk2line
      - \subpage gtk2textview
      - \subpage gtk2textbuffer
      - \subpage gtk2keysnooper
      - \subpage pollglib
      - \subpage treestoreglib
      - \subpage uicurses
      - \subpage xml2tslibxml2
*/

#include <config.h>
#include <gmodule.h>
#include <ags-cf.h>
#include <configif.h>
#include <ags-valuetypes.h>

/* XXX Debug con llamadas a gc de lua */
//#include <cf-lua.h>	
//#include <lua.h>
//#include <lualib.h>
//#include <lauxlib.h>
/* XXX Debug con llamadas a gc de lua */

#include <signal.h>
typedef void (*sighandler_t)(int);

#include <execinfo.h>    /* backtrace */

#undef  G_LOG_DOMAIN
#define G_LOG_DOMAIN "test-mods"

#ifdef AGS_DEBUG
#undef  ags_debug
#define ags_debug(level, format,...)  if(level<AGS_DEBUG) g_log(G_LOG_DOMAIN, G_LOG_LEVEL_DEBUG, ("%s: " format), __func__, ##__VA_ARGS__)
#else
#define ags_debug(...) 
#endif

/**/
static GMainLoop *ml=-1;

static void signal_handler(int signal) {
  if(ml != -1) 
    g_main_loop_quit(ml);
}

#ifdef AGS_DEBUG
#include <malloc.h> /* __malloc_hook, __free_hook */

/* my hooks.  */
static void my_init_hook (void);
static void *my_malloc_hook (size_t, const void *);
static void my_free_hook (void*, const void *);

void *(*old_malloc_hook) (size_t, const void *) = NULL;
void (*old_free_hook) (void*, const void *) = NULL;

/* Override initializing hook from the C library. */
void (*__malloc_initialize_hook) (void) = my_init_hook;

static GHashTable* my_malloc_hashtable = NULL;

static void start_my_malloc_hook(void)
{
  if(__malloc_hook != my_malloc_hook) {
    old_malloc_hook = __malloc_hook;
    __malloc_hook = my_malloc_hook;
  }
  if(__free_hook != my_free_hook) {
    old_free_hook = __free_hook;
    __free_hook = my_free_hook;
  }
}

static void stop_my_malloc_hook(void)
{
  __malloc_hook = old_malloc_hook;
  __free_hook = old_free_hook;
}

static void
my_init_hook (void)
{
  start_my_malloc_hook();
}

#define BACKTRACE_LEN 20

struct bt_t {
  int   len;
  void* addresses[BACKTRACE_LEN];
};

static void *
my_malloc_hook (size_t size, const void *caller)
{
  void *result;
  struct bt_t *bt;

  /* restablecer anteriores */
  __malloc_hook = old_malloc_hook;
  __free_hook = old_free_hook;
  /* llamada recursiva */
  result = malloc (size);
  /* XXX salvar (¿necesario?) */
  old_malloc_hook = __malloc_hook;
  old_free_hook = __free_hook;

  /* Añadimos a nuestra "traza" */
  if(my_malloc_hashtable && result) {
    bt = malloc(sizeof(struct bt_t));
    bt->len = backtrace(bt->addresses, BACKTRACE_LEN);
    g_hash_table_insert(my_malloc_hashtable, result, (gpointer) bt);
  }

  /* restaurar nuestros hooks */
  __malloc_hook = my_malloc_hook;
  __free_hook = my_free_hook;
  return result;
}

static void
my_free_hook (void *ptr, const void *caller)
{
  /* restablecer anteriores */
  __malloc_hook = old_malloc_hook;
  __free_hook = old_free_hook;
  /* llamada recursiva */
  free (ptr);
  /* XXX salvar (¿necesario?) */
  old_malloc_hook = __malloc_hook;
  old_free_hook = __free_hook;

  /* borramos "traza" */
  if(my_malloc_hashtable)
    g_hash_table_remove(my_malloc_hashtable, (gpointer) ptr);

  /* restaurar nuestros hooks */
  __malloc_hook = my_malloc_hook;
  __free_hook = my_free_hook;
}

static void
dump_bt(void *ptr, struct bt_t *bt, gpointer user_data) {
  int i;
  char **strings;

  strings = backtrace_symbols(bt->addresses, bt->len);
  printf("backtrace returned: %02d\n", bt->len);
  for(i = 2; i < bt->len; i++) {
    printf("%d: 0x%08x ", i-2, (int)bt->addresses[i]);
    printf("%s\n", strings[i]);     }
}
#endif /* AGS_DEBUG */

void close_module(char *mod_name, AgsCf *my_cf, CfTable ags_table)
{
  GValue *v;
  GModule *modulo;
  char *mod_filename;
  char *error;
  void* (*close)();
  GObject *mod_obj; /* módulos objeto */
  CfTable mod_table;

  mod_table=config_get_table(CONFIGIF(my_cf), ags_table, mod_name);

  if(   config_check_table(CONFIGIF(my_cf), mod_table)
     && config_get_boolean(CONFIGIF(my_cf), mod_table, "close") ) { /* cerrar el módulo tras inicialización? */
    ags_debug(1, "Cerrando módulo %s", mod_name);
    mod_filename=config_get_string(CONFIGIF(my_cf), mod_table, "mod_filename");
    GString *mod_varname=g_string_new(mod_filename);
    g_string_append(mod_varname, "_so"); /* nombre de variable global para guardar módulo (.so) */

    /* Obtener "handle" de módulo */
    modulo=config_get_pointer(CONFIGIF(my_cf), NULL, mod_varname->str);
    /* Obtener objeto */
    mod_obj=config_get_object(CONFIGIF(my_cf), NULL, mod_name);
    ags_debug(2, "modulo=%p mod_obj=%p", modulo, mod_obj);

    /* llamar a función de cierre (si existe) */
    GString *mod_destructorname=g_string_new(mod_filename);
    g_string_append(mod_destructorname, "_close");
    g_module_symbol(modulo, mod_destructorname->str, (gpointer*)&close);
    
    if(close) {
      ags_debug(1, "Llamando  %s", mod_destructorname->str);
      close();
    }
    if(mod_obj) {
      /* eliminar objeto ( g_object_unref() )*/
      ags_debug(1, "g_object_unref %p", mod_obj);
      g_object_unref(mod_obj);
    }
    if(modulo) {
      g_module_close(modulo);
      error=(gchar*)g_module_error();
      ags_debug(1, "close %p -> %s", mod_obj, error);
    }
  }
}

int main(int argc, char **argv) 
{
  GMainContext *mc;
  GModule *modulo;
  void* (*new)();
  AgsCf* (*cf_new)(char*);
  char *error;
  GString *aux=g_string_new("");
  
  if(argc!=3) {
    printf("Uso: %s <mod_configuracion> <fichero_configuracion>\n", argv[0]);
    exit(-1);
  }    
  
  ags_type_init();
  
  /* módulo configuración */
  g_string_printf(aux, "%s%s.%s", AGS_MOD_PREFIX, argv[1], G_MODULE_SUFFIX);
  gchar* found=find_file_in_path(aux->str, AGS_MOD_PATH, "AGS_MOD_PATH");
  modulo=g_module_open(found, G_MODULE_BIND_LAZY);
  if(!modulo) {
    g_error("%s", g_module_error());
  }
  if (found)
    free(found);
  g_string_printf(aux, "%s_new", argv[1]);
  if(! g_module_symbol(modulo, aux->str, (gpointer*)&new) ) {
    g_error("[%s] %s", g_module_name(modulo), g_module_error());
  }
  g_string_free(aux, TRUE);

  cf_new=new(); 
  g_message("Creando módulo objeto: %s...", argv[1]);
  AgsCf* my_cf=cf_new(argv[2]); /* ref_count=1 */

  ml = g_main_loop_new(NULL, FALSE);
  /* Metemos "main_loop" en configuración (global) para que sea accesible por otros módulos */
  config_set_pointer(CONFIGIF(my_cf), NULL, "main_loop", ml);

  CfTable ags_table=config_get_table(CONFIGIF(my_cf), NULL, "ags");
  if(! config_check_table(CONFIGIF(my_cf), ags_table) )
    g_error("No se encontró configuración AGS.");
 
  /* guardamos nombre=<objeto> en la configuración global */
  ags_debug(1,"Creado módulo objeto: %s...", argv[1]);
  config_set_object(CONFIGIF(my_cf), NULL, argv[1], my_cf); /* ref_count++ */
  g_object_unref(G_OBJECT(my_cf)); /* ref_count-- */

  char *mod_idx = NULL;
  while(mod_idx=config_getnextkey(CONFIGIF(my_cf), ags_table, mod_idx)) {
    /* cargar módulo */
    config_load_module(CONFIGIF(my_cf), mod_idx, ags_table);
  }

  /* eliminar módulos de inicialización */
  mod_idx = NULL;
  while(mod_idx=config_getnextkey(CONFIGIF(my_cf), ags_table, mod_idx)) {
    /* cerrar módulo */
    close_module(mod_idx, my_cf, ags_table);
  }

  /* Cierre limpio de "mainloop" al salir */
  sighandler_t old_term_handler = signal(SIGTERM, signal_handler);
  sighandler_t old_int_handler  = signal(SIGINT,  signal_handler);

#ifdef AGS_DEBUG
  char* ags_mtrace=getenv("AGS_MTRACE");
  if(ags_mtrace) {
    /* Nos interesan los "leaks" del "mainloop", ignoramos los de inicialización de momento */
    my_malloc_hashtable = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL, free);
    if(!my_malloc_hashtable) {
      g_error("No se pudo crear my_malloc_hashtable");
    }
  }
#endif /* AGS_DEBUG */

  g_main_loop_run(ml);  /*   gw_snmp(sds, argc, argv); */

  /* destruir objetos limpiamente */
  mod_idx = NULL;
  while(mod_idx=config_getnextkey(CONFIGIF(my_cf), ags_table, mod_idx)) {
    GObject* obj=config_get_object(CONFIGIF(my_cf), NULL, mod_idx); /* ref_count++ */
    g_object_unref(obj); /* ref_count-- */
    g_object_unref(obj); /* ref_count-- */
  }

  GObject* obj=config_get_object(CONFIGIF(my_cf), NULL, "cflua"); /* ref_count++ */

//	lua_gc(CF_LUA(obj)->Ls,LUA_GCCOLLECT,0);  /* XXX Debug con llamadas a gc de lua */	
//	lua_gc(CF_LUA(obj)->Ls,LUA_GCCOLLECT,0);  /* XXX Debug con llamadas a gc de lua */
//	lua_gc(CF_LUA(obj)->Ls,LUA_GCCOLLECT,0);  /* XXX Debug con llamadas a gc de lua */
//	lua_gc(CF_LUA(obj)->Ls,LUA_GCCOLLECT,0);  /* XXX Debug con llamadas a gc de lua */
  g_object_unref(obj); /* ref_count-- */

#ifdef AGS_DEBUG
  if(ags_mtrace) {
    stop_my_malloc_hook();
    
    g_hash_table_foreach(my_malloc_hashtable, dump_bt, NULL);
  }
#endif

  return 0;
}
