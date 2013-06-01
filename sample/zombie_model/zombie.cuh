#ifndef __zombie__
#define __zombie__
#include <vector>
#include "../../agent/Turtle.cuh"

class zombie : public Turtle<int>{
public:
  zombie();
  zombie(int N, int minX, int maxX, int minY, int maxY, int* field);
  ~zombie();
  void add_zombie(int N, int minX, int maxX, int minY, int maxY, int* field);
  void add_zombie(int x, int y, int minX, int maxX, int minY, int maxY, int* field);
  void step(int N, int minX, int maxX, int minY, int maxY, int* field);
  void output_zombie_info(int N);
};

__global__ void update_field_before_move(int* x, int* y, int* field, int N, int minX, int maxX, int minY, int maxY);

__global__ void update_field_after_move(int* x, int* y, int* field, int N, int minX, int maxX, int minY, int maxY);

//__global__ void infect();

#endif
