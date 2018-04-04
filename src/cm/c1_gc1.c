/*
 * Stateflow code generation for chart:
 *    gc1/Chart
 * 
 * Target Name                          : AGS
 * Stateflow Version                    : 6.1.0.14.00.0.000000
 * Date of code generation              : 02-Oct-2006 12:01:34
 */

/* Include files */
#include "gc1_AGS.h"
#include "c1_gc1.h"
#include <stdio.h>

/* Type Definitions */

/* Named Constants */
#define IN_NO_ACTIVE_CHILD              (0)
#define IN_CICLO                        (1)
#define IN_DESCARGA                     (2)
#define IN_REPLAY                       (3)
#define IN_FLOTACION                    (4)
#define IN_RECUPERACION                 (5)
#define IN_CARGA                        (6)
#define IN_GCARGA                       (7)
#define IN_TEST                         (8)

// Tiempo de filtrado de la condición de salida de test por corriente de utilización mínima (segundos).
#define T_FILTRO_IUTI_FIN_TEST					60

/* Variable Declarations */

/* Variable Definitions */
static SFc1_gc1InstanceStruct chartInstance;

/* Function Declarations */

/* Function Definitions */
void c1_gc1_inicia(void)
{

  chartInstance.TCarga = 0;
  chartInstance.TNoCarga = 0;
  chartInstance.TRecup = 0;
  chartInstance.TTest = 0;
  chartInstance.tant = 0;
  chartInstance.is_CICLO = (uint8_T)IN_CARGA;
  chartInstance.is_GCARGA = (uint8_T)IN_CICLO;
  chartInstance.is_active_c1_gc1 = (uint8_T)IN_GCARGA;
  chartInstance.is_c1_gc1 = (uint8_T)IN_GCARGA;
//  printf("c1_gc1 -> FC: Reset\n");
}

void c1_gc1(SFc1_gc1InputDataStruct *chartInputData, SFc1_gc1OutputDataStruct
 *chartOutputData)
{
  int32_T inct;
  
  printf("c1_gc1-> VBat: %d, IBat: %d, IUti: %d, Descarga: %d, t: %d\n", chartInputData->VBat, chartInputData->IBat, chartInputData->IUti, chartInputData->Descarga, chartInputData->t);fflush(0);
  printf("c1_gc1-> CBatIniCarga: %d, TPerCarga: %d, VBatFC: %d, IBatCola: %d, IUtiTestMin: %d\n", chartInputData->CBatIniCarga, chartInputData->TPerCarga, chartInputData->VBatFC, chartInputData->IBatCola, chartInputData->IUtiTestMin);fflush(0);
  printf("c1_gc1-> VBatTestMin: %d, TRecupMax: %d, VBatFTest: %d, Ta: %d, TCLimite: %d\n", chartInputData->VBatTestMin, chartInputData->TRecupMax, chartInputData->VBatFTest, chartInputData->Ta, chartInputData->TCLimite);fflush(0);
  printf("c1_gc1-> Orden: %X, TNoCarga: %d, TCarga: %d\n", chartInputData->Orden, chartInstance.TNoCarga, chartInstance.TCarga);fflush(0);
  if(chartInstance.is_active_c1_gc1 == 0) {
    chartInstance.is_active_c1_gc1 = 1;
    chartInstance.is_c1_gc1 = (uint8_T)IN_GCARGA;
    chartInstance.is_GCARGA = (uint8_T)IN_CICLO;
    chartInstance.is_CICLO = (uint8_T)IN_FLOTACION;
    chartOutputData->FT = FT_NULO;
    chartOutputData->ESalida = E_FLOTACION;
  } else if((chartInputData->Orden & O_RESET) == O_RESET) {
  	c1_gc1_inicia();
  } else {
    inct = chartInputData->t - chartInstance.tant;
    chartInstance.tant = chartInputData->t;
    chartInstance.TNoCarga += inct;
    switch(chartInstance.is_GCARGA) {
     case IN_CICLO:
      if((chartInputData->Orden & O_REPLAY) == O_REPLAY ) {
        chartInstance.is_CICLO = (uint8_T)IN_NO_ACTIVE_CHILD;
        chartInstance.is_GCARGA = (uint8_T)IN_REPLAY;
      } else if(chartInputData->Descarga == 1) {
        chartInstance.is_CICLO = (uint8_T)IN_NO_ACTIVE_CHILD;
        chartInstance.is_GCARGA = (uint8_T)IN_DESCARGA;
//        printf("c1_gc1 -> FC: Descarga\n");
      } else {
        switch(chartInstance.is_CICLO) {
         case IN_CARGA:
          if((chartInputData->VBat >= chartInputData->VBatFC) &&
           (chartInputData->IBat >= 0) && (chartInputData->IBat <=
            chartInputData->
            IBatCola)) {
            chartOutputData->FC = FC_OK;
            chartInstance.TNoCarga = 0;
            chartInstance.is_CICLO = (uint8_T)IN_FLOTACION;
          } else if(chartInstance.TCarga >= chartInputData->TCLimite) {
            chartOutputData->FC = FC_TLIM;
            chartInstance.TNoCarga = 0;
            chartInstance.is_CICLO = (uint8_T)IN_FLOTACION;
          } else if(chartInputData->Orden & O_FLOT) {
            chartOutputData->FC = FC_ORDEN;
            chartInstance.TNoCarga = 0;
            chartInstance.is_CICLO = (uint8_T)IN_FLOTACION;
          } else {
            chartInstance.TCarga += inct;
            chartOutputData->ESalida = E_CARGA;
          }
//          printf("c1_gc1 -> FC: %d\n", chartOutputData->FC);
          break;
         case IN_FLOTACION:
          if((chartInputData->Orden & O_CARGA) || (chartInputData->CBat <=
            chartInputData->CBatIniCarga) || (chartInstance.TNoCarga >=
            chartInputData->TPerCarga)) {
            chartInstance.is_CICLO = (uint8_T)IN_CARGA;
            chartOutputData->FC = FC_NULO;
            chartInstance.TCarga = 0;
          } else if((chartInputData->Orden & O_TEST) && (chartInputData->VBat >=
            chartInputData->VBatTestMin)) {
            chartInstance.is_CICLO = (uint8_T)IN_RECUPERACION;
            chartInstance.TRecup = 0;
          } else {
            chartOutputData->ESalida = E_FLOTACION;
          }
          break;
         case IN_RECUPERACION:
          if(chartInstance.TRecup >= chartInputData->TRecupMax) {
            chartOutputData->FT = FT_RECUP;
            chartInstance.is_CICLO = (uint8_T)IN_FLOTACION;
          } else if((chartInputData->VBat >= chartInputData->VBatFC) &&
           (chartInputData->IBat >= 0) && (chartInputData->IBat <= chartInputData
            ->IBatCola)) {
            chartInstance.is_CICLO = (uint8_T)IN_TEST;
            chartOutputData->ESalida = E_TEST;
            chartInstance.TTest = 0;
          } else {
            chartInstance.TRecup += inct;
            chartOutputData->ESalida = E_RECUP;
          }
          break;
         case IN_TEST:
          if(chartInputData->Orden & O_FINTEST) {
            chartOutputData->FT = FT_ORDEN;
            chartInstance.is_CICLO = (uint8_T)IN_FLOTACION;
            chartOutputData->ESalida = E_FLOTACION;
          } else if((chartInputData->IUti < chartInputData->IUtiTestMin) && (chartInstance.TTest > T_FILTRO_IUTI_FIN_TEST)) {
            chartOutputData->FT = FT_IUTI;
            chartInstance.is_CICLO = (uint8_T)IN_FLOTACION;
            chartOutputData->ESalida = E_FLOTACION;
          } else if(chartInputData->VBat <= chartInputData->VBatFTest) {
            chartOutputData->FT = FT_OK;
            chartOutputData->RTest =
            	chartInstance.TTest;
            chartInstance.is_CICLO = (uint8_T)IN_FLOTACION;
            chartOutputData->ESalida = E_FLOTACION;
          } else {
            chartInstance.TTest += inct;
            chartOutputData->ESalida = E_TEST;
          }
          break;
        }
      }
      break;
     case IN_DESCARGA:
     	if(chartInputData->Descarga == 0) {
     		chartInstance.is_GCARGA = (uint8_T)IN_CICLO;
        chartInstance.is_CICLO = (uint8_T)IN_FLOTACION;
     	}
     	else {
	      chartOutputData->ESalida = E_DESCARGA;
	    }
      break;
     case IN_REPLAY:
      if(!(chartInputData->Orden & O_REPLAY)) {
        chartInstance.is_GCARGA = (uint8_T)IN_CICLO;
        chartInstance.is_CICLO = (uint8_T)IN_FLOTACION;
      } else {
        chartOutputData->ESalida = E_REPLAY;
      }
      break;
    }
  }
}

