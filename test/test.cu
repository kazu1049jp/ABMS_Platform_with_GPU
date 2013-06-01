#include <stdio.h>
#include "../gpu/gpu.cuh"
#include <iostream>

using namespace std;

__global__ void sum(int *dev_result, int *dev1, int *dev2, int N){
  int tid = threadIdx.x + blockDim.x * blockIdx.x;
  if (tid < N){
    dev_result[tid] = dev1[tid] + dev2[tid];
  }
}

void print(int array[], int N){
  for (int i=0; i<N; ++i){
    printf("array[%d]=%d\n", i, array[i]);
  }
}

int main(void){
  const int N = 10;
  dim3 grids((N+511)/512, 1, 1);
  dim3 blocks(512,1,1);
  int element1[N];
  int element2[N];
  cout << "Begin!" << endl;
  for (int i=0; i<N; ++i){
    element1[i] = 1;
    element2[i] = 2;
  }
  print(element1, N);
  int *dev_result = reserve_device_pointer<int>(N);
  int *dev1 = transfer_data_from_host_to_gpu<int>(element1, N);
  int *dev2 = transfer_data_from_host_to_gpu<int>(element2, N);
  sum<<<grids, blocks>>>(dev_result, dev1, dev2, N);
  transfer_data_from_gpu_to_host<int>(dev_result, element1, N);
  //free_device_pointer<int>(dev_result);
  cout << "last" << endl;
  print(element1, N);
  return 0;
}
