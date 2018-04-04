#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <glib.h>
#include <glib-object.h>
#include <queryif.h>

#include "lquery.h"

#define lquery_c

#define LUA_CONSTANT(c) lua_pushstring(L, #c); lua_pushnumber(L, c); lua_settable(L, LUA_GLOBALSINDEX);

typedef int LuaObj; /* referencia a un valor Lua en el registro */

typedef struct _LuaQueryExec LuaQueryExec;
struct _LuaQueryExec {
  lua_State* L;
  LuaObj     func;
  LuaObj     extra_args;
};

static gboolean row_handler(GArray *fields, gpointer data)
{
  LuaQueryExec *lua_qe = (LuaQueryExec*) data;
  lua_State  *L        = lua_qe->L;
  gint n_extra_args    = 0;
  gboolean ret         = TRUE;

  int top = lua_gettop(L);

  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_qe->func);     /* FUNC */

  /* meter "fields" en Lua como primer parámetro */    
  lua_newtable(L);                                     /* TABLE, FUNC, ... */
  GValue *v;
  int  i;
  for(i=0; i < fields->len; i++) {
    v=&g_array_index(fields, GValue, i);
    lua_gvalue_marshall(L, v);                         /* field, TABLE, FUNC, ... */
    /* TABLE[i]=field  */
    lua_rawseti(L, -2, i+1);                           /* TABLE, FUNC, ...*/
  }
  /* clean */
  g_array_free(fields, TRUE);
  /**/

  if(lua_qe->extra_args != LUA_REFNIL) {
    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_qe->extra_args);    /* FUNC TABLE extra_args */
    n_extra_args++;
  }

  if( lua_pcall(L, 1+n_extra_args, 1, 0) ) {                  /* result, ... */
    g_critical("Error llamando query row callback: %s", lua_tostring(L, -1) );
  } else {
    ret=lua_toboolean(L, -1);
  }

  //lua_pop(L, top);
  lua_settop(L,top);	//Dejar pila como estaba by ccabezas

  /* clean si última fila o "callback" devuelve false */
  if(!ret || !fields) {
    luaL_unref(L, LUA_REGISTRYINDEX, (int) lua_qe->func);
    luaL_unref(L, LUA_REGISTRYINDEX, (int) lua_qe->extra_args);
    g_free(lua_qe);
  }

  return ret;
}

/* int,col_names exec(QueryIf *self (check null type), char *qstr, QueryRowCallback cb, gpointer user_data) */
static int lquery_exec(lua_State *L)
{
  void*  qif; /* query interface */
  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  qif = lua_touserdata(L, 1);

  /* input */
  size_t qlen;
  char  *qstr = luaL_checklstring(L, 2, &qlen);
  /* output */
  char  **col_names = NULL;

  /* data */
  LuaQueryExec *lua_qe = g_new0(LuaQueryExec, 1);
  luaL_checktype(L, 3, LUA_TFUNCTION); /* XXX ¿aceptar nil? */

  lua_qe->L=L;
  lua_pushvalue(L, 3);
  lua_qe->func=(LuaObj)luaL_ref(L, LUA_REGISTRYINDEX);
  lua_pushvalue(L, 4);
  lua_qe->extra_args=(LuaObj)luaL_ref(L, LUA_REGISTRYINDEX);
  /**/

  int res=query_exec(QUERYIF(qif), qstr, qlen, &col_names, row_handler, (gpointer) lua_qe);

  if(res) {
    lua_pushnumber(L, res);
    /* Meter col_names como tabla de cadenas */
    lua_newtable(L);                                     /* TABLE, res, ... */
    char **col_name=col_names;
    int  i;  
    for(i=1;*col_name;col_name++, i++) {
      lua_pushstring(L, *col_name);                       /* col_name, TABLE, res, ... */
      
      /* TABLE[i]=col_name  */
      lua_rawseti(L, -2, i);                             /* TABLE, res, ...*/
    }
    
  } else {
    lua_pushnil(L);
    lua_pushnil(L);
    /* clean */
    if(lua_qe) {
      luaL_unref(L, LUA_REGISTRYINDEX, (int) lua_qe->func);
      luaL_unref(L, LUA_REGISTRYINDEX, (int) lua_qe->extra_args);
      g_free(lua_qe);
    }
  }

  /* clean */
  if(col_names)
    g_free(col_names);

  return 2;
}

static const luaL_reg query[] = {
  { "exec", lquery_exec },
  { NULL, NULL }
};

LUALIB_API int luaopen_query(lua_State *L)
{
  luaL_register(L, LUA_QUERYNAME, query);
  return 1;
}
