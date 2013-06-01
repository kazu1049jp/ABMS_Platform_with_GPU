CC = nvcc
program = a.out
a.out: test.cu
	nvcc -g -G -o $(program) test.cu -I /home/kazuhideota/NVIDIA_GPU_Computing_SDK/C/common/inc/

run: $(program)
	./a.out

clean: 
	rm -f *.o $(program) *~
