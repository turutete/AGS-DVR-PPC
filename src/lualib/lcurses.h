#define LUA_CURSESNAME "curses"

#define MKLUALIB_META_CURSES_SCREEN "SCREEN*"
#define MKLUALIB_META_CURSES_WINDOW "WINDOW*"
#define MKLUALIB_META_CURSES_FILE "FILE*"

#define luacurses_mvwgetnstr(w, y, x, n) (wmove(w, y, x) == ERR ? 0 : luacurses_wgetnstr(w, n))
#define luacurses_getnstr(n) luacurses_wgetnstr(stdscr, n)
#define luacurses_mvgetnstr(y, x, n) luacurses_mvwgetnstr(stdscr, y, x, n)

#define luacurses_window_free(w) {delwin(w); w = 0;}
#define luacurses_screen_free(s) {delscreen(s); s = 0;}
