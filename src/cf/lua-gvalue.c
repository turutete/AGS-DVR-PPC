#include <ags-type.h>
#include <glib-object.h>
#include <math.h>
#include <lua.h>
#include "lua-gvalue.h"

#undef  G_LOG_DOMAIN
#define G_LOG_DOMAIN "lua-gvalue"

#ifdef AGS_DEBUG
#undef  ags_debug
#define ags_debug(level, format,...)  if(level<AGS_DEBUG) g_log(G_LOG_DOMAIN, G_LOG_LEVEL_DEBUG, ("%s: " format), __func__, ##__VA_ARGS__)
#else
#define ags_debug(...) 
#endif

static int free_boxed(lua_State* L) {
  luaL_checktype(L, -1, LUA_TUSERDATA);

  if(!lua_getmetatable(L, -1)) {             /* metatabla, userdata */
    g_critical("Userdata sin metatabla");
    return 0;
  }

  lua_pushstring(L, "type");                 /* "type", metatabla, userdata */
  lua_rawget(L, -2);                         /* GType, metatabla, userdata */

  GType type=lua_tonumber(L, -1);

  void** u=lua_touserdata(L, -3);
  if(u && *u) {
    ags_debug(1, "free_boxed liberando memoria en %p de tipo %s...", u, g_type_name(type) );
    g_boxed_free(type, *u);
  }

  return 0;
}

static int get_value_array(lua_State* L) {
  CHECK_UDATA(L, 1);
  GValueArray* value_array=GET_UDATA(L, 1);

  guint index=((guint)(lua_tonumber(L, 2)+0.5))-1;
  if(index<value_array->n_values) {
    GValue *v=g_value_array_get_nth(value_array, index);
    lua_gvalue_marshall(L, v);  
  } else {
    lua_pushnil(L);
  }

  return 1;
}

gboolean lua_gvalue_demarshall(lua_State *L, GValue **v) {
  gboolean can_convert=TRUE;
  void* userdata;

  switch(lua_type(L, -1)) {
  case LUA_TSTRING:
    *v=g_new0(GValue, 1);
    g_value_init(*v, G_TYPE_STRING);
    g_value_set_string(*v, lua_tostring(L, -1));
    break;
  case LUA_TBOOLEAN:
    *v=g_new0(GValue, 1);
    g_value_init(*v, G_TYPE_BOOLEAN);
    g_value_set_boolean(*v, lua_toboolean(L, -1));
    break;
  case LUA_TNUMBER:
    *v=g_new0(GValue, 1);
/*     double a; */
/*     double b; */

/*     a=lua_tonumber(L, -1); */
/*     b=floor(a); */
/*     ags_debug(3, "a=%f b=%f", a,b); */
/*     if( a==b ) {  /\* trick! *\/ */
/*       g_value_init(*v, G_TYPE_INT);  */
/*       g_value_set_int(*v, (int)a); */
/*     } else { */
/*       g_value_init(*v, G_TYPE_DOUBLE); */
/*       g_value_set_double(*v, a); */
/*     } */
    lua_Number ln = lua_tonumber(L, -1);
    int a;
    a=(int) (ln + ( (ln<0)?-0.5:0.5 ));
    g_value_init(*v, G_TYPE_INT);
    g_value_set_int(*v, a);
    break;
  case LUA_TLIGHTUSERDATA:
  case LUA_TUSERDATA:
    userdata=GET_UDATA(L, -1);
    if(!userdata) {
      can_convert = FALSE;
      *v=NULL;
      break;
    }
    *v=g_new0(GValue, 1);
    if( G_VALUE_TYPE(userdata) == G_TYPE_BOXED ) { /* XXX */
      g_value_init(*v, G_TYPE_BOXED);
      g_value_set_boxed(*v, userdata);
    } else {
      if( G_IS_OBJECT(userdata) ) {
	g_value_init(*v, G_OBJECT_TYPE(userdata) );
	g_value_set_object(*v, userdata);
      } else {
	g_value_init(*v, G_TYPE_POINTER);
	g_value_set_pointer(*v, userdata); 
      }
    }
    break;
    case LUA_TTABLE:
    	lua_pushnil(L);    	
    	int n=lua_objlen(L, -1); 
	GValueArray *gva = g_value_array_new(n);
	
	GValue *gv;
	while ( lua_next(L, -2) != 0 ){
		if ( !lua_gvalue_demarshall(L, &gv) ){
			return FALSE; // XXX
		}
		int i = luaL_checknumber(L, -1);
		g_value_array_insert(gva, i, gv);
		g_value_unset(gv);
		g_free(gv);
	}
  	*v=g_new0(GValue, 1);
      g_value_init(*v, G_TYPE_BOXED);
      g_value_set_boxed(*v, gva);
  break;
  default:
    can_convert = FALSE;
    *v=NULL;
    break;
  }

  return can_convert;
}

gboolean lua_gvalue_marshall(lua_State *L, GValue *v) {
  gboolean can_convert = TRUE;
  GType type=G_TYPE_FUNDAMENTAL(G_VALUE_TYPE(v));
  GValue* newv;

  switch( type ) {
  case G_TYPE_STRING:
    lua_pushstring(L, g_value_get_string(v));
    break;
  case AGS_TYPE_OBJID: /* XXX hay que poder distinguirlo de string a posteriori! */
    lua_pushstring(L, g_value_get_objid(v));
    break;
  case G_TYPE_INT:
    lua_pushnumber(L, g_value_get_int(v));
    break;
  case G_TYPE_LONG:
    lua_pushnumber(L, g_value_get_long(v));
    break;
  case G_TYPE_POINTER:
    lua_pushlightuserdata(L, g_value_get_pointer(v));
    break;
  case G_TYPE_OBJECT:
    lua_pushlightuserdata(L, g_value_get_object(v));
    break;
  case G_TYPE_BOOLEAN:
    lua_pushboolean(L, g_value_get_boolean(v));
    break;
  case G_TYPE_BOXED:
    lua_boxpointer(L, g_value_dup_boxed(v));

    /* Creamos metatabla */
    lua_newtable(L);                                      /* TABLE, userdata, ... */

    /* Metemos "type" (key) */
    lua_pushstring(L, "type");                            /* "type", TABLE, userdata,  ... */
    /* Metemos GType de boxed (value) */
    lua_pushnumber(L, G_VALUE_TYPE(v));                   /* GType, "type", TABLE, userdata, ... */
    /* TABLE["type"]=GType (TABLE[key]=value) */
    lua_rawset(L, -3);                                    /* TABLE, userdata, ...*/

    /* metemos "__gc" (key) */
    lua_pushstring(L, "__gc");                            /* "__gc", TABLE, userdata, ... */
    /* Metemos función free de boxed (value) */
    lua_pushcfunction(L, free_boxed);                     /* free_boxed(), "__gc", TABLE, userdata, ... */
    /* TABLE["__gc"]=free_boxed() (TABLE[key]=value) */
    lua_rawset(L, -3);                                    /* TABLE, userdata, ... */

    if(G_VALUE_TYPE(v)==G_TYPE_VALUE_ARRAY) {
      /* metemos "__index" (key) */
      lua_pushstring(L, "__index");                       /* "__index", TABLE, userdata, ... */
      /* Metemos función de índice (value) */
      lua_pushcfunction(L, get_value_array);              /* get_value_array(), "__index", TABLE, userdata, ... */
      /* TABLE["__index"]=get_value_array() (TABLE[key]=value) */
      lua_rawset(L, -3);                                    /* TABLE, userdata, ... */
    }

    /* establecemos TABLE como metatable de userdata */
    if(!lua_setmetatable(L, -2)) {                        /* userdata, ... */
      g_critical("No se pudo establecer metatabla!");
    }
    
    break;
  default:
    can_convert = FALSE;
    break;
  }

  return can_convert;
}
