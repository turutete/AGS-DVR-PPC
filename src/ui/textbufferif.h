#ifndef TEXTBUFFERIF_H

#include <glib-2.0/glib-object.h>
#include <ags-cf.h>

#define TEXTBUFFERIF_H

#define TYPE_TEXTBUFFERIF	 (textbuffer_if_get_type ())
#define TEXTBUFFERIF(obj)	 (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_TEXTBUFFERIF, TextbufferIf))
#define IS_TEXTBUFFERIF(obj)	 (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_TEXTBUFFERIF))
#define TEXTBUFFERIF_GET_IFACE(obj)	 (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_TEXTBUFFERIF, TextbufferIfIface))
                                                                                           
typedef struct _TextbufferIf	TextbufferIf;
typedef struct _TextbufferIfIface TextbufferIfIface;

struct _TextbufferIfIface {
  GTypeInterface g_iface;
  
  /*< vtable >*/
  gchar* (*get) (TextbufferIf* self, gint* len);
  void   (*set) (TextbufferIf* self, const gchar* text, gint len);
};

/**
 * \addtogroup interfaces interfaces
 */

/** \defgroup textbufferif textbufferif
 * \ingroup interfaces
 */
/*@{*/
GType textbuffer_if_get_type (void);

inline gchar*  textbuffer_get   (TextbufferIf* self, gint* len);
inline void    textbuffer_set   (TextbufferIf* self, const gchar* text, gint len);
/*@}*/


#endif /* TEXTBUFFERIF_H */
