/*
 * =====================================================================================
 *
 *       Filename:  cuda_norms.cu
 *
 *    Description:  File containing function source for cuda norm functions.
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

#include "cuda_norms.h"
#include "stdio.h"

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  cudaReduceSumSqrt
 *    Arguments:  float * sumArray - Array of elements to be summed.
 *                int numElements - Number of elements in sumArray.
 *  Description:  Sums all terms in sumArray and gets its square root.
 * =====================================================================================
 */

__device__ float globSum = 0.f ;
__global__ void cudaReduceSumSqrt(float * sumArray, int numElements) {
	int id = threadIdx.x+blockIdx.x*blockDim.x ;
	if (id == 0) { 
		float threadSum = 0.f ;
		for (int i = 0 ; i < numElements ; ++i) {
			threadSum += sumArray[i] ;
		}
		globSum = sqrtf(threadSum) ;
	}
}

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  cudaReduceMax
 *    Arguments:  float * maxArray - Array of elements to be reduced.
 *                int numElements - Number of elements in maxArray.
 *  Description:  Finds the largest value in maxArray and saves to globMax.
 * =====================================================================================
 */


__device__ float globMax = 0.f ;
__global__ void cudaReduceMax(float * maxArray, int numElements) {
	int id = threadIdx.x+blockIdx.x*blockDim.x ;
	if (id == 0) { 
		float threadMax = 0.f ;
		for (int i = 0 ; i < numElements ; ++i) {
			threadMax = threadMax < maxArray[i] ? maxArray[i] : threadMax ; 
		}
		globMax = threadMax ;
	}
}

/* 
* ===  FUNCTION  ===========================================================================
*         Name:  cudaCalcFrobeniusNormGPU
*    Arguments:  float * matDataGPU - Array containing matrix elements on GPU.
*                float * frobNormRow - Array containing the squared terms per row.
*                int numRows - Number of rows in matrix.
*                int numCols - Number of columns in matrix.
*  Description:  CUDA Global function for calculating max norm for the matrix. Calculates
*                max for each row. Reduction of rowMaxs array is carried out using another
*                function. Can be performed more efficiently using shared memory and atomic
*                functions.
* ==========================================================================================
*/

__global__ void cudaCalcFrobeniusNormGPU(float * matDataGPU, float * frobNormRow, int numRows, int numCols) {	
	int id = threadIdx.x+blockIdx.x*blockDim.x ;
	if (id < numCols) {
		frobNormRow[id] = 0.f ;
		for (int i = 0 ; i < numRows ; ++i) {
			frobNormRow[id] += matDataGPU[i*numCols+id]*matDataGPU[i*numCols+id] ;
		}
	}
}

/* 
 * ===  FUNCTION  ===========================================================================
 *         Name:  cudaCalcMaxNorm
 *    Arguments:  float * matDataGPU - Array containing matrix elements on GPU.
 *                float * rowMaxs - Array containing the maximum row entries on GPU.
 *                int numRows - Number of rows in matrix.
 *                int numCols - Number of columns in matrix.
 *  Description:  CUDA Global function for calculating max norm for the matrix. Calculates
 *                max for each row. Reduction of rowMaxs array is carried out using another
 *                function. Can be performed more efficiently using shared memory and atomic
 *                functions.
 * ==========================================================================================
 */

__global__ void cudaCalcMaxNorm(float * matDataGPU, float * colMaxs, int numRows, int numCols) {
	int colID = threadIdx.x+blockIdx.x*blockDim.x ;
	if (colID < numCols) {
		float max = 0.f ;
		for (int i = 0 ; i < numRows ; ++i) {
			float absVal = fabsf(matDataGPU[i*numCols + colID]) ;
			max = max < absVal ? absVal : max ;
		}
		colMaxs[colID] = max ;
	}
}		/* -----  end of function cudaCalcMaxNorm  ----- */

/* 
 * ===  FUNCTION  =========================================================================
 *         Name:  cudaCalcOneIndNorm
 *    Arguments:  float * matDataGPU - Array containing matrix elements on GPU.
 *                float * colNorms - Array containing the induced norm per column on GPU.
 *                int numRows - Number of rows in matrix.
 *                int numCols - Number of columns in matrix.
 *  Description:  CUDA Global function for calculating induced one-norm for the matrix.
 *                Calculates sum of absolute values of elements per column. The max is
 *                found by another function.
 * ========================================================================================
 */

__global__ void cudaCalcOneInducedNorm(float * matDataGPU, float * colNorms, int numRows, int numCols) {
	int colID = threadIdx.x+blockIdx.x*blockDim.x ;
	if (colID < numCols) {
		float sum = 0.f ;
		for (int i = 0 ; i < numRows ; ++i) {
			sum += fabsf(matDataGPU[i*numCols + colID]) ;
		}
		colNorms[colID] = sum ;
	}
}		/* -----  end of function cudaCalcOneIndNorm  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  cudaCalcInfIndNorm
  *    Arguments:  float * matDataGPU - Array containing matrix elements on GPU.
 *                float * rowNorms - Array containing the induced norm per row on GPU.
 *                int numRows - Number of rows in matrix.
 *                int numCols - Number of columns in matrix.
 *  Description:  CUDA Global function for calculating induced inf-norm for the matrix.
 *                Calculates sum of absolute values of elements per row. The max is
 *                found by another function.
 * =====================================================================================
 */

__global__ void cudaCalcInfInducedNorm(float * matDataGPU, float * rowNorms, int numRows, int numCols) {
	int rowID = threadIdx.x+blockIdx.x*blockDim.x ;
	if (rowID < numRows) {
		float sum = 0.f ;
		for (int i = 0 ; i < numCols ; ++i) {
			sum += fabsf(matDataGPU[rowID*numCols + i]) ;
		}
		rowNorms[rowID] = sum ;
	}
}		/* -----  end of function cudaCalcOneIndNorm  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  cudaUploadMatrixToGPU
 *    Arguments:  Matrix * mat - Matrix to upload to GPU.
 *                float ** matDataGPU - Array used to store matrix data on GPU.
 *  Description:  Uploads matrix to GPU using cuda memcopy and cuda malloc.
 * =====================================================================================
 */

void cudaUploadMatrixToGPU(Matrix * mat, float ** matDataGPUAdr) {
	cudaError_t rt = cudaMalloc((void **) matDataGPUAdr, sizeof(float)*mat->numRows*mat->numCols) ;
	if (rt != cudaSuccess) {
		printf("hiiii\n");
	}
	cudaError_t rt2 = cudaMemcpy(*matDataGPUAdr, mat->data, sizeof(float)*mat->numRows*mat->numCols, cudaMemcpyHostToDevice) ;
	if (rt != cudaSuccess) {
		printf("hiiii2\n");
	}
}		/* -----  end of function cudaUploadMatrixToGPU  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  cudaFreeMatrixGPU
 *    Arguments:  Matrix * mat - Matrix that has been loaded to the GPU.
 *                float ** matDataGPU - Array used to store matrix data on GPU.
 *  Description:  Frees matrix data from GPU.
 * =====================================================================================
 */

void cudaFreeMatrixGPU(Matrix * mat, float * matDataGPU) {
	cudaFree(matDataGPU) ;
}		/* -----  end of function cudaFreeMatrixGPU  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  cudaGetMaxNorm
 *    Arguments:  Matrix * mat - Matrix that we're finding the max norm of.
 *      Returns:  The max norm of the Matrix.
 *  Description:  This function finds the max norm of the matrix using CUDA. This norm 
 *                is simply the largest absolute element in the matrix.
 * =====================================================================================
 */

extern float cudaGetMaxNorm(Matrix * mat, int numThreads) {
	float * matDataGPU ;
	float * colMaxsGPU ;
	float max ;

	int block_size=numThreads ;
	dim3 dimBlock(block_size) ;
	dim3 dimGrid((mat->numCols/dimBlock.x) + (!(mat->numCols%dimBlock.x)?0:1) );

	cudaUploadMatrixToGPU(mat, &matDataGPU) ;
	cudaMalloc((void **) &colMaxsGPU, sizeof(float)*mat->numCols) ;
	
	cudaCalcMaxNorm<<<dimGrid, dimBlock>>>(matDataGPU, colMaxsGPU, mat->numRows, mat->numCols) ;
	cudaReduceMax<<<1,1>>>(colMaxsGPU, mat->numCols) ;
	cudaMemcpyFromSymbol(&max, globMax, sizeof(float), 0, cudaMemcpyDeviceToHost) ;

	cudaFreeMatrixGPU(mat, matDataGPU) ;
	cudaFree(colMaxsGPU) ;

	return max ;
}		/* -----  end of function cudaGetMaxNorm  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  cudaGetFrobeniusNorm
 *    Arguments:  Matrix * mat - Matrix that we're finding the Frobenius norm of.
 *      Returns:  The Frobenius norm of the matrix.
 *  Description:  This function finds the Frobenius norm of the Matrix using CUDA. 
 *                The Frobenius norm is square root of the sum of the squares of each 
 *                element.
 * =====================================================================================
 */

extern float cudaGetFrobeniusNorm(Matrix * mat, int numThreads) {
	float * frobNormRow ;
	float * matDataGPU ;
	float frobNorm ;

	int N = mat->numCols ;
	int block_size=numThreads ;
	dim3 dimBlock(block_size) ;
	dim3 dimGrid((N/dimBlock.x) + (!(N%dimBlock.x)?0:1) );

	cudaUploadMatrixToGPU(mat, &matDataGPU) ;
	cudaMalloc((void **) &frobNormRow, sizeof(float)*N) ;
	// For each row square and sum. //
	cudaCalcFrobeniusNormGPU<<<dimGrid,dimBlock>>>(matDataGPU, frobNormRow, mat->numRows, mat->numCols) ;
	// Combine all row sums. //
	cudaReduceSumSqrt<<<1,1>>>(frobNormRow, N) ;
	// Get answer. //
	cudaMemcpyFromSymbol(&frobNorm, globSum, sizeof(float), 0, cudaMemcpyDeviceToHost) ;

	cudaFreeMatrixGPU(mat, matDataGPU);
	cudaFree(frobNormRow) ;
	return frobNorm ;
}		/* -----  end of function cudaGetMaxNorm  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  cudaGetOneInducedNorm    
 *    Arguments:  Matrix * mat - Matrix that we're finding the one-induced norm of.
 *      Returns:  The one-induced norm of the matrix.
 *  Description:  This function finds the one-induced norm of the Matrix using CUDA. 
 *                This norm is maximum of the values generated by summing the absolut
 *                values of the columns.
 * =====================================================================================
 */

extern float cudaGetOneInducedNorm(Matrix * mat, int numThreads) {
	float * oneIndNormArGPU ;
	float * matDataGPU ;
	float oneIndNorm ;

	int N =mat->numCols ;
	int block_size= numThreads ;
	dim3 dimBlock(block_size) ;
	dim3 dimGrid((N/dimBlock.x) + (!(N%dimBlock.x)?0:1) );

	cudaUploadMatrixToGPU(mat, &matDataGPU) ;
	cudaMalloc((void **) &oneIndNormArGPU, sizeof(float)*N) ;
	// For each column sum absolute value of elements. //
	cudaCalcOneInducedNorm<<<dimGrid,dimBlock>>>(matDataGPU, oneIndNormArGPU, mat->numRows, mat->numCols) ;
	// Find the largest sum. //
	cudaReduceMax<<<1,1>>>(oneIndNormArGPU, mat->numCols) ;
	cudaMemcpyFromSymbol(&oneIndNorm, globMax, sizeof(float), 0, cudaMemcpyDeviceToHost) ;

	cudaFreeMatrixGPU(mat, matDataGPU);
	cudaFree(oneIndNormArGPU) ;
	
	return oneIndNorm ;
}		/* -----  end of function cudaGetMaxNorm  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  cudaGetInfInducedNorm
 *    Arguments:  Matrix * mat - Matrix that we're finding the inf-induced norm of.
 *      Returns:  The inf-induced norm of the matrix.
 *  Description:  This function finds the inf-induced norm of the Matrix using CUDA. 
 *                This norm is maximum of the values generated by summing the absolute 
 *                values of the rows.
 * =====================================================================================
 */

extern float cudaGetInfInducedNorm(Matrix * mat, int numThreads) {
	float * infIndNormArGPU ;
	float * matDataGPU ;
	float infIndNorm ;

	int N =mat->numRows ;
	int block_size= numThreads ;
	dim3 dimBlock(block_size) ;
	dim3 dimGrid((N/dimBlock.x) + (!(N%dimBlock.x)?0:1) );

	cudaUploadMatrixToGPU(mat, &matDataGPU) ;
	cudaMalloc((void **) &infIndNormArGPU, sizeof(float)*N) ;
	// For each row sum absolute value of elements. //
	cudaCalcInfInducedNorm<<<dimGrid,dimBlock>>>(matDataGPU, infIndNormArGPU, mat->numRows, mat->numCols) ;
	// Find the largest sum. //
	cudaReduceMax<<<1,1>>>(infIndNormArGPU, mat->numCols) ;
	cudaMemcpyFromSymbol(&infIndNorm, globMax, sizeof(float), 0, cudaMemcpyDeviceToHost) ;

	cudaFreeMatrixGPU(mat, matDataGPU);
	cudaFree(infIndNormArGPU) ;
	
	return infIndNorm ;
}		/* -----  end of function cudaGetMaxNorm  ----- */

