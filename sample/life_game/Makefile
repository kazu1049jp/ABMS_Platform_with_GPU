#This is the Makefile of life model.
CC = nvcc
SOURCE = main.cu cell.cu ../../world/worldCreator.cu ../../world/worldDefinition.cpp ../../math/random.cu ../../observer/observer.cu
OBJ = main.o cell.o worldCreator.o worldDefinition.o observer.o random.o
ARCH = -arch=sm_21
DEVIDE = -dc
PROGRAM = life_game
OPTION  = -g -G

all: $(PROGRAM)

$(PROGRAM): $(OBJ)
	$(CC) $(ARCH) $(OBJ) -o $(PROGRAM) $(OPTION)

main.o: main.cu
	$(CC) main.cu $(ARCH) $(DEVIDE) $(OPTION)

cell.o: cell.cu
	$(CC) cell.cu $(ARCH) $(DEVIDE) $(OPTION)

worldCreator.o: ../../world/worldCreator.cu
	$(CC) ../../world/worldCreator.cu $(ARCH) $(DEVIDE) $(OPTION)

worldDefinition.o: ../../world/worldDefinition.cpp
	$(CC) ../../world/worldDefinition.cpp $(ARCH) $(DEVIDE) $(OPTION)

observer.o: ../../observer/observer.cu
	$(CC) ../../observer/observer.cu $(ARCH) $(DEVIDE) $(OPTION)

random.o: ../../math/random.cu
	$(CC) ../../math/random.cu $(ARCH) $(DEVIDE) $(OPTION)


run: $(PROGRAM)
	./$(PROGRAM)

clean:
	rm -f *.o *~ $(PROGRAM)
