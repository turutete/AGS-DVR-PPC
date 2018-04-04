#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <glib.h>
#include <glib-object.h>
#include <treestoreif.h>
#include <lua-gvalue.h>

#include "ltreestore.h"

#define ltreestore_c

#define LUA_CONSTANT(c) lua_pushstring(L, #c); lua_pushnumber(L, c); lua_settable(L, LUA_GLOBALSINDEX);

/* first_row = first(store) */
static int ltreestore_first(lua_State *L)
{
  void* tsif; /* treestore interface */
  TsRow row;

  CHECK_UDATA(L, 1);
  tsif = GET_UDATA(L, 1);

  treestore_new_iter(TREESTOREIF(tsif), &row);
  if(treestore_first(TREESTOREIF(tsif), row)) {
    lua_pushlightuserdata(L, row); /* XXX LEAK??? */
  } else {
    lua_pushnil(L);
  }

  return 1;  
}

/* col_number = get_col_number(object, col_name) */
static int ltreestore_get_col_number(lua_State *L)
{
  void* tsif; /* treestore interface */

  CHECK_UDATA(L, 1);
  tsif = GET_UDATA(L, 1);

  char* col_name = luaL_checkstring(L, 2);
  int col_number = treestore_get_column_number(TREESTOREIF(tsif), col_name);

  lua_pushnumber(L, col_number);

  return 1;
}

/* v = get(object, row, col) */
static int ltreestore_get(lua_State *L)
{
  void*   tsif; /* treestore interface */
  GValue  vv = {0,};
  GValue* v = &vv;
  GValue* p = NULL;

  CHECK_UDATA(L, 1);
  CHECK_UDATA(L, 2);

  tsif      = GET_UDATA(L, 1);
  TsRow row = GET_UDATA(L, 2);
  gint col  = luaL_checkint(L, 3);

  treestore_get_value(TREESTOREIF(tsif), row, col, v);

  /* En columnas GValue, devuelve un GBoxed conteniendo el GValue */
  if(treestore_get_column_type(TREESTOREIF(tsif), col) == G_TYPE_VALUE) {
    p = (GValue*) g_value_get_boxed(v);    
    if(!p || !lua_gvalue_marshall(L, p)) {
      lua_pushnil(L);
    }
  } else {
    if(!lua_gvalue_marshall(L, v)) {
      lua_pushnil(L);
    } else {
      g_value_unset(v);
    }
  }

  /* clean */
  if(p) {
    g_boxed_free(G_VALUE_TYPE(v), p);
  }
 
  return 1;
}

/* set(object, row, col, v) */
static int ltreestore_set(lua_State *L)
{
  void*   tsif; /* treestore interface */
  GValue* v;
  int     res;

  CHECK_UDATA(L, 1);
  CHECK_UDATA(L, 2);

  tsif      = GET_UDATA(L, 1);
  TsRow row = GET_UDATA(L, 2);
  gint col  = luaL_checkint(L, 3);

  /* el valor ya está en la posición -1 de la pila */
  lua_gvalue_demarshall(L, &v);

  if(v) {
    treestore_set_value(TREESTOREIF(tsif), row, col, v);
    g_value_unset(v);
    free(v);
  }
  
  return 0;
}

/* row = append(object, parent_row) */
static int ltreestore_append(lua_State *L)
{
  void* tsif; /* treestore interface */
  TsRow parent_row;
  TsRow row;

  CHECK_UDATA(L, 1);
  /*   CHECK_UDATA(L, 2); */ /* XXX puede ser NULL si "store" vacío */

  tsif       = GET_UDATA(L, 1);
  parent_row = lua_touserdata(L, 2); /* XXX comprobar */

  treestore_new_iter(TREESTOREIF(tsif), &row);
  treestore_append(TREESTOREIF(tsif), row, parent_row);

  if(row) {
    lua_pushlightuserdata(L, row); /* XXX LEAK??? */
  } else {
    lua_pushnil(L);
  }

  return 1;
}

/* remove(object, row) */
static int ltreestore_remove(lua_State *L)
{
  void* tsif; /* treestore interface */
  TsRow row;

  CHECK_UDATA(L, 1);
  CHECK_UDATA(L, 2);

  tsif = GET_UDATA(L, 1);
  row  = GET_UDATA(L, 2);

  treestore_remove(TREESTOREIF(tsif), row);

  return 0;
}

static const luaL_reg treestore[] = {
  { "first",          ltreestore_first          },
  { "get_col_number", ltreestore_get_col_number },
  { "get",            ltreestore_get            },
  { "set",            ltreestore_set            },
  { "append",         ltreestore_append         },
  { "remove",         ltreestore_remove         },
  { NULL, NULL }
};

LUALIB_API int luaopen_treestore(lua_State *L)
{
  luaL_register(L, LUA_TREESTORENAME, treestore);
  return 1;
}
