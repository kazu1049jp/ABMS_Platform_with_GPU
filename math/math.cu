#include "math.cuh"

template <typename T>
__device__ double degree_to_radian(T degree){
  double PI = 3.1415926535897932384626433832;
  double radian = degree * PI / 180;
  return radian;
}
template __device__ double degree_to_radian<int>(int degree);
template __device__ double degree_to_radian<double>(double degree);

template <typename T>
__device__ T radian_to_degree(double radian){
  double PI = 3.1415926535897932384626433832;
  T degree = radian * 180 / PI;
  return degree;
}
template __device__ int radian_to_degree<int>(double radian);
template __device__ double radian_to_degree<double>(double radian);
