/*
 * Stateflow code generation for chart:
 *    sz4/Maniobra
 * 
 * Target Name                          : AGS
 * Stateflow Version                    : 6.1.0.14.00.0.000000
 * Date of code generation              : 20-Oct-2006 11:16:50
 */

/* Include files */
#include "sz_AGS.h"
#include "sz_maniobra.h"

/* Type Definitions */

/* Named Constants */
#define IN_NO_ACTIVE_CHILD              (0)
#define IN_MPPT2                        (5)
#define IN_INICIO                       (1)
#define IN_CICLO                        (1)
#define IN_FALLO                        (3)
#define IN_EMERGENCIA                   (2)
#define IN_RESET                        (2)
#define IN_CONTROL                      (1)
#define IN_PARADA                       (2)
#define IN_ESPERA1                      (2)
#define IN_ARRANQUE                     (1)
#define IN_MPPT1                        (4)
#define IN_ESPERA2                      (3)
#define IN_MARCHA                       (1)
#define E_CONV_ON                       (4)
#define E_CONV_PARO_ERROR               (8)
#define E_CONV_OFF                      (1)
#define ON                              (1)
#define OFF                             (0)
#define E_ESPERA1                       (1)
#define E_PARADA                        (0)
#define E_ESPERA2                       (2)
#define E_ARRANQUE                      (3)
#define E_MPPT1                         (4)
#define E_MPPT2                         (5)
#define E_EMERGENCIA                    (6)
#define E_FALLO                         (7)
#define ERR_TOUT                        (1)
#define ERROR_GRAVE                     (1)
#define ERROR_SEVERO                    (2)

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */

/* Function Definitions */
void c1_sz4(SFc1_sz4InstanceStruct *chartInstance, SFc1_sz4InputDataStruct
 *chartInputData, SFc1_sz4OutputDataStruct *
 chartOutputData)
{
  int32_T inct;
  if(chartInstance->is_active_c1_sz4 == 0) {
    chartInstance->is_active_c1_sz4 = 1;
    chartInstance->is_c1_sz4 = (uint8_T)IN_CONTROL;
    chartInstance->tant = chartInputData->t;
    chartOutputData->Marcha = 0;
    chartOutputData->Paro = 1;
    chartOutputData->RError = 0;
    chartInstance->is_active_MANIOBRA = 1;
    chartInstance->is_MANIOBRA = (uint8_T)IN_CICLO;
    chartInstance->is_CICLO = (uint8_T)IN_PARADA;
  } else {
    inct = chartInputData->t - chartInstance->tant;
    chartInstance->tant = chartInputData->t;
    switch(chartInstance->is_MANIOBRA) {
     case IN_CICLO:
      if(chartInputData->Error == ERROR_GRAVE) {
        chartInstance->is_MARCHA = (uint8_T)IN_NO_ACTIVE_CHILD;
        chartInstance->is_CICLO = (uint8_T)IN_NO_ACTIVE_CHILD;
        chartInstance->is_MANIOBRA = (uint8_T)IN_FALLO;
        chartInstance->is_FALLO = (uint8_T)IN_RESET;
        chartOutputData->Marcha = 0;
        chartOutputData->Paro = 1;
        chartOutputData->RError = 1;
        chartOutputData->Estado = E_FALLO;
      } else if(chartInputData->Error == ERROR_SEVERO) {
        chartInstance->is_MARCHA = (uint8_T)IN_NO_ACTIVE_CHILD;
        chartInstance->is_CICLO = (uint8_T)IN_NO_ACTIVE_CHILD;
        chartInstance->is_MANIOBRA = (uint8_T)IN_EMERGENCIA;
        chartInstance->is_EMERGENCIA = (uint8_T)IN_RESET;
        chartOutputData->Marcha = 0;
        chartOutputData->Paro = 1;
        chartOutputData->RError = 1;
        chartOutputData->Estado = E_EMERGENCIA;
      } else {
        switch(chartInstance->is_CICLO) {
         case IN_MARCHA:
          if((chartInputData->IntOnOff == 0) || (chartInputData->ContMedDC ==
            OFF)) {
            chartInstance->is_MARCHA = (uint8_T)IN_NO_ACTIVE_CHILD;
            chartInstance->is_CICLO = (uint8_T)IN_PARADA;
          } else {
            switch(chartInstance->is_MARCHA) {
             case IN_ARRANQUE:
              if(chartInstance->t1 > 60000) {
                chartOutputData->ErrorS = ERR_TOUT;
                chartInstance->is_MARCHA = (uint8_T)IN_ARRANQUE;
                chartInstance->t1 = 0;
              } else if((chartInstance->t1 > chartInputData->TEsperaDSP) &&
               (chartInputData->EstadoConv == E_CONV_ON)) {
                chartInstance->is_MARCHA = (uint8_T)IN_MPPT1;
              } else {
                chartInstance->t1 += inct;
                chartOutputData->Marcha = 1;
                chartOutputData->Paro = 0;
                chartOutputData->RError = 0;
                chartOutputData->Estado = E_ARRANQUE;
              }
              break;
             case IN_ESPERA1:
              if((chartInputData->UpvRad >= chartInputData->UpvRadArranque) &&
               (chartInstance->t1 > chartInstance->tesp)) {
                chartInstance->is_MARCHA = (uint8_T)IN_ESPERA2;
                chartInstance->t1 = 0;
              } else {
                chartInstance->t1 += inct;
                chartOutputData->Marcha = 0;
                chartOutputData->Paro = 1;
                chartOutputData->RError = 0;
                chartOutputData->ErrorS = 0;
                chartOutputData->Estado = E_ESPERA1;
              }
              break;
             case IN_ESPERA2:
              if(chartInstance->t1 > chartInputData->TArranque) {
                chartInstance->is_MARCHA = (uint8_T)IN_ARRANQUE;
                chartInstance->t1 = 0;
              } else if(chartInputData->UpvRad < chartInputData->UpvRadEspera) {
                chartInstance->tesp = 0;
                chartInstance->is_MARCHA = (uint8_T)IN_ESPERA1;
                chartInstance->t1 = 0;
              } else {
                chartInstance->t1 += inct;
                chartOutputData->Marcha = 0;
                chartOutputData->Paro = 1;
                chartOutputData->RError = 0;
                chartOutputData->Estado = E_ESPERA2;
              }
              break;
             case IN_MPPT1:
              if(chartInputData->PAc < chartInputData->PParadaL) {
                chartInstance->is_MARCHA = (uint8_T)IN_MPPT2;
                chartInstance->t1 = 0;
              } else {
                chartOutputData->Marcha = 1;
                chartOutputData->Paro = 0;
                chartOutputData->RError = 0;
                chartOutputData->Estado = E_MPPT1;
              }
              break;
             case IN_MPPT2:
              if(chartInputData->PAc >= chartInputData->PParadaH) {
                chartInstance->is_MARCHA = (uint8_T)IN_MPPT1;
              } else if(chartInstance->t1 > chartInputData->TParada) {
                chartInstance->tesp = chartInputData->TEspera;
                chartInstance->is_MARCHA = (uint8_T)IN_ESPERA1;
                chartInstance->t1 = 0;
              } else {
                chartOutputData->Marcha = 1;
                chartOutputData->Paro = 0;
                chartOutputData->RError = 0;
                chartInstance->t1 += inct;
                chartOutputData->Estado = E_MPPT2;
              }
              break;
            }
          }
          break;
         case IN_PARADA:
          if((chartInputData->IntOnOff == 1) && (chartInputData->EstadoConv ==
            E_CONV_OFF) && (chartInputData->ContMedDC == ON)) {
            chartInstance->is_CICLO = (uint8_T)IN_MARCHA;
            chartInstance->tesp = 0;
            chartInstance->is_MARCHA = (uint8_T)IN_ESPERA1;
            chartInstance->t1 = 0;
          } else {
            chartOutputData->Marcha = 0;
            chartOutputData->Paro = 1;
            chartOutputData->RError = 0;
            chartOutputData->Estado = E_PARADA;
          }
          break;
        }
      }
      break;
     case IN_EMERGENCIA:
      if(chartInputData->Error != ERROR_SEVERO) {
        chartInstance->is_EMERGENCIA = (uint8_T)IN_NO_ACTIVE_CHILD;
        chartInstance->is_MANIOBRA = (uint8_T)IN_CICLO;
        chartInstance->is_CICLO = (uint8_T)IN_PARADA;
      } else {
        switch(chartInstance->is_EMERGENCIA) {
         case IN_INICIO:
          if(chartInputData->EstadoConv == E_CONV_PARO_ERROR) {
            chartInstance->is_EMERGENCIA = (uint8_T)IN_RESET;
            chartOutputData->Marcha = 0;
            chartOutputData->Paro = 1;
            chartOutputData->RError = 1;
            chartOutputData->Estado = E_EMERGENCIA;
          }
          break;
         case IN_RESET:
          chartInstance->is_EMERGENCIA = (uint8_T)IN_INICIO;
          chartOutputData->Marcha = 0;
          chartOutputData->Paro = 1;
          chartOutputData->RError = 0;
          chartOutputData->Estado = E_EMERGENCIA;
          break;
        }
      }
      break;
     case IN_FALLO:
      if(chartInputData->Error != ERROR_GRAVE) {
        chartInstance->is_FALLO = (uint8_T)IN_NO_ACTIVE_CHILD;
        chartInstance->is_MANIOBRA = (uint8_T)IN_CICLO;
        chartInstance->is_CICLO = (uint8_T)IN_PARADA;
      } else {
        switch(chartInstance->is_FALLO) {
         case IN_INICIO:
          if(chartInputData->EstadoConv == E_CONV_PARO_ERROR) {
            chartInstance->is_FALLO = (uint8_T)IN_RESET;
            chartOutputData->Marcha = 0;
            chartOutputData->Paro = 1;
            chartOutputData->RError = 1;
            chartOutputData->Estado = E_FALLO;
          }
          break;
         case IN_RESET:
          chartInstance->is_FALLO = (uint8_T)IN_INICIO;
          chartOutputData->Marcha = 0;
          chartOutputData->Paro = 1;
          chartOutputData->RError = 0;
          chartOutputData->Estado = E_FALLO;
          break;
        }
      }
      break;
    }
  }
}

