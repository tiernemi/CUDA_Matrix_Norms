#ifndef MATRIX_H_6UVIZPC1
#define MATRIX_H_6UVIZPC1

/*
 * =====================================================================================
 *
 *       Filename:  matrix.h
 *
 *    Description:  Header file containing Matrix object.
 *
 *        Version:  1.0
 *        Created:  16/02/16 20:29:35
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Michael Tierney (MT), tiernemi@tcd.ie
 *
 * =====================================================================================
 */

/* 
 * ===  STRUCT  ========================================================================
 *         Name:  Matrix
 *       Fields:  int numRows - Number of rows in matrix.
 *                int numCols - Number of columns in matrix.
 *                float * data - Array containg matrix entries.
 *  Description:  Matrix struct that contains 2-D matrix data.
 * =====================================================================================
 */

typedef struct Matrix {
	int numRows ;
	int numCols ;
	float * data ;
} Matrix ;		/* -----  end of struct Matrix  ----- */

Matrix * makeMatrix(int numRows, int numCols) ;
float getElement(Matrix * mat, int i, int j) ;
void setElement(Matrix * mat, int i, int j, float val) ;
void printMatrix(Matrix * mat) ;
void freeMatrix(Matrix * mat) ;

#endif /* end of include guard: MATRIX_H_6UVIZPC1 */
