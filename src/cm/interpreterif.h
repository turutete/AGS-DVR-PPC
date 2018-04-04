#ifndef INTERPRETERIF_H

#include <glib-2.0/glib-object.h>
#include <ags-cf.h>

#define INTERPRETERIF_H

#define TYPE_INTERPRETERIF	 (interpreter_if_get_type ())
#define INTERPRETERIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_INTERPRETERIF, InterpreterIf))
#define IS_INTERPRETERIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_INTERPRETERIF))
#define INTERPRETERIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_INTERPRETERIF, InterpreterIfIface))
                                                                                           
typedef struct _InterpreterIf	InterpreterIf;
typedef struct _InterpreterIfIface InterpreterIfIface;

struct _InterpreterIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  GValue* (*run)    (InterpreterIf* self, gchar* text, gint len, gchar* name, AgsCf* cf, CfTable cft);
  void    (*stream) (InterpreterIf* self, GIOChannel* io);
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup interpreterif interpreterif
 * \ingroup interfaces
 */
/*@{*/
GType interpreter_if_get_type (void);

inline GValue* interpreter_run    (InterpreterIf* self, gchar* text, gint len, gchar* name, AgsCf* cf, CfTable cft);
inline void    interpreter_stream (InterpreterIf* self, GIOChannel *io);
/*@}*/


#endif /* INTERPRETERIF_H */
