#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <locale.h>
#include <stdlib.h>

#include "li18n.h"

static int lgettext(lua_State *L)
{
  char *text, *ntext;
  
  luaL_checktype(L, 1, LUA_TSTRING);
  text = lua_tostring(L, 1);

  ntext = gettext(text);

  lua_pushstring(L, ntext);

  return 1;
}

/* Copied from 'luaposix' */
static int lsetenv(lua_State *L)		/** setenv(name,value,[over]) */
{
	const char *name=luaL_checkstring(L, 1);
	const char *value=luaL_optstring(L, 2, NULL);
	if (value==NULL)
	{
		unsetenv(name);
		//return pushresult(L, 0, NULL);
	}
	else
	{
		int overwrite=lua_isnoneornil(L, 3) || lua_toboolean(L, 3);
		//return pushresult(L, setenv(name,value,overwrite), NULL);
		setenv(name,value,overwrite);
	}
}

static int lsetlocale(lua_State *L)
{
  const char *locale = luaL_checkstring(L, 1);

  /* i18n enable */
  bindtextdomain("ags","/usr/share/locale");
  textdomain("ags");
  
  setlocale(LC_ALL, locale);   /* ToDo: support other categories than LC_ALL */

  return 1;
}

static const luaL_reg i18n[] = {
  "gettext", lgettext,
  "setenv",  lsetenv,
  "setlocale",  lsetlocale,
  {NULL, NULL}
};

LUALIB_API int luaopen_i18n (lua_State *L)
{
  luaL_register(L, LUA_I18NNAME, i18n);
  return 1;
}
