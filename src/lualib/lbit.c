/* (c) bigthor */

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "lbit.h"

#define lbit_c

static int bit_and(lua_State *L)
{
  int a,b,c;
  a=lua_tonumber(L, 1);
  b=lua_tonumber(L, 2);
  c=a&b;
  lua_pushnumber(L, c);
  return 1;
}

static int bit_or(lua_State *L)
{
  int a,b,c;
  a=lua_tonumber(L, 1);
  b=lua_tonumber(L, 2);
  c=a|b;
  lua_pushnumber(L, c);
  return 1;
}
static int bit_xor(lua_State *L)
{
  int a,b,c;
  a=lua_tonumber(L, 1);
  b=lua_tonumber(L, 2);
  c=a^b;
  lua_pushnumber(L, c);
  return 1;
}
static int bit_not(lua_State *L)
{
  int a,b;
  a=lua_tonumber(L, 1);
  b=~a;
  lua_pushnumber(L, b);
  return 1;
}
static int bit_shl(lua_State *L)
{
  int a,b,c;
  a=lua_tonumber(L, 1);
  b=lua_tonumber(L, 2);
  c=a<<b;
  lua_pushnumber(L, c);
  return 1;
}
static int bit_shr(lua_State *L)
{
  int a,b,c;
  a=lua_tonumber(L, 1);
  b=lua_tonumber(L, 2);
  c=a>>b;
  lua_pushnumber(L, c);
  return 1;
}

static const luaL_reg bit[] = {
  "AND", bit_and,
  "OR",  bit_or,
  "XOR", bit_xor,
  "NOT", bit_not,
  "SHL", bit_shl,
  "SHR", bit_shr,
  {NULL, NULL}
};

LUALIB_API int luaopen_bit (lua_State *L)
{
  luaL_register(L, LUA_BITNAME, bit);
  return 1;
}
