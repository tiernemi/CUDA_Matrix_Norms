/*
 * =====================================================================================
 *
 *       Filename:  matrix.c
 *
 *    Description:  File containing source code for Matrix functions.
 *
 *        Version:  1.0
 *        Created:  16/02/16 20:37:38
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Michael Tierney (MT), tiernemi@tcd.ie
 *
 * =====================================================================================
 */

#include <stdlib.h>
#include <stdio.h>
#include "matrix.h"

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  makeMatrix
 *    Arguments:  int numRows - Number of rows in matrix.
 *                int numCols - Number of columns in matrix.
 *      Returns:  Pointer to Matrix object in heap.
 *  Description:  Allocates memory for a Matrix with numrows rows and numcols columns.
 * =====================================================================================
 */

Matrix * makeMatrix(int numRows, int numCols) {
	Matrix * newMatrix = malloc(sizeof(Matrix)) ;
	newMatrix->data = malloc(sizeof(float)*numRows*numCols) ;
	newMatrix->numRows = numRows ;
	newMatrix->numCols = numCols ;

	return newMatrix ;
}	/* -----  end of function makeMatrix  ----- */


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  getElement
 *    Arguments:  Matrix * mat - Matrix containing data.
 *                int i - i co-ordinate.
 *                int j - j co-ordinate.
 *      Returns:  Data at index (i,j).
 *  Description:  Function used to get data using 2-D co-ordinates from a 1-D array.
 * =====================================================================================
 */

float getElement(Matrix * mat, int i, int j) {
	return mat->data[i*mat->numCols + j] ;
}		/* -----  end of function getElement  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  setElement
 *    Arguments:  Matrix * mat - Matrix containing data.
 *                int i - i co-ordinate.
 *                int j - j co-ordinate.
 *                float val - Value to be set at index (i,j).
 *  Description:  Function used to set data using 2-D co-ordinates for a 1-D array.
 * =====================================================================================
 */

void setElement(Matrix * mat, int i, int j, float val) {
	mat->data[i*mat->numCols + j] = val ;
}		/* -----  end of function setElement  ----- */


/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  printMatrix
 *    Arguments:  Matrix * mat - Matrix to be printed.
 *  Description:  Prints the matrix to stdout.
 * =====================================================================================
 */

void printMatrix(Matrix * mat) {
	int i,j ;
	printf("\n") ;
	for (i = 0 ; i < mat->numRows ; ++i) {
		for (j = 0 ; j < mat->numCols ; ++j) {
			printf("%f ", getElement(mat,i,j)) ;
		}
		printf("\n") ;
	}
	printf("\n") ;
}		/* -----  end of function printMatrix  ----- */

/* 
 * ===  FUNCTION  ======================================================================
 *         Name:  freeMatrix
 *    Arguments:  Matrix * mat - Matrix to free.
 *  Description:  Frees heap memory associated with Matrix object.
 * =====================================================================================
 */

void freeMatrix(Matrix * mat) {
	free(mat->data) ;
	free(mat) ;
}		/* -----  end of function freeMatrix  ----- */
