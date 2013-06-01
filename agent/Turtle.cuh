#ifndef __Turtle__
#define __Turtle__
#include <vector>

using namespace std;

template <typename T>
class Turtle{
private:
  vector<T> x;
  vector<T> y;
public:
  Turtle();
  Turtle(int N);
  ~Turtle();
  void add_turtle(int N);
  void add_turtle(T x, T y);
  void remove_turtle(int id);
  T getX(int id);
  T getY(int id);
  T* get_pointer_x(int id);
  T* get_pointer_y(int id);
  int get_turtle_size();
  //void set_pointer_x(T *x);
  //void set_pointer_y(T *y);
  void setX(int id, T x);
  void setY(int id, T y);
  void setXY(int id, T x, T y);
  void random_setXY(T* x, T* y, int N);
};

__device__ int head();

template <typename T>
__global__ void move(T distance, T *x, T *y, int N, T minX, T maxX, T minY, T maxY);

__global__ void move8(double distance, double* x, double* y, int N, double minX, double maxX, double minY, double maxY);

#endif
