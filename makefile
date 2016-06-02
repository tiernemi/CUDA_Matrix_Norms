# Compilers and commands
CC=	nvcc
CXX= g++
NVCC= nvcc
LINK= nvcc
DEL_FILE= rm -f

#Flags
#PARALLEL	= -fopenmp
#DEFINES		= -DWITH_OPENMP
CFLAGS		= -W -Wall $(PARALLEL) $(DEFINES) -O2
CXXFLAGS	= -W -Wall $(PARALLEL) $(DEFINES) -O2
NVCCFLAGS	= --use_fast_math -arch=sm_21 -O5
LIBS		= $(PARALLEL)
INCPATH		= /usr/include/
# Old versions
#CFLAGS=-lGL -lglut -lpthread -llibtiff  -O3 -finline-functions -ffast-math -fomit-frame-pointer -funroll-loops
#CXXFLAGS=-lGL -lglut -lpthread -llibtiff  -O3 -finline-functions -ffast-math -fomit-frame-pointer -funroll-loops


####### Files
SRC=cuda_norms.cu main.c matrix.c
OBJ=cuda_norms.o matrix.o main.o
SOURCES=$(SRC)
OBJECTS=$(OBJ)
TARGET= cuda_norms


all: $(OBJECTS)
	$(NVCC) $(OBJECTS) -o $(TARGET) -I$(INCPATH)

main.o: main.c
	$(CC) -c $< $(NVCCFLAGS) -I$(INCPATH)

matrix.o: matrix.c matrix.h time_utils.h
	$(CC) -c $< $(NVCCFLAGS) -I$(INCPATH)

cuda_norms.o: cuda_norms.cu
	$(NVCC) -c $< $(NVCCFLAGS) -I$(INCPATH)

#%.o: %.c
#	$(NVCC) $< -c $(NVCCFLAGS) -I$(INCPATH)

#%.o: %.cu
#	$(NVCC) $< -c $(NVCCFLAGS) -I$(INCPATH)

clean:
	-$(DEL_FILE) $(OBJECTS) $(TARGET)
