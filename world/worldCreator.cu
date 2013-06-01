#include "worldCreator.cuh"
#include "worldDefinition.h"
#include <cstdlib>
#include <iostream>
#include <cutil.h>

using namespace std;


/*
  Initialize variables
*/
template <class T>
worldCreator<T>::worldCreator(){
  this->field = NULL;
  worldDefinition<T> world;
  this->min_x = world.getMin_X();
  this->max_x = world.getMax_X();
  this->min_y = world.getMin_Y();
  this->max_y = world.getMax_Y();
  T x_range = this->max_x - this->min_x + 1;
  T y_range = this->max_y - this->min_y + 1;
  this->N = x_range * y_range;
  this->field = (int*) malloc(sizeof(T)*(this->N));//デストラクタで解放
  if (this->field == NULL){
    cout << "Simulator can't get a pointer in worldCreator." << endl;
  }
}
template worldCreator<int>::worldCreator();
template worldCreator<float>::worldCreator();
template worldCreator<double>::worldCreator(); 


/*
  Free the malloced pointer
*/
template <class T>
worldCreator<T>::~worldCreator(){
  if (field != NULL){
    free(field);
  }
}
template worldCreator<int>::~worldCreator();
template worldCreator<float>::~worldCreator();
template worldCreator<double>::~worldCreator();


/*
  Set the range defined in worldDefinition
*/
template <class T>
void worldCreator<T>::setRange(T minX, T maxX, T minY, T maxY){
  this->min_x = minX;
  this->max_x = maxX;
  this->min_y = minY;
  this->max_y = maxY;
}
template void worldCreator<int>::setRange(int minX, int maxX, int minY, int maxY);
template void worldCreator<float>::setRange(float minX, float maxX, float minY, float maxY);
template void worldCreator<double>::setRange(double minX, double maxX, double minY, double maxY);

template <class T>
__global__ void fieldSet(T* field, int N){
  int tid = threadIdx.x + blockDim.x * blockIdx.x;
  if (tid < N){
    field[tid] = 0;
  }
}
template __global__ void fieldSet<int>(int* field, int N);
template __global__ void fieldSet<float>(float* field, int N);
template __global__ void fieldSet<double>(double* field, int N);

/*
  Make field with the range!
  We must set detail information at the other place.
*/
template <class T>
void worldCreator<T>::make_2D_World(){
  T* dev_field;
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_field, sizeof(T)*N));
  dim3 blocks(1024, 1 ,1);
  dim3 grids((N + 1023)/1024, 1, 1);
  fieldSet<<<grids, blocks>>>(dev_field, N);
  CUDA_SAFE_CALL(cudaMemcpy(field, dev_field, sizeof(T)*N, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaFree(dev_field));
}
template void worldCreator<int>::make_2D_World();
template void worldCreator<float>::make_2D_World();
template void worldCreator<double>::make_2D_World();

template <class T>
T worldCreator<T>::getMax_X(){
  return this->max_x;
}
template int worldCreator<int>::getMax_X();
template float worldCreator<float>::getMax_X();
template double worldCreator<double>::getMax_X();

template <class T>
T worldCreator<T>::getMin_X(){
  return this->min_x;
}
template int worldCreator<int>::getMin_X();
template float worldCreator<float>::getMin_X();
template double worldCreator<double>::getMin_X();

template <class T>
T worldCreator<T>::getMax_Y(){
  return this->max_y;
}
template int worldCreator<int>::getMax_Y();
template float worldCreator<float>::getMax_Y();
template double worldCreator<double>::getMax_Y();

template <class T>
T worldCreator<T>::getMin_Y(){
  return this->min_y;
}
template int worldCreator<int>::getMin_Y();
template float worldCreator<float>::getMin_Y();
template double worldCreator<double>::getMin_Y();

template <class T>
int* worldCreator<T>::getField(){
  return &(this->field[0]);
}
template int* worldCreator<int>::getField();
template int* worldCreator<float>::getField();
template int* worldCreator<double>::getField();

template <class T>
void worldCreator<T>::setField(int* dataP, int N){
  this->field = (int*)malloc(sizeof(int)*N);
  for (int i=0; i<N; ++i){
    this->field[i] = dataP[i];
  }
}
template void worldCreator<int>::setField(int* dataP, int N);
template void worldCreator<float>::setField(int* dataP, int N);
template void worldCreator<double>::setField(int* dataP, int N);
