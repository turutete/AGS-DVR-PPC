#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <glib.h>
#include <glib-object.h>
#include <configif.h>

#include "lconfig.h"

#define lconfig_c

#define LUA_CONSTANT(c) lua_pushstring(L, #c); lua_pushnumber(L, c); lua_settable(L, LUA_GLOBALSINDEX);

static int lconfig_get(lua_State *L)
{
  GObject*   cif; /* config interface */
  GValue* v;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  if(!lua_isnil(L, 2))
    luaL_checktype(L, 2, LUA_TLIGHTUSERDATA);

  cif = lua_touserdata(L, 1);
  CfTable cftable = lua_touserdata(L, 2);
  const char* key = luaL_checkstring(L, 3);

  v=config_get(CONFIGIF(cif), cftable, key);
  if(!v || !lua_gvalue_marshall(L, v)) {
    lua_pushnil(L);
  } else {
    g_value_unset(v);
    free(v);
  }
  
  return 1;
}

static int lconfig_set(lua_State *L)
{
  GObject*   cif; /* config interface */
  GValue* v;
  int     res;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  if(!lua_isnil(L, 2))
    luaL_checktype(L, 2, LUA_TLIGHTUSERDATA);

  cif = lua_touserdata(L, 1);
  CfTable cftable = lua_touserdata(L, 2);
  const char* key = luaL_checkstring(L, 3);

  /* el valor ya está en la posición -1 de la pila */
  lua_gvalue_demarshall(L, &v);

  res=config_set(CONFIGIF(cif), cftable, key, v);
  lua_pushnumber(L, res);
  
  return 1;
}


/* XXX buggy? */
static int lconfig_get_table(lua_State *L)
{
  GObject*   cif; /* config interface */
  CfTable res;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  if(!lua_isnil(L, 2))
    luaL_checktype(L, 2, LUA_TLIGHTUSERDATA);

  cif = lua_touserdata(L, 1);
  CfTable cftable = lua_touserdata(L, 2);
  const char* key = luaL_checkstring(L, 3);

  res=config_get_table(CONFIGIF(cif), cftable, key);
  lua_pushlightuserdata(L, res);
  
  return 1;
}

static int lconfig_add_table(lua_State *L)
{
  GObject*   cif; /* config interface */
  CfTable res;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  if(!lua_isnil(L, 2))
    luaL_checktype(L, 2, LUA_TLIGHTUSERDATA);

  cif = lua_touserdata(L, 1);
  CfTable cftable = lua_touserdata(L, 2);
  const char* key = luaL_checkstring(L, 3);

  res=config_add_table(CONFIGIF(cif), cftable, key);
  lua_pushlightuserdata(L, res);
  
  return 1;
}

static int lconfig_getnextkey(lua_State *L)
{
  GObject*   cif; /* config interface */
  char*   nextkey;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  if(!lua_isnil(L, 2))
    luaL_checktype(L, 2, LUA_TLIGHTUSERDATA);

  cif = lua_touserdata(L, 1);
  CfTable cftable = lua_touserdata(L, 2);
  const char* key = luaL_checkstring(L, 3);

  nextkey = config_getnextkey(CONFIGIF(cif), cftable, key);
  lua_pushstring(L, nextkey);
  
  return 1;
}

static int lconfig_check_table(lua_State *L)
{
  GObject*    cif; /* config interface */
  gboolean res;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  if(!lua_isnil(L, 2))
    luaL_checktype(L, 2, LUA_TLIGHTUSERDATA);

  cif = lua_touserdata(L, 1);
  CfTable cftable = lua_touserdata(L, 2);

  res = config_check_table(CONFIGIF(cif), cftable);
  lua_pushboolean(L, res);
  
  return 1;
}

static int lconfig_load_module(lua_State *L)
{
  GObject*    cif; /* config interface */
  const char* mod_name;
  CfTable     cftable;
  GObject*    res;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  if(!lua_isnil(L, 3))
    luaL_checktype(L, 3, LUA_TLIGHTUSERDATA);

  cif      = lua_touserdata(L, 1);
  mod_name = luaL_checkstring(L, 2);
  cftable  = (CfTable)lua_touserdata(L, 3);

  res = config_load_module(CONFIGIF(cif), mod_name, cftable);
  lua_pushlightuserdata(L, (void*) res);

  return 1;
}

static const luaL_reg config[] = {
  { "get",         lconfig_get         },
  { "set",         lconfig_set         },
  { "get_table",   lconfig_get_table   },
  { "add_table",   lconfig_add_table   },
  { "getnextkey",  lconfig_getnextkey  },
  { "load_module", lconfig_load_module },
  { NULL, NULL }
};

LUALIB_API int luaopen_config(lua_State *L)
{
  luaL_register(L, LUA_CONFIGNAME, config);
  return 1;
}
