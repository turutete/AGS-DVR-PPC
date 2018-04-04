/*
 * Stateflow code generation for chart:
 *    sz4/Ventilador
 * 
 * Target Name                          : AGS
 * Stateflow Version                    : 6.1.0.14.00.0.000000
 * Date of code generation              : 20-Oct-2006 11:16:50
 */

/* Include files */
#include "sz_AGS.h"
#include "sz_ventiladores.h"

/* Type Definitions */

/* Named Constants */
#define IN_CONTROL                      (1)
#define IN_OFF                          (1)
#define IN_ON                           (2)
#define OFF                             (0)
#define ON                              (1)

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */

/* Function Definitions */
void c2_sz4(SFc2_sz4InstanceStruct *chartInstance, SFc2_sz4InputDataStruct
 *chartInputData, SFc2_sz4OutputDataStruct *
 chartOutputData)
{
  int32_T inct;
  if(chartInstance->is_active_c2_sz4 == 0) {
    chartInstance->is_active_c2_sz4 = 1;
    chartInstance->is_c2_sz4 = (uint8_T)IN_CONTROL;
    chartInstance->tp = 0;
    chartInstance->tant = chartInputData->t;
    chartOutputData->Salida = OFF;
    chartInstance->is_CONTROL = (uint8_T)IN_OFF;
  } else {
    inct = chartInputData->t - chartInstance->tant;
    chartInstance->tant = chartInputData->t;
    switch(chartInstance->is_CONTROL) {
     case IN_OFF:
      if((chartInputData->Ta >= chartInputData->TaOn) || (chartInstance->tp >=
        chartInputData->TPer)) {
        chartInstance->is_CONTROL = (uint8_T)IN_ON;
        chartInstance->tp = 0;
        chartInstance->ton = 0;
      } else {
        chartInstance->tp += inct;
        chartOutputData->Salida = OFF;
      }
      break;
     case IN_ON:
      if((chartInputData->Ta < chartInputData->TaOff) && (chartInstance->ton >=
        chartInputData->TOn)) {
        chartInstance->is_CONTROL = (uint8_T)IN_OFF;
      } else {
        chartInstance->ton += inct;
        chartOutputData->Salida = ON;
      }
      break;
    }
  }
}

