/*
 * Stateflow code generation for chart:
 *    gc1/Chart
 * 
 * Target Name                          : AGS
 * Stateflow Version                    : 6.1.0.14.00.0.000000
 * Date of code generation              : 02-Oct-2006 12:01:34
 */

#ifndef __c1_gc1_h__
#define __c1_gc1_h__

#include <tmwtypes.h>

/* Type Definitions */
typedef struct {
  int32_T ESalida;
  int32_T FC;
  int32_T FT;
  int32_T RTest;
} SFc1_gc1OutputDataStruct;
typedef struct {
  int32_T CBat;
  int32_T CBatIniCarga;
  int32_T Descarga;
  int32_T IBat;
  int32_T IBatCola;
  int32_T IUti;
  int32_T IUtiTestMin;
  int32_T Orden;
  int32_T TCLimite;
  int32_T TPerCarga;
  int32_T TRecupMax;
  int32_T Ta;
  int32_T VBat;
  int32_T VBatFC;
  int32_T VBatFTest;
  int32_T VBatTestMin;
  int32_T t;
} SFc1_gc1InputDataStruct;
typedef struct {
  int32_T TCarga;
  int32_T TNoCarga;
  int32_T TRecup;
  int32_T TTest;
  int32_T tant;
  unsigned int is_CICLO : 4;
  unsigned int is_GCARGA : 2;
  unsigned int is_active_c1_gc1 : 1;
  unsigned int is_c1_gc1 : 1;
} SFc1_gc1InstanceStruct;

/* Named Constants */
#define E_DESCARGA                      (1)
#define E_REPLAY                        (2)
#define E_FLOTACION                     (3)
#define E_CARGA                         (5)
#define E_RECUP                         (7)
#define E_TEST                          (8)
#define O_REPLAY                        (1)
#define O_CARGA                         (2)
#define O_FLOT                          (4)
#define O_FINTEST                       (8)
#define O_TEST                       	  (16)
#define O_RESET													(32)
#define FT_NULO													(0)
#define FT_OK                           (1)
#define FT_RECUP                        (2)
#define FT_IUTI                         (3)
#define FT_ORDEN                        (4)
#define FC_NULO													(0)
#define FC_OK                           (1)
#define FC_ORDEN                        (2)
#define FC_TLIM                         (3)

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
void c1_gc1(SFc1_gc1InputDataStruct *chartInputData, SFc1_gc1OutputDataStruct
 *chartOutputData);

void c1_gc1_inicia(void);

/* Function Definitions */

#endif

