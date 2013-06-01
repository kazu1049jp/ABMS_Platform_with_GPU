#include <vector>
#include "../../world/worldCreator.cuh"

class Cell{
private:
  std::vector<int> condition;//0:die, 1:live
  int maxX;
  int minX; 
  int maxY;
  int minY;
public:
  Cell(worldCreator<int> &world);
  ~Cell();
  int get_cell_condition(int id);
  int* get_cell_condition_pointer(int id);
  void step(int agent_size, worldCreator<int> &world);
  void print_result();
};

__global__ void initiate(int* dev_condition,int N);

__global__ void synch_field(int *dev_condition, int *dev_field, int size);

__device__ int around_me(int *world,int tid,int minX,int maxX,int minY,int maxY);

__global__ void game(int *dev_cell, int *world, int minX, int maxX, int minY, int maxY, int N);
