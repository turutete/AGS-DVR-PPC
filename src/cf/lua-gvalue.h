#ifndef LUA_GVALUE_H

#define LUA_GVALUE_H

gboolean lua_gvalue_demarshall(lua_State *L, GValue **v);
gboolean lua_gvalue_marshall(lua_State *L, GValue *v);

#define lua_boxpointer(L,u) \
        (*(void **)(lua_newuserdata(L, sizeof(void *))) = (u))

#define lua_unboxpointer(L,i)   (*(void **)(lua_touserdata(L, i)))

#define CHECK_UDATA(L, n) if( (lua_type(L, n)!=LUA_TLIGHTUSERDATA) && lua_type(L, n)!=LUA_TUSERDATA) luaL_typerror(L, n, "USERDATA");
#define GET_UDATA(L, n)   ( lua_islightuserdata(L, n)?lua_touserdata(L, n):lua_unboxpointer(L, n) );

#endif /* LUA_GVALUE_H */
