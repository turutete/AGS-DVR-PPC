/*
 * Stateflow code generation for chart:
 *    sz4/Ventilador
 * 
 * Target Name                          : AGS
 * Stateflow Version                    : 6.1.0.14.00.0.000000
 * Date of code generation              : 20-Oct-2006 11:16:50
 */

#ifndef __c2_sz4_h__
#define __c2_sz4_h__

/* Type Definitions */
typedef struct {
  int32_T Salida;
} SFc2_sz4OutputDataStruct;
typedef struct {
  int32_T TOn;
  int32_T TPer;
  int32_T Ta;
  int32_T TaOff;
  int32_T TaOn;
  int32_T t;
} SFc2_sz4InputDataStruct;
typedef struct {
  int32_T tant;
  int32_T ton;
  int32_T tp;
  unsigned int is_CONTROL : 2;
  unsigned int is_active_c2_sz4 : 1;
  unsigned int is_c2_sz4 : 1;
} SFc2_sz4InstanceStruct;

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
void c2_sz4(SFc2_sz4InstanceStruct *chartInstance, SFc2_sz4InputDataStruct
 *chartInputData, SFc2_sz4OutputDataStruct *chartOutputData);

/* Function Definitions */

#endif

