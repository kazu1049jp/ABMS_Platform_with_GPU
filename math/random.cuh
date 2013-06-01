/*線形合同法を用いた乱数生成*/

#ifndef __RANDOM__
#define __RANDOM__


/*線形合同法*/
__device__ void Srand(unsigned int s);

__device__ unsigned int Rand();

/*XORSHIFT*/
__device__ unsigned long Xorshift128();

__device__ long Xorshift128(long l, long h);
 
__device__ float XorFrand(float l, float h);

#endif
