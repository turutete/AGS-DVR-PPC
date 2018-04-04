loadlualib("gobject") -- G_TYPE_*

-- XXX
-- Definiciones de Constantes
--
TruthValueFALSE=2
TruthValueTRUE=1

--
-- Definiciones Bus Zigor
--
-- XXX
COD_INT =0
COD_UINT=1
COD_INT_LE=2
COD_UINT_LE=3

-- Mapeo de flag (0/1=falso/verdadero) a booleano de MIB (1/2=verdadero/falso)
boolmap = {
   -- verdadero se queda igual
   falso = { from = 0, to = 2 },
}


tipo_objeto_dsp = {
   --Objetos DSP
   Estado = {
      EstadoControl       = { start = 24, len =  8, cod = COD_UINT, type = G_TYPE_INT, offset=1        },
      Parado              = { start = 47, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },  
      ErrorVInst          = { start = 46, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },  
      Saturado            = { start = 45, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      PwmOndOn            = { start = 44, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },	
--    BypassOn            = { start = 43, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      TirBypassOn         = { start = 42, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      PwmRecOn            = { start = 41, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      DeteccionEnable     = { start = 40, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      AlarmaVBusMax       = { start = 39, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      AlarmaVCondMax      = { start = 38, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },	  
      AlarmaVBusMin       = { start = 37, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      AlarmaVRed          = { start = 36, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },	 
      LimitIntVSal        = { start = 35, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      ErrorPLL            = { start = 34, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      AlarmaDriver        = { start = 33, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, }, 
      ParadoError         = { start = 32, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },     
      --
      ErrorDriver         = { start = 63, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      ErrorTermo          = { start = 62, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      Limitando           = { start = 61, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      ErrorFusible        = { start = 60, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      RegHueco            = { start = 59, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      AlarmaPLL           = { start = 58, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      ResetDriver         = { start = 57, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
--    TA3                 = { start = 56, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
--    TB3                 = { start = 55, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
   },
   VRed = {
      VRedR                = { start =  0, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      VRedS                = { start = 16, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      VRedT                = { start = 32, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      VBus                 = { start = 48, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
   },
   VSec = {
      VSecundarioR         = { start =  0, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      VSecundarioS         = { start = 16, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      VSecundarioT         = { start = 32, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
   },
   ISec = {
      ISecundarioR         = { start =  0, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      ISecundarioS         = { start = 16, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      ISecundarioT         = { start = 32, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
   },     
   PSal = {
      PSalidaR             = { start =  0, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      PSalidaS             = { start = 16, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      PSalidaT             = { start = 32, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
   },     
   Hueco = {
      Minimo               = { start =  0, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      Integral             = { start = 16, len = 16, cod = COD_INT, type = G_TYPE_INT,                 },
      Tiempo               = { start = 32, len = 16, cod = COD_UINT, type = G_TYPE_INT,                },
      Fase                 = { start = 48, len = 16, cod = COD_INT, type = G_TYPE_INT, offset=1        },
   },     
   -- Objetos Consola (nodo embedded)
   Actua = {
      Marcha               = { start = 15, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      Paro                 = { start = 14, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
      Reset                = { start = 13, len =  1, cod = COD_UINT, type = G_TYPE_INT, maps = boolmap, },
   },
}
