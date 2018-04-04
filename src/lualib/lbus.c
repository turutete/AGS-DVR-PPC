#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <glib.h>
#include <glib-object.h>
#include <busif.h>

#include <lbus.h>
#include <lua-gvalue.h>

#define lbus_c

static int lbus_write(lua_State *L)
{
  void*   bif; /* bus interface */
  gchar*  obj_name;
  gchar*  poll_da = NULL;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  bif = lua_touserdata(L, 1);

  luaL_checktype(L, 2, LUA_TSTRING);
  obj_name = lua_tostring(L, 2);

  if(!lua_isnil(L, 3)) {
    luaL_checktype(L, 3, LUA_TSTRING);
    poll_da = lua_tostring(L, 3);
  }

  int res=bus_write(BUSIF(bif), obj_name, poll_da);
  lua_pushnumber(L, res);
  
  return 1;
}

static int lbus_write2(lua_State *L)
{
  void*   bif; /* bus interface */
  gchar*  obj_name;
  gchar*  poll_da = NULL;
  GValueArray * m;
  GValueArray * v;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  bif = lua_touserdata(L, 1);

  luaL_checktype(L, 2, LUA_TSTRING);
  obj_name = lua_tostring(L, 2);

  if(!lua_isnil(L, 3)) {
    luaL_checktype(L, 3, LUA_TSTRING);
    poll_da = lua_tostring(L, 3);
  }
  GValue *b;

  CHECK_UDATA(L, 4);
  m=GET_UDATA(L, 4);

  CHECK_UDATA(L, 5);
  v=GET_UDATA(L, 5);

  int res=bus_write2(BUSIF(bif), obj_name, poll_da, m, v);
  lua_pushnumber(L, res);
  
  return 1;
}

static const luaL_reg bus[] = {
  { "write", lbus_write },
  { "write2", lbus_write2 },
  { NULL, NULL }
};

LUALIB_API int luaopen_bus(lua_State *L)
{
  luaL_register(L, LUA_BUSNAME, bus);
  return 1;
}
