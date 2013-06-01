#include <stdio.h>
#include "human.cuh"
#include "zombie.cuh"
#include <cutil.h>
#include "../../world/worldCreator.cuh"
#include "../../agent/output.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

using namespace std;

void run(void);

void input_agent_data(int& humanN, int& zombieN);

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

void run(void){
  worldCreator<int> world;
  int maxX = world.getMax_X();
  int minX = world.getMin_X();
  int maxY = world.getMax_Y();
  int minY = world.getMin_Y();
  //cout << "maxX:" << maxX << ", minX:" << minX << ", maxY:" << maxY << ", minY:" << minY << endl;
  world.make_2D_World();
  int* field = world.getField();
  int humanN;// = 10;
  int zombieN;// = 5;
  input_agent_data(humanN, zombieN);
  human agent(humanN, minX, maxX, minY, maxY);
  zombie zombies(zombieN, minX, maxX, minY, maxY, field);

  printf("maxX:%d, minX:%d, maxY:%d, minY:%d \n", maxX,minX,maxY,minY);//check
  printf("human=%d, zombie=%d\n", humanN, zombieN);//check
  cout << "--------------------------" << endl;
  cout << "Simulation starts!" << endl;
  /*
  cout << "initial" << endl;
  for (int i=0; i<humanN; ++i){
    cout << "x[" << i << "]=" << agent.getX(i) << ", ";
    cout << "y[" << i << "]=" << agent.getY(i) << endl;
  }
  */
  //make_output_coordinates(agent.get_pointer_x(0), agent.get_pointer_y(0), N);
  const int step_count = 100;
  for(int i=0; i<step_count; ++i){
    cout << "step " << (i+1) << endl;
    //int death_counter = 0;
    agent.step(zombies, field, minX, maxX, minY, maxY, humanN, zombieN);
    zombies.step(zombieN, minX, maxX, minY, maxY, field);
  }
  cout << "fin" << endl;
  cout << "------------------------------" << endl;
  cout << "<result>" << endl;
  printf("maxX:%d, minX:%d, maxY:%d, minY:%d \n", maxX,minX,maxY,minY);
  cout << "the sum of agents=" << (humanN+zombieN) << endl;
  cout << "simulation steps=" << step_count << endl;
  cout << "left human=" << humanN << endl;
  cout << "zombie=" << zombieN << endl;

  /*
  for (int i=0; i<humanN; ++i){
    cout << "x[" << i << "]=" << agent.getX(i) << ", ";
    cout << "y[" << i << "]=" << agent.getY(i) << endl;
  }
  */
  //output_agent_info(agent.get_pointer_x(0), agent.get_pointer_y(0), agent.get_pointer_infect(0), N);
  agent.output_human_info(humanN);
  zombies.output_zombie_info(zombieN);
  cout << "Simulation end!" << endl;
}


void input_agent_data(int& humanN, int& zombieN){
  string str, human, zombie;
  ifstream ifs("agent.props");
  getline(ifs, str);
  getline(ifs, str);
  human = str;
  getline(ifs, str);
  getline(ifs, str);
  zombie = str;

  /*文字列データを数値へ変換*/
  stringstream ss;
  ss << human;
  ss >> humanN;
  ss.clear();
  ss.str("");
  ss << zombie;
  ss >> zombieN;
  ss.clear();
  ss.str("");
}
