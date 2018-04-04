#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <glib.h>
#include <glib-object.h>
#include <accessxif.h>

#include "laccessx.h"

#define laccessx_c

#define LUA_CONSTANT(c) lua_pushstring(L, #c); lua_pushnumber(L, c); lua_settable(L, LUA_GLOBALSINDEX);

static int laccessx_getnextkey(lua_State *L)
{
  void* axif; /* accessx interface */
  char* nextkey;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  axif = lua_touserdata(L, 1);
  char* key = luaL_checkstring(L, 2);

  nextkey=accessx_getnextkey(ACCESSXIF(axif), key);
  if(nextkey) {
    lua_pushstring(L, nextkey);
    free(nextkey);
  } else {
    lua_pushnil(L);
  }
  
  return 1;
}

static const luaL_reg accessx[] = {
  { "getnextkey", laccessx_getnextkey },
  { NULL, NULL }
};

LUALIB_API int luaopen_accessx(lua_State *L)
{
  luaL_register(L, LUA_ACCESSXNAME, accessx);
  return 1;
}
