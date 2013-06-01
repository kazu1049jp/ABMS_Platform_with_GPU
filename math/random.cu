#include "random.cuh"


/*線形合同法*/
__device__ static unsigned int randx = 1;

__device__ void Srand(unsigned int s){
  randx = s;
}
 
__device__ unsigned int Rand(){
  randx = randx*1103515245+12345;
  return randx&2147483647;
}


/*XORSHIFT*/
__device__ static unsigned long xors_x = 123456789;
__device__ static unsigned long xors_y = 362436069;
__device__ static unsigned long xors_z = 521288629;
__device__ static unsigned long xors_w = 88675123;
 
__device__ unsigned long Xorshift128()
{ 
    unsigned long t; 
    t = (xors_x^(xors_x<<11));
    xors_x = xors_y; xors_y = xors_z; xors_z = xors_w; 
    return ( xors_w = (xors_w^(xors_w>>19))^(t^(t>>8)) ); 
}
__device__ long Xorshift128(long l, long h)
{ 
    unsigned long t; 
    t = (xors_x^(xors_x<<11));
    xors_x = xors_y; xors_y = xors_z; xors_z = xors_w; 
    xors_w = (xors_w^(xors_w>>19))^(t^(t>>8));
    return l+(xors_w%(h-l));
}
 
__device__ float XorFrand(float l, float h)
{
    return l+(h-l)*(Xorshift128(0, 1000000)/1000000.0f);
}
