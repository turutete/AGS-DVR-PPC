#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <glib.h>
#include <glib-object.h>
#include <textbufferif.h>

#include "ltextbuffer.h"

#define ltextbuffer_c

#define LUA_CONSTANT(c) lua_pushstring(L, #c); lua_pushnumber(L, c); lua_settable(L, LUA_GLOBALSINDEX);

static int ltextbuffer_get(lua_State *L)
{
  void*   tbif; /* textbuffer interface */
  gchar*  text;
  gint    len;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  tbif = lua_touserdata(L, 1);

  text=textbuffer_get(TEXTBUFFERIF(tbif), &len);
  if(text) {
    lua_pushlstring(L, text, len);
    free(text);
  } else {
    lua_pushnil(L);
  }
  
  return 1;
}

static int ltextbuffer_set(lua_State *L)
{
  void*   tbif; /* textbuffer interface */
  GValue* v;
  int     res;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  tbif = lua_touserdata(L, 1);

  size_t len;
  const char* text = luaL_checklstring(L, 2, &len);

  if(text)
    textbuffer_set(TEXTBUFFERIF(tbif), text, len+1);
  
  return 0;
}

static int ltextbuffer_setraw(lua_State *L)
{
  void*   tbif; /* textbuffer interface */
  GValue* v;
  int     res;

  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  tbif = lua_touserdata(L, 1);

  size_t len;
  const char* text = luaL_checklstring(L, 2, &len);

  if(text)
    textbuffer_set(TEXTBUFFERIF(tbif), text, len);
  
  return 0;
}

static const luaL_reg textbuffer[] = {
  { "get", ltextbuffer_get },
  { "set", ltextbuffer_set },
  { "setraw", ltextbuffer_setraw },
  { NULL, NULL }
};

LUALIB_API int luaopen_textbuffer(lua_State *L)
{
  luaL_register(L, LUA_TEXTBUFFERNAME, textbuffer);
  return 1;
}
