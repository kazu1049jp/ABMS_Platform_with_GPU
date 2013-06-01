#include "zombie.cuh"
#include <math.h>
#include <cutil.h>
#include "../../agent/Turtle.cuh"
#include "seed.cuh"
#include <fstream>
#include <stdio.h>


zombie::zombie(){
}

zombie::zombie(int N, int minX, int maxX, int minY, int maxY, int* field){
  srand(SEED);
  add_zombie(N, minX, maxX, minY, maxY, field);
}

zombie::~zombie(){
}

void zombie::add_zombie(int N, int minX, int maxX, int minY, int maxY, int* field){
  for (int i=0; i<N; ++i){
    int x = rand() % (maxX-minX+1);
    int y = rand() % (maxX-minX+1);
    add_turtle(x,y);
    ++field[x+((maxX-minX+1)*y)];
  }
}

void zombie::add_zombie(int x, int y, int minX, int maxX, int minY, int maxY, int *field){
  add_turtle(x,y);
  ++field[x+((maxX-minX+1)*y)];
}

void zombie::step(int N, int minX, int maxX, int minY, int maxY, int* field){
  int field_count = (maxY-minY+1)*(maxX-minX+1);
  int* x = (int*)malloc(sizeof(int)*N);
  int* y = (int*)malloc(sizeof(int)*N);
  x = get_pointer_x(0);
  y = get_pointer_y(0);
  int* devX;
  int* devY;
  int* dev_field;
  dim3 grids((N+1023)/1024, 1, 1);
  dim3 blocks(1024, 1, 1);

  /*remove before move*/
  CUDA_SAFE_CALL(cudaMalloc((void**)&devX, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&devY, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_field, sizeof(int)*field_count));
  CUDA_SAFE_CALL(cudaMemcpy(devX, x, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(devY, y, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(dev_field, field, sizeof(int)*field_count, cudaMemcpyHostToDevice));
  update_field_before_move<<<grids, blocks>>>(devX, devY, dev_field, N, minX, maxX, minY, maxY);
  CUDA_SAFE_CALL(cudaMemcpy(field, dev_field, sizeof(int)*field_count, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaFree(devX));
  CUDA_SAFE_CALL(cudaFree(devY));
  CUDA_SAFE_CALL(cudaFree(dev_field));

  /*move*/
  CUDA_SAFE_CALL(cudaMalloc((void**)&devX, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&devY, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMemcpy(devX, x, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(devY, y, sizeof(int)*N, cudaMemcpyHostToDevice));
  move<<<grids,blocks>>>(1,devX,devY,N,minX,maxX,minY,maxY);
  CUDA_SAFE_CALL(cudaMemcpy(x, devX, sizeof(int)*N, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaMemcpy(y, devY, sizeof(int)*N, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaFree(devX));
  CUDA_SAFE_CALL(cudaFree(devY));

  /*add after move*/
  CUDA_SAFE_CALL(cudaMalloc((void**)&devX, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&devY, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_field, sizeof(int)*field_count));
  CUDA_SAFE_CALL(cudaMemcpy(devX, x, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(devY, y, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(dev_field, field, sizeof(int)*field_count, cudaMemcpyHostToDevice));
  update_field_after_move<<<grids, blocks>>>(devX, devY, dev_field, N, minX, maxX, minY, maxY);
  CUDA_SAFE_CALL(cudaMemcpy(field, dev_field, sizeof(int)*field_count, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaFree(devX));
  CUDA_SAFE_CALL(cudaFree(devY));
  CUDA_SAFE_CALL(cudaFree(dev_field));

  /*Add zombies whom people become in this turn.*/
  /*
  add_zombie(death_counter, minX, maxX, minY, maxY, field);
  N += death_counter;
  */
}

__global__ void update_field_before_move(int* x, int* y, int* field, int N, int minX, int maxX, int minY, int maxY){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
  if (tid < N){
    if (field[(y[tid]*(maxX-minX+1))+x[tid]] > 0){
      atomicSub(&field[(y[tid]*(maxX-minX+1))+x[tid]], 1);
    }
  }
}


__global__ void update_field_after_move(int* x, int* y, int* field, int N, int minX, int maxX, int minY, int maxY){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
  if (tid < N){
    atomicAdd(&field[(y[tid]*(maxX-minX+1))+x[tid]], 1);
  }
}


void zombie::output_zombie_info(int N){
  ofstream ofs("info_zombie.csv");
  ofs << "id,x,y" << endl;
  for(int i=0; i<N; ++i){
    ofs << i << "," << getX(i) << "," << getY(i) << endl;
  }
}
