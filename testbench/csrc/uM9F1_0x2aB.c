#include "svdpi.h"
#include "DirectC.h"
#ifdef __cplusplus
extern "C" {
#endif
extern void snps_reg__regWrite_0x2a(const int A0, const U* A1);
#ifdef __cplusplus
} /*extern "C" */
#endif
#ifndef _DPI_WRAPPER_snps_reg__regWrite_0x2a
#define _DPI_WRAPPER_snps_reg__regWrite_0x2a
#ifdef __cplusplus
extern "C" {
#endif
void  snps_reg__regWrite(int A0,long long int  A1)
{
U A1_u2[2];

ConvLLI2UP(A1, A1_u2);

 snps_reg__regWrite_0x2a(A0,A1_u2);



}
#ifdef __cplusplus
} /*extern "C" */
#endif
#endif
#include "svdpi.h"
#include "DirectC.h"
#ifdef __cplusplus
extern "C" {
#endif
extern void snps_reg__regWriteAtAddr_0x2a(const int A0, const U* A1);
#ifdef __cplusplus
} /*extern "C" */
#endif
#ifndef _DPI_WRAPPER_snps_reg__regWriteAtAddr_0x2a
#define _DPI_WRAPPER_snps_reg__regWriteAtAddr_0x2a
#ifdef __cplusplus
extern "C" {
#endif
void  snps_reg__regWriteAtAddr(int A0,long long int  A1)
{
U A1_u2[2];

ConvLLI2UP(A1, A1_u2);

 snps_reg__regWriteAtAddr_0x2a(A0,A1_u2);



}
#ifdef __cplusplus
} /*extern "C" */
#endif
#endif
