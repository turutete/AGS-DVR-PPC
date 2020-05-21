require "oids-dvr"    -- OIDs dvr
require "alarmtable"  -- index_cond (XXX)
require "defs-dvr"    -- XXX definiciones de ctes

--
-- Factorías de funciones de evaluación de alarmas
--
local factory_ErrorVInst = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local ErrorVInst  = access.get(sds, zigorDvrObjErrorVInst .. ".0")
	   
	   if ErrorVInst==TruthValueTRUE then
	      return zigorAlarmaErrorVInst,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaErrorVInst,{}
	   end
	---
	end
     end
local factory_Saturado = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local Saturado  = access.get(sds, zigorDvrObjSaturado .. ".0")
	   
	   if Saturado==TruthValueTRUE then
	      return zigorAlarmaSaturado,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaSaturado,{}
	   end
	---
	end
     end
local factory_AlarmaVBusMax = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local AlarmaVBusMax  = access.get(sds, zigorDvrObjAlarmaVBusMax .. ".0")
	   
	   if AlarmaVBusMax==TruthValueTRUE then
	      return zigorAlarmaVBusMax,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaVBusMax,{}
	   end
	---
	end
     end
local factory_AlarmaVCondMax = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local AlarmaVCondMax  = access.get(sds, zigorDvrObjAlarmaVCondMax .. ".0")
	   
	   if AlarmaVCondMax==TruthValueTRUE then
	      return zigorAlarmaVCondMax,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaVCondMax,{}
	   end
	---
	end
     end
local factory_AlarmaVBusMin = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local AlarmaVBusMin  = access.get(sds, zigorDvrObjAlarmaVBusMin .. ".0")
	   
	   if AlarmaVBusMin==TruthValueTRUE then
	      return zigorAlarmaVBusMin,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaVBusMin,{}
	   end
	---
	end
     end
local factory_AlarmaVRed = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local AlarmaVRed  = access.get(sds, zigorDvrObjAlarmaVRed .. ".0")
	   
	   if AlarmaVRed==TruthValueTRUE then
	      return zigorAlarmaVRed,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaVRed,{}
	   end
	---
	end
     end
local factory_LimitIntVSal = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local LimitIntVSal  = access.get(sds, zigorDvrObjLimitIntVSal .. ".0")
	   
	   if LimitIntVSal==TruthValueTRUE then
	      return zigorAlarmaLimitIntVSal,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaLimitIntVSal,{}
	   end
	---
	end
     end
local factory_AlarmaDriver = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local AlarmaDriver  = access.get(sds, zigorDvrObjAlarmaDriver .. ".0")
	   
	   if AlarmaDriver==TruthValueTRUE then
	      return zigorAlarmaDriver,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaDriver,{}
	   end
	---
	end
     end
local factory_ParadoError = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local ParadoError  = access.get(sds, zigorDvrObjParadoError .. ".0")
	   
	   if ParadoError==TruthValueTRUE then
	      return zigorAlarmaParadoError,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaParadoError,{}
	   end
	---
	end
     end
local factory_ErrorDriver = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local ErrorDriver  = access.get(sds, zigorDvrObjErrorDriver .. ".0")
	   
	   if ErrorDriver==TruthValueTRUE then
	      return zigorAlarmaErrorDriver,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaErrorDriver,{}
	   end
	---
	end
     end
local factory_ErrorTermo = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local ErrorTermo  = access.get(sds, zigorDvrObjErrorTermo .. ".0")
	   
	   if ErrorTermo==TruthValueTRUE then
	      return zigorAlarmaErrorTermo,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaErrorTermo,{}
	   end
	---
	end
     end
local factory_Limitando = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local Limitando  = access.get(sds, zigorDvrObjLimitando .. ".0")
	   
	   if Limitando==TruthValueTRUE then
	      return zigorAlarmaLimitando,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaLimitando,{}
	   end
	---
	end
     end
local factory_ErrorFusible = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local ErrorFusible  = access.get(sds, zigorDvrObjErrorFusible .. ".0")
	   
	   if ErrorFusible==TruthValueTRUE then
	      return zigorAlarmaErrorFusible,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaErrorFusible,{}
	   end
	---
	end
     end
local factory_AlarmaPLL = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local AlarmaPLL  = access.get(sds, zigorDvrObjAlarmaPLL .. ".0")
	   
	   if AlarmaPLL==TruthValueTRUE then
	      return zigorAlarmaPLL,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaPLL,{}
	   end
	---
	end
     end
local factory_ErrorComDSP = function(sds)
	return
	function()
	   -- Variables "locales" de función
	   local EComDSP  = access.get(sds, zigorDvrObjEComDSP .. ".0")
	   
	   if EComDSP==TruthValueTRUE then
	      return zigorAlarmaErrorComDSP,{
	         ["1"] = true,  -- debemos especificar elementos aunque sea único
	      }
	   else
	      return zigorAlarmaErrorComDSP,{}
	   end
	---
	end
     end

local factory_AlarmaTemperatura = function(sds)
        return
        function()
           local FlagErrorTemp  = access.get(sds, zigorDvrObjErrorTemp .. ".0")

           if FlagErrorTemp==TruthValueTRUE then
              return zigorAlarmaTemperaturaAlta,{
                 ["1"] = true,
              }
           else
              return zigorAlarmaTemperaturaAlta,{}
           end
        ---
        end
     end

function alarms_dvr_new(sds)
   -- La tabla "alarms" contiene las funciones para evaluar las condiciones de alarmas, una función por alarma.
   -- También contiene los contadores de activación y desactivación.
   -- Cada función debe devolver _siempre_ 2 valores: descripción de alarma (OID) y elementos activos
   -- Si condición de alarma es activa(1), entonces elementos activos ~= {} (no puede ser tabla vacía).
   -- Si condición de alarma es inactiva(2), entonces elementos activos = {} (tabla vacía).
   local alarms = {
      ErrorVInst        = { f = factory_ErrorVInst(sds), ca = 5, cd = 5, },
      Saturado          = { f = factory_Saturado(sds), ca = 5, cd = 5, },
      AlarmaVBusMax     = { f = factory_AlarmaVBusMax(sds), ca = 5, cd = 5, },
      AlarmaVCondMax    = { f = factory_AlarmaVCondMax(sds), ca = 5, cd = 5, },
      AlarmaVBusMin     = { f = factory_AlarmaVBusMin(sds), ca = 5, cd = 5, },
      AlarmaVRed        = { f = factory_AlarmaVRed(sds), ca = 5, cd = 5, },
      LimitIntVSal      = { f = factory_LimitIntVSal(sds), ca = 5, cd = 5, },
      AlarmaDriver      = { f = factory_AlarmaDriver(sds), ca = 5, cd = 5, },
      ParadoError       = { f = factory_ParadoError(sds), ca = 5, cd = 5, },
      ErrorDriver       = { f = factory_ErrorDriver(sds), ca = 5, cd = 5, },
      ErrorTermo        = { f = factory_ErrorTermo(sds), ca = 5, cd = 5, },
      Limitando         = { f = factory_Limitando(sds), ca = 5, cd = 5, },
      ErrorFusible      = { f = factory_ErrorFusible(sds), ca = 5, cd = 5, },
      AlarmaPLL         = { f = factory_AlarmaPLL(sds), ca = 5, cd = 5, },
      ErrorComDSP       = { f = factory_ErrorComDSP(sds), ca = 5, cd = 5, },
      AlarmaTemperatura = { f = factory_AlarmaTemperatura(sds), ca = 5, cd = 5, },
   }

   return alarms
end
