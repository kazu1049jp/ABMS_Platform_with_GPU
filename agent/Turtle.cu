#include "Turtle.cuh"
#include "../observer/observer.cuh"
#include "../math/random.cuh"
//#include <vector>
#include <iostream>
#include <stdio.h>

using namespace std;

/*default constructor*/
template <typename T>
Turtle<T>::Turtle(){
}
template Turtle<int>::Turtle();
template Turtle<float>::Turtle();
template Turtle<double>::Turtle();

/*constructor we always want to use*/
template <typename T>
Turtle<T>::Turtle(int N){
  add_turtle(N);
}
template Turtle<int>::Turtle(int N);
template Turtle<float>::Turtle(int N);
template Turtle<double>::Turtle(int N);

/*Destructor*/
template <typename T>
Turtle<T>::~Turtle(){
  x.clear();
  y.clear();
}
template Turtle<int>::~Turtle();
template Turtle<float>::~Turtle();
template Turtle<double>::~Turtle();

/*get the coordinates x*/
template <typename T>
T Turtle<T>::getX(int id){
  return x[id];
}
template int Turtle<int>::getX(int id);
template float Turtle<float>::getX(int id);
template double Turtle<double>::getX(int id);

template <typename T>
void Turtle<T>::add_turtle(int N){
  //x.reserve(N);
  //y.reserve(N);
  /*
    vector.reserve(N)は必要十分な領域を確保するだけで確保領域数が決まっているわけではない
    よって、イテレータ等の使用は不可能
  */
  for (int i=0; i<N; ++i){
    this->x.push_back(0);
    this->y.push_back(0);
  }
}
template void Turtle<int>::add_turtle(int N);
template void Turtle<float>::add_turtle(int N);
template void Turtle<double>::add_turtle(int N);

/*直接新しいエージェントを生成*/
template <typename T>
void Turtle<T>::add_turtle(T x, T y){
  this->x.push_back(x);
  this->y.push_back(y);
}
template void Turtle<int>::add_turtle(int x, int y);
template void Turtle<float>::add_turtle(float x, float y);
template void Turtle<double>::add_turtle(double x, double y);

template <typename T>
void Turtle<T>::remove_turtle(int id){
  if ((x.empty() == false) && (y.empty() == false)){
    int search = 0;
    typename vector<T>::iterator it_x = x.begin();
    typename vector<T>::iterator it_y = y.begin();
    while (search != id){
      ++search;
      ++it_x;
      ++it_y;
    }
    x.erase(it_x);
    y.erase(it_y);
  }
  /*
  else{
    cout << "The turtle vector is empty!" << endl;
  }
  */
}
template void Turtle<int>::remove_turtle(int id);
template void Turtle<float>::remove_turtle(int id);
template void Turtle<double>::remove_turtle(int id);
  

/*get the coordinates y*/
template <typename T>
T Turtle<T>::getY(int id){
  return y[id];
}
template int Turtle<int>::getY(int id);
template float Turtle<float>::getY(int id);
template double Turtle<double>::getY(int id);


template <typename T>
T* Turtle<T>::get_pointer_x(int id){
  return &x[id];
}
template int* Turtle<int>::get_pointer_x(int id);
template float* Turtle<float>::get_pointer_x(int id);
template double* Turtle<double>::get_pointer_x(int id);

template <typename T>
T* Turtle<T>::get_pointer_y(int id){
  return &y[id];
}
template int* Turtle<int>::get_pointer_y(int id);
template float* Turtle<float>::get_pointer_y(int id);
template double* Turtle<double>::get_pointer_y(int id);

template <typename T>
int Turtle<T>::get_turtle_size(){
  if (x.size() == y.size()){
    return x.size();
  }
  else{
    cout << "size error in the function:get_turlte_size!" << endl;
    return -1;
  }
}
template int Turtle<int>::get_turtle_size();
template int Turtle<float>::get_turtle_size();
template int Turtle<double>::get_turtle_size();


/*set the coordinates x*/
template <typename T>
void Turtle<T>::setX(int id, T x){
  this->x[id] = x;
}
template void Turtle<int>::setX(int id, int x);
template void Turtle<float>::setX(int id, float x);
template void Turtle<double>::setX(int id, double x);

/*set the coordinates y*/
template<typename T>
void Turtle<T>::setY(int id, T y){
  this->y[id] = y;
}
template void Turtle<int>::setY(int id, int y);
template void Turtle<float>::setY(int id, float y);
template void Turtle<double>::setY(int id, double y);


/*set the coordinates x and y*/
template <typename T>
void Turtle<T>::setXY(int id, T x, T y){
  this->x[id] = x;
  this->y[id] = y;
}
template void Turtle<int>::setXY(int id, int x, int y);
template void Turtle<float>::setXY(int id, float x, float y);
template void Turtle<double>::setXY(int id, double x, double y);


/*進む方向を決める（４方向）*/
__device__ int head(int tid){
  int arg = (tid + Rand()) % 4;//良い乱数を考えなくてはいけない
  return arg;//0:north, 1:east, 2:south, 3:west
}


/*進む方向を決める（８方向）*/
__device__ int head8(int tid){
  int arg = (tid + Rand()) % 8;
  return arg;//0:north, 1:east, 2:south, 3:west 4:northeast 5:southeast 6:southwest 7:northeast
}

/*移動する（４方向）*/
template <typename T>
__global__ void move(T distance, T *x, T *y, int N, T minX, T maxX, T minY, T maxY){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
  if (tid < N){
    int oldX, oldY, newX, newY;
    oldX = x[tid];
    oldY = y[tid];
    int h = head(tid);
    switch (h){
    case 0: //north
      newX = oldX;
      newY = oldY + distance;
      if (checkBorder(newX, newY, minX, maxX, minY, maxY) == false){
	newY = newY - (maxY - minY + 1);
      }
      break;
    case 1: //east
      newX = oldX + distance;
      newY = oldY;
      if (checkBorder(newX, newY, minX, maxX, minY, maxY) == false){
	newX = newX - (maxX - minX + 1);
      }
      break;
    case 2: //south
      newX = oldX;
      newY = oldY - distance;
      if (checkBorder(newX, newY, minX, maxX, minY, maxY) == false){
	newY = newY + (maxY - minY + 1);
      }
      break;
    case 3: //west
      newX = oldX - distance;
      newY = oldY;;
      if (checkBorder(newX, newY, minX, maxX, minY, maxY) == false){
	newX = newX + (maxX - minX + 1);
      }
      break;
    default://others are some problems.
      printf("some problems in move function\n");
      break;
    }
    x[tid] = newX;
    y[tid] = newY;
  }
}
template __global__ void move<int>(int distance, int *x, int *y, int N, int minX, int maxX, int minY, int maxY);
template __global__ void move<float>(float distance, float *x, float *y, int N, float minX, float maxX, float minY, float maxY);
template __global__ void move<double>(double distance, double *x, double *y, int N, double minX, double maxX, double minY, double maxY);


/*移動する（８方向）*/
__global__ void move8(double distance, double* x, double* y, int N, double minX, double maxX, double minY, double maxY){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
  double PI = 3.1415926535897932384626433832;

  if (tid < N){
    double oldX = x[tid];
    double oldY = y[tid];
    double newX, newY;

    int direction = head8(tid);//方角を決める

    switch (direction){//決められた方角に対して移動処理
    case 0: //north
      newX = oldX;
      newY = oldY + distance;
      if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) != 0){
	newY = newY - (maxY - minY + 1);
      }
      break;
    case 1: //east
      newX = oldX + distance;
      newY = oldY;;
      if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) != 0){
	newX = newX - (maxX - minX + 1);
      }
      break;
    case 2: //south
      newX = oldX;
      newY = oldY - distance;
      if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) != 0){
	newY = newY + (maxY - minY + 1);
      }
      break;
    case 3: //west
      newX = oldX - distance;
      newY = oldY;;
      if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) != 0){
	newX = newX - (maxX - minX + 1);
      }
      break;
    case 4://northwest
      newX = oldX - (distance * cos(PI/4));
      newY = oldY + (distance * sin(PI/4));
      if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 2){
	newX = newX + (maxX - minX + 1);
      }
      else if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 3){
	newX = newX + (maxX - minX + 1);
	newY = newY - (maxY - minY + 1);
      }
      else if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 5){
	newY = newY - (maxY - minY + 1);
      }
      break;
    case 5://southwest
      newX = oldX + (distance * cos(PI/4));
      newY = oldY - (distance * sin(PI/4));
      if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 1){
	newX = newX - (maxX - minX + 1);
	newY = newY + (maxY - minY + 1);
      }
      else if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 2){
	newX = newX + (maxX - minX + 1);
      }
      else if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 3){
	newX = newX + (maxX - minX + 1);
	newY = newY - (maxY - minY + 1);
      }
      break;
    case 6://southeast
      newX = oldX - (distance * cos(PI/4));
      newY = oldY + (distance * sin(PI/4));
      if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 2){
	newX = newX + (maxX - minX + 1);
      }
      else if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 3){
	newX = newX + (maxX - minX + 1);
	newY = newY - (maxY - minY + 1);
      }
      else if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 5){
	newY = newY - (maxY - minY + 1);
      }
      break;
    case 7://northeast
      newX = oldX + (distance * cos(PI/4));
      newY = oldY + (distance * sin(PI/4));
      if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 6){
	newX = newX - (maxX - minX + 1);
	newY = newY + (maxY - minY - 1);
      }
      else if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 7){
	newX = newX - (maxX - minX + 1);
      }
      else if (checkBorder_where_wrong(newX, newY, minX, maxX, minY, maxY) == 8){
	newX = newX - (maxX - minX + 1);
	newX = newY - (maxY - minY + 1);
      }
      break;
    }
    x[tid] = newX;
    y[tid] = newY;
  }
}
