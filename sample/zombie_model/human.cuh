#include "../../agent/Turtle.cuh"
#include <vector>
#include "zombie.cuh"

using namespace std;

/*
  エージェント個人が持つIDは配列引数の番号とする。
*/
class human : public Turtle<int>{
private:
  vector<int> infect;//0:false, 1:true
  vector<int> infection_time;

public:
  human(int N, int minX, int maxX, int minY, int maxY);
  ~human();
  //int getX(int id);
  //int getY(int id);
  int getInfect(int id);
  int getInfectionTime(int id);
  //int* get_pointer_x();
  //int* get_pointer_y();
  int*  get_pointer_infect(int id);
  int* get_pointer_infection_time(int id);
  void add_human(int N);
  void die(int id);
  void step(zombie& zombies, int* field, int minX, int maxX, int minY, int maxY, int& N, int& zombieN);
  void output_human_info(int N);
};

__global__ void initiate_agent(int* x, int* y, int* infect, int* infection_time, int N, int minX, int maxX, int minY, int maxY);

__global__ void agent_infect(int infect_distance, int* world, int* devX, int* devY, int* infect, int N, int minX, int maxX, int minY, int maxY);

/*
__global__ void update_field_after_move(int* world, int* infect, int* x, int* y, int N, int minX, int maxX);

__global__ void update_field_before_move(int* world, int* infect, int* x, int* y, int N, int minX, int maxX);
*/
__global__ void update_infection_time(int* dev_infect, int* dev_infection_time, int N);

