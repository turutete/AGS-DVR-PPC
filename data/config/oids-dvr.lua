require "oids-zigor"

zigorDvrMIB = zigorExperiment..".10"
zigorDvrObjects = zigorDvrMIB..".1"
--
-- Variables de estado
--
zigorDvrObjEstado = zigorDvrObjects..".1"

zigorDvrObjVRedR = zigorDvrObjEstado..".1"
zigorDvrObjVRedS = zigorDvrObjEstado..".2"
zigorDvrObjVRedT = zigorDvrObjEstado..".3"
zigorDvrObjVSecundarioR = zigorDvrObjEstado..".4"
zigorDvrObjVSecundarioS = zigorDvrObjEstado..".5"
zigorDvrObjVSecundarioT = zigorDvrObjEstado..".6"
zigorDvrObjISecundarioR = zigorDvrObjEstado..".7"
zigorDvrObjISecundarioS = zigorDvrObjEstado..".8"
zigorDvrObjISecundarioT = zigorDvrObjEstado..".9"
zigorDvrObjPSalidaR = zigorDvrObjEstado..".10"
zigorDvrObjPSalidaS = zigorDvrObjEstado..".11"
zigorDvrObjPSalidaT = zigorDvrObjEstado..".12"
--
zigorDvrObjEstadoControl = zigorDvrObjEstado..".13"
--
zigorDvrObjAlarmaDriver = zigorDvrObjEstado..".14"
zigorDvrObjParado = zigorDvrObjEstado..".15"
zigorDvrObjErrorVInst = zigorDvrObjEstado..".16"
zigorDvrObjSaturado = zigorDvrObjEstado..".17"
zigorDvrObjPwmOndOn = zigorDvrObjEstado..".18"
zigorDvrObjBypassOn = zigorDvrObjEstado..".19"
zigorDvrObjErrorDriver = zigorDvrObjEstado..".20"
zigorDvrObjPwmRecOn = zigorDvrObjEstado..".21"
zigorDvrObjDeteccionEnable = zigorDvrObjEstado..".22"
zigorDvrObjAlarmaVBusMax = zigorDvrObjEstado..".23"
zigorDvrObjAlarmaVCondMax = zigorDvrObjEstado..".24"
zigorDvrObjAlarmaVBusMin = zigorDvrObjEstado..".25"
zigorDvrObjAlarmaVRed = zigorDvrObjEstado..".26"
zigorDvrObjErrorTermo = zigorDvrObjEstado..".27"
zigorDvrObjErrorPLL = zigorDvrObjEstado..".28"
zigorDvrObjAlarmaPLL = zigorDvrObjEstado..".29"
zigorDvrObjParadoError = zigorDvrObjEstado..".30"
--
zigorDvrObjOrdenMarcha = zigorDvrObjEstado..".31"
zigorDvrObjOrdenParo = zigorDvrObjEstado..".32"
zigorDvrObjOrdenReset = zigorDvrObjEstado..".33"
--
zigorDvrObjLimitando = zigorDvrObjEstado..".34"
zigorDvrObjEComDSP = zigorDvrObjEstado..".35"
zigorDvrObjVBus = zigorDvrObjEstado..".36"
zigorDvrObjLimitIntVSal = zigorDvrObjEstado..".37"
--
zigorDvrObjGapMinimo = zigorDvrObjEstado..".38"
zigorDvrObjGapIntegral = zigorDvrObjEstado..".39"
zigorDvrObjGapTiempo = zigorDvrObjEstado..".40"
zigorDvrObjGapFase = zigorDvrObjEstado..".41"
--
zigorDvrObjErrorFusCondAC = zigorDvrObjEstado..".42"
zigorDvrObjRegHueco = zigorDvrObjEstado..".43"
zigorDvrObjResetDriver = zigorDvrObjEstado..".44"

zigorDvrObjVRedNom = zigorDvrObjEstado..".45"

zigorDvrObjModemStatus = zigorDvrObjEstado..".46"

zigorDvrObjErrorTemp = zigorDvrObjEstado..".47"

--
-- Parametros Sistema
--
zigorDvrObjParams = zigorDvrObjects..".2"

zigorDvrParamVRedNom = zigorDvrObjParams..".1"
zigorDvrParamVMinDVR = zigorDvrObjParams..".2"
zigorDvrParamNumEquipos = zigorDvrObjParams..".3"
zigorDvrParamFactor = zigorDvrObjParams..".4"
zigorDvrParamFrecNom = zigorDvrObjParams..".5"
--
-- Alarmas
--
zigorDvrAlarms = zigorDvrMIB..".2"

zigorAlarmaErrorVInst = zigorDvrAlarms..".1"
zigorAlarmaSaturado = zigorDvrAlarms..".2"
zigorAlarmaVBusMax = zigorDvrAlarms..".3"
zigorAlarmaVCondMax = zigorDvrAlarms..".4"
zigorAlarmaVBusMin = zigorDvrAlarms..".5"
zigorAlarmaVRed = zigorDvrAlarms..".6"
zigorAlarmaLimitIntVSal = zigorDvrAlarms..".7"
zigorAlarmaDriver = zigorDvrAlarms..".8"
zigorAlarmaParadoError = zigorDvrAlarms..".9"
zigorAlarmaErrorDriver = zigorDvrAlarms..".10"
zigorAlarmaErrorTermo = zigorDvrAlarms..".11"
zigorAlarmaLimitando = zigorDvrAlarms..".12"
zigorAlarmaPLL = zigorDvrAlarms..".13"
zigorAlarmaErrorComDSP = zigorDvrAlarms..".14"
zigorAlarmaStatusChange = zigorDvrAlarms..".15"
zigorAlarmaTemperaturaAlta = zigorDvrAlarms..".16"
zigorAlarmaSagRecorded = zigorDvrAlarms..".17"

-- gaplog:
zigorDvrGapLog = zigorDvrMIB..".3"

zigorDvrGapLogTotalEntries = zigorDvrGapLog..".1"
zigorDvrGapLogMaxEntries = zigorDvrGapLog..".2"
zigorDvrGapLogQueueWraps = zigorDvrGapLog..".3"
zigorDvrGapLogIndex = zigorDvrGapLog..".4"
zigorDvrGapLogTable = zigorDvrGapLog..".5"
zigorDvrGapLogEntry = zigorDvrGapLogTable..".1"
zigorDvrGapLogId = zigorDvrGapLogEntry..".1"
zigorDvrGapLogTime = zigorDvrGapLogEntry..".2"
zigorDvrGapLogMinimo = zigorDvrGapLogEntry..".3"
zigorDvrGapLogIntegral = zigorDvrGapLogEntry..".4"
zigorDvrGapLogTiempo = zigorDvrGapLogEntry..".5"
zigorDvrGapLogFase = zigorDvrGapLogEntry..".6"

zigorDvrGapLogTraps = zigorDvrMIB..".4"
zigorTrapDvrGapLogEntryAdded = zigorDvrGapLogTraps..".1"
