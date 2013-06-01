#include "cell.cuh"
#include <cutil.h>
#include "../../math/random.cuh"
#include <stdio.h>
#include "../../gpu/gpu.cuh"
#include "../../observer/observer.cuh"
#include <cstdlib>
#include <ctime>


using namespace std;

Cell::Cell(worldCreator<int> &world){
  this->maxX = world.getMax_X();
  this->minX = world.getMin_X();
  this->maxY = world.getMax_Y();
  this->minY = world.getMin_Y();
  int agent_size = (maxX-minX+1)*(maxY-minY+1);
  //srand(time(NULL));
  srand(1);
  for (int i=0; i<agent_size; ++i){
    this->condition.push_back((rand()%2));
  }
  world.setField(&(this->condition[0]), agent_size);
}

Cell::~Cell(){
}

int Cell::get_cell_condition(int id){
  return this->condition[id];
}

int* Cell::get_cell_condition_pointer(int id){
  return &(this->condition[id]);
}

void Cell::step(int agent_size, worldCreator<int> &world){
  dim3 grids((agent_size+1023)/1024, 1, 1);
  dim3 blocks(1024, 1, 1);
  int *dev_cell, *dev_field;
  int *field = world.getField();
  dev_field = transfer_data_from_host_to_gpu(field, agent_size);
  dev_cell = transfer_data_from_host_to_gpu(&(this->condition[0]), agent_size);
  game<<<grids,blocks>>>(dev_cell, dev_field, minX, maxX, minY, maxY, agent_size);
  synch_field<<<grids, blocks>>>(dev_cell, dev_field, agent_size);//field synch
  transfer_data_from_gpu_to_host(dev_cell, &(this->condition[0]), agent_size);
  transfer_data_from_gpu_to_host(dev_field, field, agent_size);
}

void Cell::print_result(){
  for (int y=minY; y<=maxY; ++y){
    if(y==minY){
      for (int i=minX; i<=(maxX+2);++i){
	printf("- ");
      }
      printf("\n");
    }   
    for (int x=minX; x<=maxX; ++x){
      if (x==minX){
	printf("| ");
      }
      if (this->condition[x+(maxX-minX+1)*y]==1){
	printf("* ");
      }
      else if (this->condition[x+(maxX-minX+1)*y]==0){
	printf("  ");
      }
      else{
	printf("cell error!\n");
	exit(1);
      }
      if (x==maxX){
	printf("|\n");
      }
    }
    if(y==maxY){
      for (int i=minX; i<=(maxX+2);++i){
	printf("- ");
      }
      printf("\n");
    }
  }
}


__global__ void synch_field(int *dev_condition, int *dev_field, int size){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
  if (tid < size){
    dev_field[tid] = dev_condition[tid];
  }
}


__device__ int around_me(int *world,int tid,int minX,int maxX,int minY,int maxY){
  return check_with_distance8(world,tid,minX,maxX,minY,maxY);
}


/*
ライフゲームのルール実装
*/
__global__ void game(int *dev_cell, int *dev_world, int minX, int maxX, int minY, int maxY, int N){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
  
  if (tid < N){
    int around_life = around_me(dev_world, tid, minX, maxX, minY, maxY);
    
    if (dev_cell[tid] == 1){
      if (around_life <= 1){
	dev_cell[tid] = 0;
      }
      else if ((2 <= around_life) && (around_life <= 3)){
	dev_cell[tid] = 1;
      }
      else if (4 <= around_life){
	dev_cell[tid] = 0;
      }
    }
    else if (dev_cell[tid] == 0){
      if ((1 <= around_life) && (around_life <= 2)){
	dev_cell[tid] = 0;
      }
      else if (around_life == 3){
	dev_cell[tid] = 1;
      }
      else if (4 <= around_life){
	dev_cell[tid] = 0;
      }
    }
    else{
      printf("This case can't cause in tid%d:%d!", tid, dev_cell[tid]);
    }
  }
}
