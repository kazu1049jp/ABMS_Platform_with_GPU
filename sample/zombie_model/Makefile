#This is the Makefile of infection model (double).
CC = nvcc
#SOURCE = main.cu human.cu ../../world/worldCreator.cu ../../world/worldDefinition.cpp ../../math/random.cu ../../agent/output.cpp ../../agent/AbstractAgent.cu ../../agent/Turtle.cu  ../../observer/observer.cu
OBJ = main.o human.o zombie.o  Turtle.o observer.o worldDefinition.o worldCreator.o output.o random.o
ARCH = -arch=sm_21
DEVIDE = -dc
PROGRAM = infect
OPTION  = -g

all: $(PROGRAM)

$(PROGRAM): $(OBJ)
	$(CC)  $(OBJ) -o $(PROGRAM) $(OPTION) $(ARCH)

main.o: main.cu
	$(CC) main.cu $(ARCH) $(DEVIDE)

worldDefinition.o: ../../world/worldDefinition.cpp
	$(CC) ../../world/worldDefinition.cpp $(ARCH) $(DEVIDE)

worldCreator.o: ../../world/worldCreator.cu
	$(CC) ../../world/worldCreator.cu $(ARCH) $(DEVIDE)

random.o: ../../math/random.cu
	$(CC) ../../math/random.cu $(ARCH) $(DEVIDE)

human.o: human.cu
	$(CC) human.cu $(ARCH) $(DEVIDE)

zombie.o: zombie.cu
	$(CC) zombie.cu $(ARCH) $(DEVIDE)

output.o: ../../agent/output.cpp
	$(CC) ../../agent/output.cpp $(ARCH) $(DEVIDE)

#AbstractAgent.o: ../../agent/AbstractAgent.cu
#	$(CC) -c ../../agent/AbstractAgent.cu

Turtle.o: ../../agent/Turtle.cu
	$(CC) ../../agent/Turtle.cu $(ARCH) $(DEVIDE)

observer.o: ../../observer/observer.cu
	$(CC) ../../observer/observer.cu $(ARCH) $(DEVIDE)

run: $(PROGRAM)
	./$(PROGRAM)

clean:
	rm -f *.o *~ $(PROGRAM)
