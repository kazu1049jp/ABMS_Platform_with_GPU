#ifndef __OBSERVER__
#define __OBSERVER__

__device__ bool checkBorder(int x, int y, int minX, int maxX, int minY, int maxY);

template <typename T>
__device__ int checkBorder_where_wrong(T x, T y, T minX, T maxX, T minY, T maxY);

__device__ bool check_x_ue(int distance, int x, int minX, int maxX, int minY, int maxY);


__device__ bool check_x_shita(int distance, int x, int minX, int maxX, int minY, int maxY);


__device__ bool check_y_hidari(int distance, int y, int minX, int maxX, int minY, int maxY);



__device__ bool check_y_migi(int distance, int y, int minX, int maxX, int minY, int maxY);

__device__ int check_with_distance(int *world, int distance, int tid, int minX, int maxX, int minY, int maxY);

__device__ int check_with_distance8(int *world, int tid, int minX, int maxX, int minY, int maxY);

#endif
