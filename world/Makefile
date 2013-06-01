CC = nvcc 
OBJ = worldCreator.o worldDefinition.o
OPTION = -arch=sm_20

Creator: worldCreator.cu
	$(CC) -c worldCreator.cu $(OPTION)

Definition: worldDefinition.cpp
	$(CC) -c worldDefinition.cpp $(OPTION)

clean:
	rm -f *.o *~
