#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <gdk/gdk.h> 
#include <gdk-pixbuf/gdk-pixbuf.h>

#include "lgdk.h"

#define lgdk_c

#define LUA_CONSTANT(c) lua_pushstring(L, #c); lua_pushnumber(L, c); lua_settable(L, LUA_GLOBALSINDEX);

static void gdk_bindings(lua_State *L)
{
  LUA_CONSTANT(GDK_TYPE_PIXBUF);
  
  LUA_CONSTANT(GDK_LINE_SOLID);
  LUA_CONSTANT(GDK_LINE_ON_OFF_DASH);
  LUA_CONSTANT(GDK_LINE_DOUBLE_DASH);

  LUA_CONSTANT(GDK_CAP_NOT_LAST);
  LUA_CONSTANT(GDK_CAP_BUTT);
  LUA_CONSTANT(GDK_CAP_ROUND);
  LUA_CONSTANT(GDK_CAP_PROJECTING);

  LUA_CONSTANT(GDK_JOIN_MITER);
  LUA_CONSTANT(GDK_JOIN_ROUND);
  LUA_CONSTANT(GDK_JOIN_BEVEL);
}

LUALIB_API int luaopen_gdk(lua_State *L)
{
  gdk_bindings(L);
  return 1;
}
