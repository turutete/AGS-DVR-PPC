/*
 * Stateflow code generation for chart:
 *    sz4/Maniobra
 * 
 * Target Name                          : AGS
 * Stateflow Version                    : 6.1.0.14.00.0.000000
 * Date of code generation              : 20-Oct-2006 11:16:50
 */

#ifndef __c1_sz4_h__
#define __c1_sz4_h__

/* Type Definitions */
typedef struct {
  int32_T ErrorS;
  int32_T Estado;
  int32_T Marcha;
  int32_T Paro;
  int32_T RError;
} SFc1_sz4OutputDataStruct;
typedef struct {
  int32_T ContMedDC;
  int32_T Error;
  int32_T EstadoConv;
  int32_T IntOnOff;
  int32_T PAc;
  int32_T PParadaH;
  int32_T PParadaL;
  int32_T TArranque;
  int32_T TEspera;
  int32_T TEsperaDSP;
  int32_T TParada;
  int32_T UpvRad;
  int32_T UpvRadArranque;
  int32_T UpvRadEspera;
  int32_T t;
} SFc1_sz4InputDataStruct;
typedef struct {
  int32_T t1;
  int32_T tant;
  int32_T tesp;
  unsigned int is_MARCHA : 3;
  unsigned int is_CICLO : 2;
  unsigned int is_EMERGENCIA : 2;
  unsigned int is_FALLO : 2;
  unsigned int is_MANIOBRA : 2;
  unsigned int is_active_MANIOBRA : 1;
  unsigned int is_active_c1_sz4 : 1;
  unsigned int is_c1_sz4 : 1;
} SFc1_sz4InstanceStruct;

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
void c1_sz4(SFc1_sz4InstanceStruct *chartInstance, SFc1_sz4InputDataStruct
 *chartInputData, SFc1_sz4OutputDataStruct *chartOutputData);

/* Function Definitions */

#endif

