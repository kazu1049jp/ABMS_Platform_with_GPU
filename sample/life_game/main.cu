#include <stdio.h>
#include <iostream>
#include "../../world/worldCreator.cuh"
#include "cell.cuh"
#include <cutil.h>

using namespace std;

void run(){
  worldCreator<int> world;
  world.make_2D_World();
  Cell agent(world);
  int agent_size = (world.getMax_X()-world.getMin_X()+1)*(world.getMax_Y()-world.getMin_Y()+1);

  printf("initial condition\n");
  agent.print_result();

  int step_count = 100;
  for (int i=0; i<step_count; ++i){
    printf("step%d\n",i+1);
    agent.step(agent_size, world);
    agent.print_result();
  }
  

}

int main(void){
  CUDA_SAFE_CALL(cudaSetDevice(0));
  float elapsed_time_ms = 0.0f;
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  cudaEventRecord(start, 0);
  run();
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&elapsed_time_ms, start, stop);
  printf("Run time from start to end : %f [sec]\n", elapsed_time_ms/1000);

  return 0;
}
