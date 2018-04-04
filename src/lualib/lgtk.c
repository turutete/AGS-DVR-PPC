#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include <ags-type.h>
#include <lua-gvalue.h>

#include <gtk/gtk.h>

#include "lgtk.h"

#define lgtk_c

#define LUA_CONSTANT(c) lua_pushstring(L, #c); lua_pushnumber(L, c); lua_settable(L, LUA_GLOBALSINDEX);

static void gtk_bindings(lua_State *L)
{
  LUA_CONSTANT(GTK_SORT_ASCENDING);
  LUA_CONSTANT(GTK_SORT_DESCENDING);
  /* XXX */
}

/**/

/* función helper GTK+ "colorize" (XXX ¿donde poner?) */
static void
colorize(GtkWidget *w, guint16 red, guint16 green, guint16 blue)
{
    GdkColor    bg;
    GtkStyle    *style;

    bg.pixel    = 0;
    bg.red      = red;
    bg.green    = green;
    bg.blue     = blue;

    style = gtk_style_copy(gtk_widget_get_style(w));
    style->base[GTK_STATE_NORMAL] = bg;
    gtk_widget_set_style(w, style);
    gtk_style_unref(style);
}
/**/

/* bin_get_child(GtkBin* object)  */
static int lgtk_bin_get_child(lua_State *L)
{
  luaL_checktype(L, 1, LUA_TLIGHTUSERDATA);
  GtkBin*    bin   = lua_touserdata(L, 1);

  GtkWidget* child = gtk_bin_get_child(bin);

  if(child) {
    lua_pushlightuserdata(L, child);
  } else {
    lua_pushnil(L);
  }

  return 1;
}

/* object_destroy(obj) */
static int lgtk_object_destroy(lua_State *L)
{
  CHECK_UDATA(L, 1);
  GtkObject *obj = GET_UDATA(L, 1);

  gtk_object_destroy(obj);

  return 0;
}

/* Funciones para manejo de statusbar */

/* statusbar_push(statusbar, context, text) */
static int lgtk_statusbar_push(lua_State *L)
{
  CHECK_UDATA(L, 1);
  GtkStatusbar *sb     = GET_UDATA(L, 1);
  const gchar *context = luaL_checkstring(L, 2);
  const gchar *text    = luaL_checkstring(L, 3);

  guint context_id = gtk_statusbar_get_context_id(sb, context);
  guint message_id = gtk_statusbar_push(sb, context_id, text);

  lua_pushnumber(L, message_id);

  return 1;
}

/* statusbar_pop(statusbar, context) */
static int lgtk_statusbar_pop(lua_State *L)
{
  CHECK_UDATA(L, 1);
  GtkStatusbar *sb     = GET_UDATA(L, 1);
  const gchar *context = luaL_checkstring(L, 2);

  guint context_id = gtk_statusbar_get_context_id(sb, context);
  gtk_statusbar_pop(sb, context_id);

  return 0;
}

/* statusbar_remove(statusbar, context, message_id) */
static int lgtk_statusbar_remove(lua_State *L)
{
  CHECK_UDATA(L, 1);
  GtkStatusbar *sb       = GET_UDATA(L, 1);
  const gchar *context   = luaL_checkstring(L, 2);
  const guint message_id = luaL_checknumber(L, 3);

  guint context_id = gtk_statusbar_get_context_id(sb, context);
  gtk_statusbar_remove(sb, context_id, message_id);

  return 0;
}

/**/

/* main_iteration_do(blocking) */
static int lgtk_main_iteration_do(lua_State *L)
{
  gboolean blocking=lua_toboolean(L, 1);

  gtk_main_iteration_do(blocking);

  return 0;
}

/**/

/* colorize(widget, r, g, b) */
static int lgtk_colorize(lua_State *L)
{
  CHECK_UDATA(L, 1);
  GtkWidget* w = GET_UDATA(L, 1);
  guint16 r=luaL_checknumber(L, 2);
  guint16 g=luaL_checknumber(L, 3);
  guint16 b=luaL_checknumber(L, 4);

  if(w) 
    colorize(w,r,g,b);

  return 0;
}

/**/

/* widget_grab_focus(widget) (XXX jur) */
static int lgtk_widget_grab_focus(lua_State *L)
{
  CHECK_UDATA(L, 1);
  GtkWidget* w = GET_UDATA(L, 1);

  if(w) 
    gtk_widget_grab_focus(w);

  return 0;
}

/**/

/* window_set_keep_above(window, setting) (XXX jur) */
static int lgtk_window_set_keep_above(lua_State *L)
{
  CHECK_UDATA(L, 1);
  //GtkWindow* w = GET_UDATA(L, 1);
  GtkWidget* w = GET_UDATA(L, 1);
  gboolean setting=lua_toboolean(L, 2);
  
  /*if(w && setting) */
    gtk_window_set_keep_above( GTK_WINDOW(w), setting );

  return 0;
}

/**/

/* window_set_transient_for(window, (parent)) (XXX jur) */
static int lgtk_window_set_transient_for(lua_State *L)
{
  CHECK_UDATA(L, 1);
  //GtkWindow* w = GET_UDATA(L, 1);
  GtkWidget* w = GET_UDATA(L, 1);

  GdkScreen *screen;
  GdkWindow *root;
  
  screen = gdk_screen_get_default();
  root = gdk_screen_get_root_window(screen);

  //gtk_window_set_transient_for(w->window, root);
  //gtk_window_set_transient_for(GTK_WINDOW(w->window), GTK_WINDOW(root));
  gdk_window_set_transient_for(w->window, root);

  return 0;
}

/**/

/* window_set_opacity(GtkWindow *window, gdouble opacity) (XXX jur) */
static int lgtk_window_set_opacity(lua_State *L)
{
  CHECK_UDATA(L, 1);
  //GtkWindow* w = GET_UDATA(L, 1);
  GtkWidget* w = GET_UDATA(L, 1);
  gdouble opacity=lua_tonumber(L, 2);

  gtk_window_set_opacity(GTK_WINDOW(w), opacity);

  return 0;
}

/**/

static const luaL_reg gtk[] = {
  { "bin_get_child",       lgtk_bin_get_child },
  { "object_destroy",      lgtk_object_destroy },
  { "statusbar_push",      lgtk_statusbar_push },
  { "statusbar_pop",       lgtk_statusbar_pop },
  { "statusbar_remove",    lgtk_statusbar_remove },
  { "main_iteration_do",   lgtk_main_iteration_do },
  { "colorize",            lgtk_colorize },
  { "widget_grab_focus",   lgtk_widget_grab_focus },
  { "window_set_keep_above",    lgtk_window_set_keep_above },
  { "window_set_transient_for", lgtk_window_set_transient_for },
  { "window_set_opacity", lgtk_window_set_opacity },
  { NULL, NULL }
};

LUALIB_API int luaopen_gtk(lua_State *L)
{
  gtk_bindings(L);
  luaL_register(L, LUA_GTKNAME, gtk);
  return 1;
}
