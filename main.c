/*
 * =====================================================================================
 *
 *       Filename:  main.c
 *
 *    Description:  File containing main function.
 *
 *        Version:  1.0
 *        Created:  16/02/16 20:52:22
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Michael Tierney (MT), tiernemi@tcd.ie
 *
 * =====================================================================================
 */

#include "matrix.h"
#include "getopt.h"
#include "stdlib.h"
#include "stdio.h"
#include <math.h>
#include "norms.h"
#include <stdbool.h>
#include "time_utils.h"
#include "cuda_norms.h"


int main(int argc, char *argv[]) {
	
	int i,j ;
	int numRows = 10 ;
	int numCols = 10 ;
	int defaultSeed = 123456 ;
	int choice ;
	bool timeFlag = false ;
	srand48(defaultSeed) ;
	
	// ..............................COMMAND LINE ARGS............................. //
	
	time_t s;  // Seconds
    struct timespec spec ;
	clock_gettime(CLOCK_REALTIME, &spec);	
    s = spec.tv_sec;
    unsigned long ms = round(spec.tv_nsec / 1.0e6) ;
	unsigned long numMsSinceEpoch = s*1000 + ms ;

	while (1) {
		choice = getopt(argc, argv, "stn:m:") ;
		if (choice == -1)
			break ;
		switch( choice ) {
			case 's' :
				srand48(numMsSinceEpoch) ;
				break ;
			case 'n' :
				numRows = atoi(optarg) ;
				break ;
			case 'm' :
				numCols = atoi(optarg) ;
				break ;
			case 't' :
				timeFlag = true ;
				break ;
			default  :
				fprintf(stderr, "Unknown Command Line Argument\n") ;
				return EXIT_FAILURE ;
		}
	}
	
	/* Deal with non-option arguments here */
	int remainingArgs = argc - optind ;
	if (remainingArgs > 0) {
		fprintf(stderr, "Expecting 2 or 0 cmd line arguments\n") ;
		return EXIT_FAILURE ;
	}

	// ........................................................................... //
	
	Matrix * randMat = makeMatrix(numRows, numCols) ;
	for (i = 0 ; i < randMat->numRows ; ++i) {
		for (j = 0 ; j < randMat->numCols ; ++j) {
			setElement(randMat,i,j,(float)drand48()) ;
		}
	}

	int numThreads = 32 ;

	// Calculate norms on the CPU. //
	startClock() ;
	float maxNorm = getMaxNorm(randMat) ;
	stopClock() ;
	float timeDiffMaxNorm = getElapsedTime() ;

	startClock() ;
	float frobNorm = getFrobeniusNorm(randMat) ;
	stopClock() ;
	float timeDiffFrobNorm = getElapsedTime() ;

	startClock() ;
	float oneInNorm = getOneInducedNorm(randMat) ;
	stopClock() ;
	float timeDiffOneInNorm = getElapsedTime() ;

	startClock() ;
	float infInNorm = getInfInducedNorm(randMat) ;
	stopClock() ;
	float timeDiffInfInNorm = getElapsedTime() ;
	
	// Calculate norms on the CPU. //
	startClock() ;
	float cudaMaxNorm = cudaGetMaxNorm(randMat, numThreads) ;
	stopClock() ;
	float cudaTimeDiffMaxNorm = getElapsedTime() ;

	startClock() ;
	float cudaFrobNorm = cudaGetFrobeniusNorm(randMat, numThreads) ;
	stopClock() ;
	float cudaTimeDiffFrobNorm = getElapsedTime() ;

	startClock() ;
	float cudaOneInNorm = cudaGetOneInducedNorm(randMat, numThreads) ;
	stopClock() ;
	float cudaTimeDiffOneInNorm = getElapsedTime() ;

	startClock() ;
	float cudaInfInNorm = cudaGetInfInducedNorm(randMat, numThreads) ;
	stopClock() ;
	float cudaTimeDiffInfInNorm = getElapsedTime() ;


	if (numRows < 20 && numCols < 20) {
		printMatrix(randMat) ;
	}

	// If timeFlag enabled then display times. //
	if (timeFlag) {
		printf("Max Norm : %f\nTime : %f\n", maxNorm, timeDiffMaxNorm) ;
		printf("Max Norm CUDA : %f\nTime : %f\n", cudaMaxNorm, cudaTimeDiffMaxNorm) ;
		printf("Frobenius Norm : %f\nTime : %f\n", frobNorm, timeDiffFrobNorm) ;
		printf("Frobenius Norm CUDA : %f\nTime : %f\n", cudaFrobNorm, cudaTimeDiffFrobNorm) ;
		printf("One-Induced Norm : %f\nTime : %f\n", oneInNorm, timeDiffOneInNorm) ;
		printf("One-Induced Norm CUDA : %f\nTime : %f\n", cudaOneInNorm, cudaTimeDiffOneInNorm) ;
		printf("Infinity-Induced Norm : %f\nTime : %f\n", infInNorm, timeDiffInfInNorm) ;
		printf("Infinity-Induced Norm CUDA : %f\nTime : %f\n\n", cudaInfInNorm, cudaTimeDiffInfInNorm) ;
	} else {
		printf("Max Norm : %f\n", maxNorm) ;
		printf("Max Norm CUDA : %f\n", cudaMaxNorm) ;
		printf("Frobenius Norm : %f\n", frobNorm) ;
		printf("Frobenius Norm CUDA : %f\n", cudaFrobNorm) ;
		printf("One-Induced Norm : %f\n", oneInNorm) ;
		printf("One-Induced Norm CUDA : %f\n", cudaOneInNorm) ;
		printf("Infinity-Induced Norm : %f\n", infInNorm) ;
		printf("Infinity-Induced Norm CUDA : %f\n\n", cudaInfInNorm) ;
	}

	freeMatrix(randMat) ;
	return 0 ;
}
