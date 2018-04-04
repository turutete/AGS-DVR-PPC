#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <ags-type.h>
#include <lua-gvalue.h>

#include "lgobject.h"

#define lgobject_c

#define LUA_CONSTANT(c) lua_pushstring(L, #c); lua_pushnumber(L, c); lua_settable(L, LUA_GLOBALSINDEX);

typedef int LuaObj; /* referencia a un valor Lua en el registro */

typedef struct _LuaGClosure LuaGClosure;
struct _LuaGClosure {
  GClosure closure;
  lua_State* L;
  LuaObj     func;
  LuaObj     extra_args;
};

typedef struct _LuaTimeout LuaTimeout;
struct _LuaTimeout {
  lua_State* L;
  LuaObj     func;
  LuaObj     extra_args;
};

static void gtype_bindings(lua_State *L)
{
  LUA_CONSTANT(G_TYPE_INVALID);
  LUA_CONSTANT(G_TYPE_NONE);
  LUA_CONSTANT(G_TYPE_INTERFACE);
  LUA_CONSTANT(G_TYPE_CHAR);
  LUA_CONSTANT(G_TYPE_UCHAR);
  LUA_CONSTANT(G_TYPE_BOOLEAN);
  LUA_CONSTANT(G_TYPE_INT);
  LUA_CONSTANT(G_TYPE_UINT);
  LUA_CONSTANT(G_TYPE_LONG);
  LUA_CONSTANT(G_TYPE_ULONG);  
  LUA_CONSTANT(G_TYPE_INT64);
  LUA_CONSTANT(G_TYPE_UINT64);
  LUA_CONSTANT(G_TYPE_ENUM);
  LUA_CONSTANT(G_TYPE_FLAGS);
  LUA_CONSTANT(G_TYPE_FLOAT);
  LUA_CONSTANT(G_TYPE_DOUBLE);
  LUA_CONSTANT(G_TYPE_STRING);
  LUA_CONSTANT(G_TYPE_POINTER);
  LUA_CONSTANT(G_TYPE_BOXED);
  LUA_CONSTANT(G_TYPE_PARAM);
  LUA_CONSTANT(G_TYPE_OBJECT);

  LUA_CONSTANT(G_TYPE_VALUE);
}

/**/
static void closure_marshal(GClosure *closure,
			    GValue *return_value,
			    guint n_param_values,
			    const GValue *param_values,
			    gpointer invocation_hint,
			    gpointer marshal_data)
{
  LuaGClosure* lua_closure  = (LuaGClosure*) closure;
  lua_State*   L            = lua_closure->L;
  LuaObj       func         = lua_closure->func;
  LuaObj       extra_args   = lua_closure->extra_args;
  int          n_extra_args = 0;
  int i;
  GValue* v;
  int top = lua_gettop(L);

  lua_rawgeti(L, LUA_REGISTRYINDEX, func);            /* FUNC */

  for(i=0;i<n_param_values;i++) {
    v=&param_values[i];

    if( G_VALUE_TYPE(v)==G_TYPE_POINTER && G_IS_VALUE(g_value_get_pointer(v)) ) {
      v=(GValue*) g_value_get_pointer(v);
    }

    if( !lua_gvalue_marshall(L, v) ) { /* FUNC param[1] param[2] ... param[N] */
      g_critical("Parámetro %d de señal no convertible, se sustituye por nil.", 1+i);
      lua_pushnil(L);
    }
  }

  if(extra_args != LUA_REFNIL) {
    lua_rawgeti(L, LUA_REGISTRYINDEX, extra_args);          /* FUNC param[1] param[2] ... param[N] extra_args */
    n_extra_args++;
  }

  if( lua_pcall(L, n_param_values+n_extra_args, 1, 0) ) {                 /* result ... */
    g_critical("Error llamando signal callback: %s", lua_tostring(L, -1) );
    lua_pop(L, 1); /* Evitar leak by CC */
  }

  if(return_value) {
    if(lua_gvalue_demarshall(L, &v)) {
      g_value_copy(v, return_value);
      g_value_unset(v);
      free(v);
    }
  }

  //lua_pop(L, top);
  lua_settop(L,top);	//Dejar pila como estaba by ccabezas
}

static GClosure* closure_new(lua_State* L, LuaObj func, LuaObj extra_args, GClosureMarshal marshaller)
{
  GClosure* closure;

  g_return_val_if_fail(func != LUA_REFNIL, NULL);

  closure = g_closure_new_simple(sizeof(LuaGClosure), NULL);
  /* XXX g_closure_add_invalidate_notifier(closure, NULL, closure_invalidate); */
  if(marshaller) {
    g_closure_set_marshal(closure, marshaller);
  } else {
    g_closure_set_marshal(closure, closure_marshal);
  }
  ((LuaGClosure *)closure)->L = L;
  ((LuaGClosure *)closure)->func = func;
  ((LuaGClosure *)closure)->extra_args = extra_args;

  return closure;
}

/* stack: gobject, signal_name, function, user_data, [marshaller] */
static int lgobject_connect(lua_State *L)
{
  GClosure* closure;
  guint handlerid, sigid, len;
  GQuark detail;

  int n=lua_gettop(L);

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  luaL_checktype(L, 3, LUA_TFUNCTION);

  if(n < 3) {
    g_critical("GObject::connect requiere al menos 2 parámetros.");
    lua_pushnil(L);
    return 1;
  } else {
    GObject* object;

    object            = lua_touserdata(L, 1);
    const char* signal_name = luaL_checkstring(L, 2);
    GClosureMarshal marshaller = (GClosureMarshal) lua_tocfunction(L, 5);

    if (!G_IS_OBJECT(object) || !g_signal_parse_name(signal_name, G_OBJECT_TYPE(object), &sigid, &detail, TRUE)) {
      g_critical("Objeto %p no tiene señal %s.", object, signal_name);
      lua_pushnil(L);
      return 1;
    }

    lua_pushvalue(L, 3);
    LuaObj func       = (LuaObj)luaL_ref(L, LUA_REGISTRYINDEX); /* XXX leak potencial */
    lua_pushvalue(L, 4);
    LuaObj extra_args = (LuaObj)luaL_ref(L, LUA_REGISTRYINDEX); /* XXX leak potencial */

    closure=closure_new(L, func, extra_args, marshaller);
    /* XXX watch_closure(object, closure); */
    handlerid = g_signal_connect_closure_by_id(object, sigid, detail, closure, FALSE);
    lua_pushnumber(L, handlerid);
  }

  return 1;
}

/* get_unblocked(instance, signal_name) */
/* devuelve el primer manejador de la señal no bloqueado */
/* llamada iterativamente sirve para bloquear todos los manejadores */
static int lgobject_signal_get_unblocked(lua_State *L)
{
  gpointer instance=NULL;
  const gchar* detailed_signal=NULL;
  guint signal_id=0;
  gulong handler_id=0;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);

  instance=lua_touserdata(L, 1);
  detailed_signal = luaL_checkstring(L, 2);
  
  signal_id=g_signal_lookup(detailed_signal, G_OBJECT_TYPE(instance));
  if(signal_id) {
    handler_id=g_signal_handler_find(instance, G_SIGNAL_MATCH_UNBLOCKED|G_SIGNAL_MATCH_ID, signal_id,
				     0, NULL, NULL, NULL);
  }

  if(handler_id) {
    lua_pushnumber(L, handler_id);
  } else {
    lua_pushnil(L);
  }

  return 1;
}
/* block(instance, handler_id) */
static int lgobject_signal_block(lua_State *L)
{
  gpointer instance;
  gulong   handler_id;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);

  instance=lua_touserdata(L, 1);
  handler_id=luaL_checkint(L, 2);

  g_signal_handler_block(instance, handler_id);

  return 0;
}
/* unblock(instance, handler_id) */
static int lgobject_signal_unblock(lua_State *L)
{
  gpointer instance;
  gulong   handler_id;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);

  instance=lua_touserdata(L, 1);
  handler_id=luaL_checkint(L, 2);

  g_signal_handler_unblock(instance, handler_id);

  return 0;
}
/* stop(instance, signal_id) */
static int lgobject_signal_stop(lua_State *L)
{
  gpointer instance;
  const gchar* detailed_signal;

  CHECK_UDATA(L, 1);
  instance=GET_UDATA(L, 1);
  detailed_signal = luaL_checkstring(L, 2);

  g_signal_stop_emission_by_name(instance, detailed_signal);

  return 0;
}

/* prop=get_property(obj, name) */
static int lgobject_get_property(lua_State *L)
{
  int n=lua_gettop(L);

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);

  GObject* object           = lua_touserdata(L, 1);
  const char* property_name = luaL_checkstring(L, 2);
  GParamSpec* spec          = NULL;

  if(object) {
    spec = g_object_class_find_property (G_OBJECT_GET_CLASS(object), property_name);
  }
  GValue v={0,};
  if(spec) {
    g_value_init (&v, G_PARAM_SPEC_VALUE_TYPE(spec) );
    g_object_get_property(G_OBJECT(object), property_name, &v);
  }
  
  if(!spec || !lua_gvalue_marshall(L, &v)) {
    lua_pushnil(L);
  }
  
  /* clean */
  g_value_unset(&v);

  return 1;
}
/* set_property(obj, name, val) */
static int lgobject_set_property(lua_State *L)
{
  int n=lua_gettop(L);

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);

  GObject* object           = lua_touserdata(L, 1);
  const char* property_name = luaL_checkstring(L, 2);

  GValue *v;
  if(lua_gvalue_demarshall(L, &v)) {
    g_object_set_property(G_OBJECT(object), property_name, v);
    g_value_unset(v);
    free(v);
  } 

  return 0;
}
/* data=get_data(obj, name) */
static int lgobject_get_data(lua_State *L)
{
  int n=lua_gettop(L);

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);

  GObject* object       = lua_touserdata(L, 1);
  const char* data_name = luaL_checkstring(L, 2);

  gpointer data=g_object_get_data(G_OBJECT(object), data_name);
  lua_pushlightuserdata(L, data);

  return 1;
}
/* set_data(obj, name, val) */
static int lgobject_set_data(lua_State *L)
{
  int n=lua_gettop(L);

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);

  GObject* object       = lua_touserdata(L, 1);
  const char* data_name = luaL_checkstring(L, 2);

  g_object_set_data(G_OBJECT(object), data_name, (gpointer) lua_topointer(L, 3) );

  return 0;
}

/* unref(obj) */
static int lgobject_unref(lua_State *L)
{
  int n=lua_gettop(L);
  void *obj;

  CHECK_UDATA(L, 1);

  obj=GET_UDATA(L, 1);
  
  g_critical("pre ref count = %d", G_OBJECT(obj)->ref_count);
  g_object_unref(G_OBJECT(obj));
  g_critical("post ref count = %d", G_OBJECT(obj)->ref_count);

  return 0;
}


/**/

static gboolean timeout_handler(gpointer data)
{
  LuaTimeout *lua_to = (LuaTimeout*) data;
  lua_State  *L      = lua_to->L;
  gint n_extra_args = 0;
  gboolean ret = TRUE;

  int top = lua_gettop(L);

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_to->func);            /* FUNC */

  if(lua_to->extra_args != LUA_REFNIL) {
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_to->extra_args);          /* FUNC extra_args */
    n_extra_args++;
  }

  if( lua_pcall(L, n_extra_args, 1, 0) ) {                 /* result ... */
    g_critical("Error llamando signal callback: %s", lua_tostring(L, -1) );
    lua_pop(L, 1); /* Evitar leak by CC */
  } else {
    ret=lua_toboolean(L, -1);
  }

  //lua_pop(L, top);
  lua_settop(L,top);	//Dejar pila como estaba by ccabezas

  /* clean */
  if(!ret && lua_to) {
    luaL_unref(L, LUA_REGISTRYINDEX, (int) lua_to->func);
    luaL_unref(L, LUA_REGISTRYINDEX, (int) lua_to->extra_args);
    g_free(lua_to);
  }

  return ret;
}

/* source_remove(source) added by jur */
static int lgobject_source_remove(lua_State *L)
{
  guint source=luaL_checkint(L, 1);
  g_source_remove(source);
  return 1;
}

/* timeout_add(interval, func, data) */
static int lgobject_timeout_add(lua_State *L)
{
  LuaTimeout *lua_to = g_new0(LuaTimeout, 1);

  luaL_checktype(L, 2, LUA_TFUNCTION);

  guint interval=luaL_checkint(L, 1);

  lua_to->L=L;
  lua_pushvalue(L, 2);
  lua_to->func=(LuaObj)luaL_ref(L, LUA_REGISTRYINDEX);
  lua_pushvalue(L, 3);
  lua_to->extra_args=(LuaObj)luaL_ref(L, LUA_REGISTRYINDEX);
  
  guint res = g_timeout_add(interval, timeout_handler, lua_to);
  lua_pushnumber(L, res);

  return 1;
}

/* utf8str=locale_to_utf8(str) */
static int lgobject_locale_to_utf8(lua_State *L)
{
  size_t len;
  gsize  bytes_written;
  GError *error=NULL;

  const unsigned char *str = luaL_checklstring(L, 1, &len);

  gchar* utf8str=g_locale_to_utf8(str, len, NULL, &bytes_written, &error);
  /* XXX comprobar error */
  g_clear_error(&error);

  if(bytes_written) {
    lua_pushlstring(L, utf8str, bytes_written);
    g_free(utf8str);
  } else {
    lua_pushnil(L);
  }

  return 1;
}

/* main_loop_new(context, is_running) */
static int lgobject_main_loop_new(lua_State *L)
{
  /* CHECK_UDATA(L, 1); */ /* puede ser NULL */

  GMainContext *context   = lua_touserdata(L, 1);
  gboolean     is_running = lua_toboolean(L, 2);

  GMainLoop *ml = g_main_loop_new(context, is_running);
  if(ml)
    lua_pushlightuserdata(L, ml);
  else
    lua_pushnil(L);

  return 1;
}

/* main_loop_run(ml); */
static int lgobject_main_loop_run(lua_State *L)
{
  CHECK_UDATA(L, 1);
  GMainLoop *ml=GET_UDATA(L, 1);

  g_main_loop_run(ml);

  return 0;
}

/* main_loop_quit(ml); */
static int lgobject_main_loop_quit(lua_State *L)
{
  CHECK_UDATA(L, 1);
  GMainLoop *ml=GET_UDATA(L, 1);

  g_main_loop_quit(ml);

  return 0;
}

/* main_context_iteration(context, may_block) */
static int lgobject_main_context_iteration(lua_State *L)
{
  GMainContext *context   = lua_touserdata(L, 1);
  gboolean     may_block  = lua_toboolean(L, 2);

  gboolean res = g_main_context_iteration(context, may_block);
  lua_pushboolean(L, res);

  return 1;
}
/**/

static const luaL_reg gobject[] = {
  { "connect",        lgobject_connect },
  { "block",          lgobject_signal_block },
  { "unblock",        lgobject_signal_unblock },
  { "stop",           lgobject_signal_stop },
  { "get_property",   lgobject_get_property },
  { "set_property",   lgobject_set_property },
  { "get_data",       lgobject_get_data },
  { "set_data",       lgobject_set_data },
  { "unref",          lgobject_unref },
  { "timeout_add",    lgobject_timeout_add },
  { "locale_to_utf8", lgobject_locale_to_utf8 },
  { "main_loop_new",  lgobject_main_loop_new },
  { "main_loop_run",  lgobject_main_loop_run },
  { "main_loop_quit", lgobject_main_loop_quit },
  { "main_context_iteration", lgobject_main_context_iteration },
  { "get_unblocked",  lgobject_signal_get_unblocked },
  { "source_remove",  lgobject_source_remove },
  { NULL, NULL }
};

LUALIB_API int luaopen_gobject(lua_State *L)
{
  ags_type_init();
  gtype_bindings(L);
  luaL_register(L, LUA_GOBJECTNAME, gobject);
  return 1;
}
