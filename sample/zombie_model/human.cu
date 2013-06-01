#include "human.cuh"
#include <cutil.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include "../../math/random.cuh"
#include "../../observer/observer.cuh"
#include "../../agent/Turtle.cuh"
#include "seed.cuh"

/*
  エージェント個人が持つIDは配列引数の番号とする。
*/

using namespace std;

__constant__ int D_SEED = SEED;

/*
  エージェント情報を初期化する
*/
human::human(int N, int minX, int maxX, int minY, int maxY){//Nはエージェント数
  int* dev_agentX = NULL;
  int* dev_agentY = NULL;
  int* dev_agentInfect = NULL;
  int* dev_agentInfectionTime = NULL;
  add_human(N);
  int *x = get_pointer_x(0);
  int *y = get_pointer_y(0);
  int *infect_P = get_pointer_infect(0);
  int *infection_time_P = get_pointer_infection_time(0);
  //infect  = NULL;
  //die = NULL;

  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_agentX, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_agentY, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_agentInfect, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_agentInfectionTime, sizeof(int)*N));
	
  dim3 blocks(1024, 1, 1);
  dim3 grids((N+1023)/1024, 1, 1);

  initiate_agent<<<grids, blocks>>>(dev_agentX, dev_agentY, dev_agentInfect, dev_agentInfectionTime, N, minX, maxX, minY, maxY);
	
  CUDA_SAFE_CALL(cudaMemcpy(x, dev_agentX, sizeof(int)*N, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaMemcpy(y, dev_agentY, sizeof(int)*N, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaMemcpy(infect_P, dev_agentInfect, sizeof(int)*N, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaMemcpy(infection_time_P, dev_agentInfectionTime, sizeof(int)*N, cudaMemcpyDeviceToHost));

  CUDA_SAFE_CALL(cudaFree(dev_agentX));
  CUDA_SAFE_CALL(cudaFree(dev_agentY));
  CUDA_SAFE_CALL(cudaFree(dev_agentInfect));
  CUDA_SAFE_CALL(cudaFree(dev_agentInfectionTime));
}


human::~human(){
}

/*
int human::getX(int id){
  return x[id];
}

int human::getY(int id){
  return y[id];
}
*/

int human::getInfect(int id){
  return infect[id];
}

int human::getInfectionTime(int id){
  return infection_time[id];
}

/*
int* human::get_pointer_x(){
  return x;
}

int* human::get_pointer_y(){
  return y;
}
*/

int* human::get_pointer_infect(int id){
  return &infect[id];
}

int* human::get_pointer_infection_time(int id){
  return &infection_time[id];
}

void human::add_human(int N){
  add_turtle(N);
  for (int i=0; i<N; ++i){
    infect.push_back(0);
    infection_time.push_back(0);
  }
}
/*reserveはイテレータが取得できないので不可*/

void human::die(int id){
  remove_turtle(id);
  if ((infect.empty() == false) && (infection_time.empty() == false)){
    int search = 0;
    vector<int>::iterator it_infect = infect.begin();
    vector<int>::iterator it_infection_time = infection_time.begin();
    while (search != id){
      ++it_infect;
      ++it_infection_time;
      ++search;
    }
    infect.erase(it_infect);
    infection_time.erase(it_infection_time);
  }
}

__global__ void agent_infect(int infect_distance, int* world, int* devX, int* devY, int* infect, int N, int minX, int maxX, int minY, int maxY){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
  //const int infect_parameter = 80;
  if (tid < N){
    if(infect[tid] != 1){
      if (world[devX[tid]+((maxX-minX+1)*devY[tid])] >= 1){
	infect[tid] = 1;
      }

      /*以下は範囲外アクセスを考慮した周囲のチェック*/
      /*
      int pos = devX[tid] + ((maxX-minX+1)*devY[tid]);
      int count = check_with_distance(world, infect_distance, pos, minX, maxX, minY, maxY);
      */
      /*周囲チェックの処理はここまで*/
      /*
      if (count > 0){
	int parameter = (Rand() % 101) + (10*count);
	if (parameter > infect_parameter){//感染条件は適当にいじってよし
	  infect[tid] = 1;
	}
      }
      else{
	int parameter = Rand() % 101;
	if (parameter > infect_parameter){
	  infect[tid] = 1;
	}
      }
      */
    }
  }
}


__global__ void update_field_before_move(int* world, int* infect, int* x, int* y, int N, int minX, int maxX){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
	
  if (tid < N){
    if (infect[tid] == 1){
      if (world[(y[tid]*(maxX-minX+1))+x[tid]] > 0){
	atomicSub(&world[(y[tid]*(maxX-minX+1))+x[tid]], 1);
      }
    }
  }
}

__global__ void update_field_after_move(int* world, int* infect, int* x, int* y, int N, int minX, int maxX){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
	
  if (tid < N){
    if (infect[tid] == 1){
      atomicAdd(&world[(y[tid]*(maxX-minX+1))+x[tid]], 1);
    }
  }
}

__global__ void update_infection_time(int* dev_infect, int* dev_infection_time, int N){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
  if (tid < N){
    if (dev_infect[tid] == 1){
      ++dev_infection_time[tid];
    }
  }
}


void human::step(zombie& zombies, int* field, int minX, int maxX, int minY, int maxY, int& N, int& zombieN){
  int field_count = (maxX-minX+1)*(maxY-minY+1);
  int *tmp_field = (int*)malloc(sizeof(int)*field_count);//before info
  dim3 grids((N+1023)/1024,1,1);
  dim3 blocks(1024,1,1);
  int *devX, *devY;
  int *dev_infect, *dev_infection_time;
  int *dev_field_before;//, *dev_field_after;
  int *x = get_pointer_x(0);
  int *y = get_pointer_y(0);
  int *infect = get_pointer_infect(0);
  int *infection_time = get_pointer_infection_time(0);
  

  for (int i=(int)minY;i<(int)maxY;++i){
    tmp_field[i] = field[i];
  }

  /*update infection time*/
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_infection_time, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_infect, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMemcpy(dev_infect, infect, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(dev_infection_time, infection_time, sizeof(int)*N, cudaMemcpyHostToDevice));
  update_infection_time<<<grids, blocks>>>(dev_infect, dev_infection_time, N);
  CUDA_SAFE_CALL(cudaMemcpy(infection_time, dev_infection_time, sizeof(int)*N, cudaMemcpyDeviceToHost));
  
  CUDA_SAFE_CALL(cudaFree(dev_infection_time));
  CUDA_SAFE_CALL(cudaFree(dev_infect));

  /*update field before move*/
  /*
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_field_after, sizeof(int)*field_count));
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_infect, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&devX, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&devY, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMemcpy(dev_field_after, field, sizeof(int)*field_count, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(dev_infect, infect, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(devX, x, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(devY, y, sizeof(int)*N, cudaMemcpyHostToDevice));
  update_field_before_move<<<grids, blocks>>>(dev_field_after, dev_infect, devX, devY, N, minX, maxX);
  CUDA_SAFE_CALL(cudaMemcpy(field, dev_field_after, sizeof(int)*field_count, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaFree(devX));
  CUDA_SAFE_CALL(cudaFree(devY));
  CUDA_SAFE_CALL(cudaFree(dev_field_after));
  CUDA_SAFE_CALL(cudaFree(dev_infect));
  */
  
  /*move*/
  CUDA_SAFE_CALL(cudaMalloc((void**)&devX, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&devY, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMemcpy(devX, x, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(devY, y, sizeof(int)*N, cudaMemcpyHostToDevice));
  move<<<grids,blocks>>>(2,devX,devY,N,minX,maxX,minY,maxY);
  CUDA_SAFE_CALL(cudaMemcpy(x, devX, sizeof(int)*N, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaMemcpy(y, devY, sizeof(int)*N, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaFree(devX));
  CUDA_SAFE_CALL(cudaFree(devY));
  
  /*update field after move*/
  /*
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_field_after, sizeof(int)*field_count));
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_infect, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&devX, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&devY, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMemcpy(dev_field_after, field, sizeof(int)*field_count, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(dev_infect, infect, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(devX, x, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(devY, y, sizeof(int)*N, cudaMemcpyHostToDevice));
  update_field_after_move<<<grids, blocks>>>(dev_field_after, dev_infect, devX, devY, N, minX, maxX);
  CUDA_SAFE_CALL(cudaMemcpy(field, dev_field_after, sizeof(int)*field_count, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaFree(devX));
  CUDA_SAFE_CALL(cudaFree(devY));
  CUDA_SAFE_CALL(cudaFree(dev_field_after));
  CUDA_SAFE_CALL(cudaFree(dev_infect));
  */

  /*infect*/
  CUDA_SAFE_CALL(cudaMalloc((void**)&devX, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&devY, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMemcpy(devX, x, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(devY, y, sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_infect, sizeof(int)*N));
  CUDA_SAFE_CALL(cudaMalloc((void**)&dev_field_before, sizeof(int)*field_count));
  CUDA_SAFE_CALL(cudaMemcpy(dev_infect, &infect[0], sizeof(int)*N, cudaMemcpyHostToDevice));
  CUDA_SAFE_CALL(cudaMemcpy(dev_field_before, tmp_field, sizeof(int)*field_count, cudaMemcpyHostToDevice));
  agent_infect<<<grids, blocks>>>(1, dev_field_before, devX, devY, dev_infect, N, minX, maxX, minY, maxY);
  CUDA_SAFE_CALL(cudaMemcpy(infect, dev_infect, sizeof(int)*N, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaMemcpy(tmp_field, dev_field_before, sizeof(int)*field_count, cudaMemcpyDeviceToHost));
  CUDA_SAFE_CALL(cudaFree(dev_infect));
  CUDA_SAFE_CALL(cudaFree(dev_field_before));
  CUDA_SAFE_CALL(cudaFree(devX));
  CUDA_SAFE_CALL(cudaFree(devY));
  
  free(tmp_field);
  for (int id=0; id<N; ++id){
    if (infection_time[id] >= 5){
      zombies.add_zombie(getX(id), getY(id), minX, maxX, minY, maxY, field);
      //cout << "X:" << getX(id) << ", Y:" << getY(id) << endl;
      ++zombieN;
      die(id);
      --N;
      --id;
      //id = 0;
    }
  }
}



__global__ void initiate_agent(int* x, int* y, int* infect, int* infection_time, int N, int minX, int maxX, int minY, int maxY){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
	
  if (tid < N){
    //x[tid] = (Rand() << tid) % (maxX-minX+1);//% (maxX+1);
    //y[tid] = (Rand() >> tid) % (maxY-minY+1);//% (maxY+1);
    x[tid] = abs(Xorshift128(tid+D_SEED,N-tid+D_SEED) % (maxX-minX+1));
    y[tid] = abs(Xorshift128(N-tid+D_SEED,tid+D_SEED) % (maxY-minY+1));
    infect[tid] = 0;
    infection_time[tid] = 0;
  }
}

void human::output_human_info(int N){
  int infect_count = 0;
  ofstream ofs("info_human.csv");
  ofs << "id,x,y,infected,infection time" << endl;
  for (int i=0; i<N; ++i){
    if (getInfect(i) == 1){
      ++infect_count;
      ofs << i << "," << getX(i) << "," << getY(i) << "," << "true" << "," << infection_time[i] << endl;//<< getInfectionTime(i) << endl;
    }
    else{
      ofs << i << "," << getX(i) << "," << getY(i) << "," << "false" << "," << getInfectionTime(i) << endl;
    }
    
  }
  ofs << endl;
  ofs << "感染者合計：," << infect_count << "人" << endl;
}
