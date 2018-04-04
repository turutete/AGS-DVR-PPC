require "oids-zigor"

zigorAlarmMIB = zigorExperiment..".5"
zigorAlarm = zigorAlarmMIB..".1"
zigorAlarmsPresent = zigorAlarm..".1"
zigorAlarmTable = zigorAlarm..".2"
zigorAlarmEntry = zigorAlarmTable..".1"
zigorAlarmId = zigorAlarmEntry..".1"
zigorAlarmDescr = zigorAlarmEntry..".2"
zigorAlarmTime = zigorAlarmEntry..".3"
zigorAlarmElementList = zigorAlarmEntry..".4"
zigorAlarmCondition = zigorAlarmEntry..".5"
--
-- Configuracion alarmas
--
zigorAlarmConfig = zigorAlarmMIB..".2"
zigorAlarmsCfgPresent = zigorAlarmConfig..".1"
zigorAlarmCfgTable = zigorAlarmConfig..".2"
zigorAlarmCfgEntry = zigorAlarmCfgTable..".1"
zigorAlarmCfgId = zigorAlarmCfgEntry..".1"
zigorAlarmCfgDescr = zigorAlarmCfgEntry..".2"
zigorAlarmCfgSeverity = zigorAlarmCfgEntry..".3"
zigorAlarmCfgNotification = zigorAlarmCfgEntry..".4"

--

AlarmSeverityLEVE = 1
AlarmSeverityPERSISTENTE = 2
AlarmSeverityGRAVE = 3
AlarmSeveritySEVERA = 4
AlarmSeverityNOURGENTE = 5
AlarmSeverityURGENTE = 6

--

AlarmNotificationSMS   = 1
AlarmNotificationNOSMS = 2

--

zigorSysAlarms = zigorAlarmMIB..".3"
zigorAlarmaStart = zigorSysAlarms..".1"
zigorAlarmaPasswdChange = zigorSysAlarms..".2"
