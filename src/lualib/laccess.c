#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <glib.h>
#include <glib-object.h>
#include <accessif.h>

#include "laccess.h"

#define laccess_c

#define LUA_CONSTANT(c) lua_pushstring(L, #c); lua_pushnumber(L, c); lua_settable(L, LUA_GLOBALSINDEX);

static int laccess_get(lua_State *L)
{
  void*   aif; /* access interface */
  GValue* v;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  aif = lua_touserdata(L, 1);
  char* key = luaL_checkstring(L, 2);

  v=access_get(ACCESSIF(aif), key);
  if(!v || !lua_gvalue_marshall(L, v))
    lua_pushnil(L);

  /* clean */
  if(v) {
    g_value_unset(v);
    free(v);
  }
  
  return 1;
}

static int laccess_set(lua_State *L)
{
  void*   aif; /* access interface */
  GValue* v;
  int     res;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  aif = lua_touserdata(L, 1);
  char* key = luaL_checkstring(L, 2);

  /* el valor ya está en la posición -1 de la pila */
  lua_gvalue_demarshall(L, &v);

  res=access_set(ACCESSIF(aif), key, v);
  lua_pushnumber(L, res);

  /* clean */
  if(v) {
    g_value_unset(v);
    free(v);
  }
  
  return 1;
}

static const luaL_reg access[] = {
  { "get", laccess_get },
  { "set", laccess_set },
  { NULL, NULL }
};

LUALIB_API int luaopen_access(lua_State *L)
{
  luaL_register(L, LUA_ACCESSNAME, access);
  return 1;
}
