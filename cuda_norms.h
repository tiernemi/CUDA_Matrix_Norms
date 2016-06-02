#ifndef CUDA_NORMS_H_QSHUGFPT
#define CUDA_NORMS_H_QSHUGFPT

/*
 * =====================================================================================
 *
 *       Filename:  cuda_norms.h
 *
 *    Description:  File containing function declarations for cuda norm functions.
 *
 *        Version:  1.0
 *        Created:  17/02/16 11:46:13
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Michael Tierney (MT), tiernemi@tcd.ie
 *
 * =====================================================================================
 */

#include "matrix.h"

#ifdef __cplusplus
extern "C" {
#endif
	float cudaGetMaxNorm(Matrix * mat, int numThreads) ;
	float cudaGetFrobeniusNorm(Matrix * mat, int numThreads) ;
	float cudaGetOneInducedNorm(Matrix * mat, int numThreads) ;
	float cudaGetInfInducedNorm(Matrix * mat, int numThreads) ;	
#ifdef __cplusplus
}
#endif


#endif /* end of include guard: CUDA_NORMS_H_QSHUGFPT */
