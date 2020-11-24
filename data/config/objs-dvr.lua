require "oids-dvr"
require "oids-parameter"


-- DAs e IDs siempre 2 carácteres hex y letras A-F mayúsculas
--
-- Bus Zigor DSP
--
DA_DSP          = "03"  --XXX >>> Gestora
DA_ETX_BUS_DSP  = "11"  --17 decimal >>> Consola (nodo embedded)


-- (identificadores en hex también)
--
-- Bus Zigor DSP
--
--DSP
ID_DSP_ESTADO   = "02"
ID_DSP_RED      = "11"  --17 decimal
ID_DSP_VSEC     = "16"  --22 decimal
ID_DSP_ISEC     = "12"  --18 decimal
ID_DSP_PSAL     = "13"  --19 decimal
ID_DSP_HUECO    = "17"  --23 decimal
--
--ETX
--ID_ETX_ACTUA    = "04"
ID_ETX_ACTUA    = "01"  --XXX, parece es este, verificar
--ID_ETX_BUF      = "05"
ID_ETX_BUF      = "0C"  --idem

-- (objetos por defecto: read=false, write=false)
--
-- Objetos Bus DSP
--
objects_dsp = {
   -- Objetos DSP (lectura)
   [ DA_DSP .. ID_DSP_ESTADO ] = {
      type = "Estado",
      binds = {
         [zigorDvrObjEstadoControl ..".0"    	] = "EstadoControl", 
	 [zigorDvrObjParado ..".0"		] = "Parado",
	 [zigorDvrObjErrorVInst ..".0"		] = "ErrorVInst",
	 [zigorDvrObjSaturado ..".0"		] = "Saturado",
	 [zigorDvrObjPwmOndOn ..".0"		] = "PwmOndOn",
--	 [zigorDvrObjBypassOn ..".0"		] = "BypassOn",
	 [zigorDvrObjBypassOn ..".0"		] = "TirBypassOn",
	 [zigorDvrObjPwmRecOn ..".0"		] = "PwmRecOn",
	 [zigorDvrObjDeteccionEnable ..".0"	] = "DeteccionEnable",
	 [zigorDvrObjAlarmaVBusMax ..".0"	] = "AlarmaVBusMax",
	 [zigorDvrObjAlarmaVCondMax ..".0"	] = "AlarmaVCondMax",
	 [zigorDvrObjAlarmaVBusMin ..".0"	] = "AlarmaVBusMin",
	 [zigorDvrObjAlarmaVRed ..".0"		] = "AlarmaVRed",
	 [zigorDvrObjLimitIntVSal ..".0"	] = "LimitIntVSal",
	 [zigorDvrObjErrorPLL ..".0"		] = "ErrorPLL",
	 [zigorDvrObjAlarmaDriver ..".0"	] = "AlarmaDriver",
	 [zigorDvrObjParadoError ..".0"		] = "ParadoError", 	 
--
	 [zigorDvrObjErrorDriver ..".0"		] = "ErrorDriver",
	 [zigorDvrObjErrorTermo ..".0"	        ] = "ErrorTermo",
	 [zigorDvrObjLimitando ..".0"	        ] = "Limitando",
	 [zigorDvrObjErrorFusCondAC ..".0"	] = "ErrorFusCondAC",
	 [zigorDvrObjRegHueco ..".0"	        ] = "RegHueco",
	 [zigorDvrObjAlarmaPLL ..".0"		] = "AlarmaPLL",
	 [zigorDvrObjResetDriver ..".0"	        ] = "ResetDriver",
	 [zigorDvrObjErrorTemp ..".0"           ] = "ErrorTemp",
      },
      read = true,
   },
   [ DA_DSP .. ID_DSP_RED ] = {
      type = "VRed",
      binds = {
	 [ zigorDvrObjVRedR .. ".0"             ] = "VRedR",
	 [ zigorDvrObjVRedS .. ".0"             ] = "VRedS",
	 [ zigorDvrObjVRedT .. ".0"             ] = "VRedT",
	 [ zigorDvrObjVBus .. ".0"              ] = "VBus",
      },
      read = true,
   },
   [ DA_DSP .. ID_DSP_VSEC ] = {
      type = "VSec",
      binds = {
	 [ zigorDvrObjVSecundarioR .. ".0"      ] = "VSecundarioR",
	 [ zigorDvrObjVSecundarioS .. ".0"      ] = "VSecundarioS",
	 [ zigorDvrObjVSecundarioT .. ".0"      ] = "VSecundarioT",
      },
      read = true,
   },
   [ DA_DSP .. ID_DSP_ISEC ] = {
      type = "ISec",
      binds = {
	 [ zigorDvrObjISecundarioR .. ".0"      ] = "ISecundarioR",
	 [ zigorDvrObjISecundarioS .. ".0"      ] = "ISecundarioS",
	 [ zigorDvrObjISecundarioT .. ".0"      ] = "ISecundarioT",
      },
      read = true,
   },
   [ DA_DSP .. ID_DSP_PSAL ] = {
      type = "PSal",
      binds = {
	 [ zigorDvrObjPSalidaR .. ".0"          ] = "PSalidaR",
	 [ zigorDvrObjPSalidaS .. ".0"          ] = "PSalidaS",
	 [ zigorDvrObjPSalidaT .. ".0"          ] = "PSalidaT",
      },
      read = true,
   }, 
   [ DA_DSP .. ID_DSP_HUECO ] = {
      type = "Hueco",
      binds = {
	 [ zigorDvrObjGapMinimo .. ".0"            ] = "Minimo",
	 [ zigorDvrObjGapIntegral .. ".0"          ] = "Integral",
	 [ zigorDvrObjGapTiempo .. ".0"            ] = "Tiempo",
	 [ zigorDvrObjGapFase .. ".0"              ] = "Fase",
      },
      read = true,
   }, 
   
   -- Objetos Consola (escritura)
   [ DA_ETX_BUS_DSP .. ID_ETX_ACTUA ] = {
      type = "Actua",
      binds = {
	 [ zigorDvrObjOrdenMarcha .. ".0"       ] = "Marcha",
	 [ zigorDvrObjOrdenParo .. ".0"         ] = "Paro",
	 [ zigorDvrObjOrdenReset .. ".0"        ] = "Reset",
      },
      write = true,
   },
}
