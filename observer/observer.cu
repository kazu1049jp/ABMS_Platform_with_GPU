#include "observer.cuh"
#include <stdio.h>

__device__ bool checkBorder(int x, int y, int minX, int maxX, int minY, int maxY){
  if ((minX <= x) && (x <= maxX)){
    if ((minY <= y) && (y <= maxY)){
      return true;
    }
    else{
      return false;
    }
  }
  else{
    return false;
  }
}

template <typename T>
__device__ int checkBorder_where_wrong(T x, T y, T minX, T maxX, T minY, T maxY){
  if ((x < minX) && (y < minY)){//x,yともに最小ボーダーを下回る
    return 1;
  }
  else if ((x < minX) && ((minY <= y) && (y <= maxY))){//xが最小ボーダーを下回る
    return 2;
  }
  else if ((x < minX) && (maxY < y)){//xが最小ボーダーを下回り、yが最大ボーダーを上回る
    return 3;
  }
  else if (((minX <= x) && (x <= maxX)) && (y < minY)){//yが最小ボーダーを下回る
    return 4;
  }
  else if (((minX <= x) && (x <= maxX)) && ((minY <= y) && (y <= maxY))){//正常
    return 0;
  }
  else if (((minX <= x) && (x <= maxX)) && (maxY < y)){//yが最大ボーダーを上回る
    return 5;
  }
  else if ((maxX < x) && (y < minY)){//xが最大ボーダーを上回り、yが最小ボーダーを下回る
    return 6;
  }
  else if ((maxX < x) && ((minY <= y) && (y <= maxY))){//xが最大ボーダーを上回る
    return 7;
  }
  else if ((maxX < x) && (maxY < y)){//x,yともに最大ボーダーを上回る
    return 8;
  }
  else{//その他は起こりえないはずだが、一応保険をかけておく。
    printf("Some problems caused!\n");
    return 100;
  }
}
template __device__ int checkBorder_where_wrong<int>(int x, int y, int minX, int maxX, int minY, int maxY);
template __device__ int checkBorder_where_wrong<float>(float x, float y, float minX, float maxX, float minY, float maxY);
template __device__ int checkBorder_where_wrong<double>(double x, double y, double minX, double maxX, double minY, double maxY);


__device__ bool check_x_shita(int distance, int pos, int minX, int maxX, int minY, int maxY){
  for (int i=1; i<=distance; ++i){
    if (((0+((maxX-minX+1)*(i-1))) <= pos) && (pos <= ((maxX-minX)+(maxX-minX+1)*(i-1)))){
      return false;
    }
  }
  return true;
}


__device__ bool check_x_ue(int distance, int pos, int minX, int maxX, int minY, int maxY){
  for (int i=1; i<=distance; ++i){
    if (((0+((maxX-minX+1)*(maxY-minY))-((maxX-minX+1)*(i-1))) <= pos) && (pos <= ((maxX-minX)+((maxX-minX+1)*(maxY-minY))-((maxX-minX+1)*(i-1))))){
      return false;
    }
  }
  return true;
}


__device__ bool check_y_hidari(int distance, int pos, int minX, int maxX, int minY, int maxY){
  for (int i=1; i<=distance; ++i){
    int tid = 0+(i-1);
    while (tid < ((maxX-minX+1)*(maxY-minY+1))){
      if (tid == pos){
	return false;
      }
      tid+=(maxX-minX+1);
    }
  }
  return true;
}


__device__ bool check_y_migi(int distance, int pos, int minX, int maxX, int minY, int maxY){
  for (int i=1; i<=distance; ++i){
    int tid = (maxX-minX)-(i-1);
    while (tid < ((maxX-minX+1)*(maxY-minY+1))){
      if (tid == pos){
	return false;
      }
      tid+=(maxX-minX+1);
    }
  }
  return true;
}


/*4方向チェック*/
__device__ int check_with_distance(int *world, int distance, int tid, int minX, int maxX, int minY, int maxY){
  int count = 0;

  for (int i=1; i<=distance; ++i){
    if ((check_x_shita(distance, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(distance, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(distance, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(distance, tid, minX, maxX, minY, maxY) == true)){//all OK
      count += world[tid-((maxX-minX+1)*i)] + world[tid+((maxX-minX+1)*i)] + world[tid-i] + world[tid+i];
    }
    else if ((check_x_shita(distance, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(distance, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(distance, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(distance, tid, minX, maxX, minY, maxY) == false)){//migi
      count += world[tid-i] + world[tid+i-(maxX-minX+1)] + world[tid+((maxX-minX+1)*i)] + world[tid-((maxX-minX+1)*i)];
    }
    else if ((check_x_shita(distance, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(distance, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(distance, tid, minX, maxX, minY, maxY) == false) && (check_y_migi(distance, tid, minX, maxX, minY, maxY) == true)){//hidari
      count += world[tid-i+(maxX-minX+1)] + world[tid+i] + world[tid+(maxX-minX+1)*i] + world[tid-(maxX-minX+1)*i];
    }
    else if ((check_x_shita(distance, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(distance, tid, minX, maxX, minY, maxY)==false) && (check_y_hidari(distance, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(distance, tid, minX, maxX, minY, maxY) == true)){//ue
      count += world[tid-i] + world[tid+i] + world[tid+((maxX-minX+1)*i)-((maxX-minX+1)*(maxY-minY+1))] + world[tid-(maxX-minX+1)*i];
    }
    else if ((check_x_shita(distance, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(distance, tid, minX, maxX, minY, maxY)==false) && (check_y_hidari(distance, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(distance, tid, minX, maxX, minY, maxY) == false)){//migiue
      count += world[tid-i] + world[tid+i-(maxX-minX+1)] + world[tid+((maxX-minX+1)*i)-((maxX-minX+1)*(maxY-minY+1))] + world[tid-(maxX-minX+1)*i];
    }
    else if ((check_x_shita(distance, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(distance, tid, minX, maxX, minY, maxY)==false) && (check_y_hidari(distance, tid, minX, maxX, minY, maxY) == false) && (check_y_migi(distance, tid, minX, maxX, minY, maxY) == true)){//hidariue
      count += world[tid-i+(maxX-minX+1)] + world[tid+i] + world[tid+((maxX-minX+1)*i)-((maxX-minX+1)*(maxY-minY+1))] + world[tid-((maxX-minX+1)*i)];
    }
    else if ((check_x_shita(distance, tid, minX, maxX, minY, maxY)== false) && (check_x_ue(distance, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(distance, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(distance, tid, minX, maxX, minY, maxY) == true)){//shita
      count += world[tid-i] + world[tid+i] + world[tid+(maxX-minX+1)*i] + world[tid-((maxX-minX+1)*i)+((maxX-minX+1)*(maxY-minY+1))];
    }
    else if ((check_x_shita(distance, tid, minX, maxX, minY, maxY)== false) && (check_x_ue(distance, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(distance, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(distance, tid, minX, maxX, minY, maxY) == false)){//migishita
      count += world[tid-i] + world[tid+i-(maxX-minX+1)] + world[tid+(maxX-minX+1)*i] + world[tid-((maxX-minX+1)*i)+((maxX-minX+1)*(maxY-minY+1))];
    }
    else if ((check_x_shita(distance, tid, minX, maxX, minY, maxY)== false) && (check_x_ue(distance, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(distance, tid, minX, maxX, minY, maxY) == false) && (check_y_migi(distance, tid, minX, maxX, minY, maxY) == true)){//hidarishita
      count += world[tid-i+(maxX-minX+1)] + world[tid+i] + world[tid+(maxX-minX+1)*i] + world[tid-((maxX-minX+1)*i)+((maxX-minX+1)*(maxY-minY+1))];
    }
    else {
      printf("some problems in check at tid%d\n", tid);
    }
  }
  return count;
}


/*８方向チェック(distance=1)*/
__device__ int check_with_distance8(int *world, int tid, int minX, int maxX, int minY, int maxY){
  int count = 0;

  if ((check_x_shita(1, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(1, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(1, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(1, tid, minX, maxX, minY, maxY) == true)){//all OK
    count += world[tid-((maxX-minX+1)*1)] + world[tid+((maxX-minX+1)*1)] + world[tid-1] + world[tid+1]+world[tid-1+(maxX-minX+1)]+world[tid-1-(maxX-minX+1)]+world[tid+1+(maxX-minX+1)]+world[tid+1-(maxX-minX+1)];//OK
  }
  else if ((check_x_shita(1, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(1, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(1, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(1, tid, minX, maxX, minY, maxY) == false)){//migi
    count += world[tid-1] + world[tid+1-(maxX-minX+1)] + world[tid+((maxX-minX+1)*1)] + world[tid-((maxX-minX+1)*1)]+world[tid-1+(maxX-minX+1)]+world[tid-1-(maxX-minX+1)]+world[tid+1-(maxX-minX+1)+(maxX-minX+1)]+world[tid+1-(maxX-minX+1)-(maxX-minX+1)];
  }
  else if ((check_x_shita(1, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(1, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(1, tid, minX, maxX, minY, maxY) == false) && (check_y_migi(1, tid, minX, maxX, minY, maxY) == true)){//hidari
    count += world[tid-1+(maxX-minX+1)] + world[tid+1] + world[tid+(maxX-minX+1)*1] + world[tid-(maxX-minX+1)*1]+world[tid-1+(maxX-minX+1)+(maxX-minX+1)]+world[tid-1+(maxX-minX+1)-(maxX-minX+1)]+world[tid+1+(maxX-minX+1)]+world[tid+1-(maxX-minX+1)];
  }
  else if ((check_x_shita(1, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(1, tid, minX, maxX, minY, maxY)==false) && (check_y_hidari(1, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(1, tid, minX, maxX, minY, maxY) == true)){//ue
    count += world[tid-1] + world[tid+1] + world[tid+((maxX-minX+1)*1)-((maxX-minX+1)*(maxY-minY+1))] + world[tid-(maxX-minX+1)*1]+world[tid-1+(maxX-minX+1)*1-((maxX-minX+1)*(maxY-minY+1))]+world[tid-1-(maxX-minX+1)*1]+world[tid+1-(maxX-minX+1)*1]+world[tid+1+(maxX-minX+1)*1-((maxX-minX+1)*(maxY-minY+1))];
  }
  else if ((check_x_shita(1, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(1, tid, minX, maxX, minY, maxY)==false) && (check_y_hidari(1, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(1, tid, minX, maxX, minY, maxY) == false)){//migiue
    count += world[tid-1] + world[tid+1-(maxX-minX+1)] + world[tid+((maxX-minX+1)*1)-((maxX-minX+1)*(maxY-minY+1))] + world[tid-(maxX-minX+1)*1] + world[tid-1+((maxX-minX+1)*1)-((maxX-minX+1)*(maxY-minY+1))]+world[tid-1-(maxX-minX+1)*1]+world[tid+1-((maxX-minX+1)*1)-(maxX-minX+1)]+world[tid+1+(maxX-minX+1)-(maxX-minX+1)-((maxX-minX+1)*(maxY-minY+1))];
    /*
    if (tid == 0){
      printf("migiuecount=%d\n",count);////////////
    }
    */
  }
  else if ((check_x_shita(1, tid, minX, maxX, minY, maxY)== true) && (check_x_ue(1, tid, minX, maxX, minY, maxY)==false) && (check_y_hidari(1, tid, minX, maxX, minY, maxY) == false) && (check_y_migi(1, tid, minX, maxX, minY, maxY) == true)){//hidariue
    count += world[tid-1+(maxX-minX+1)] + world[tid+1] + world[tid+((maxX-minX+1)*1)-((maxX-minX+1)*(maxY-minY+1))] + world[tid-((maxX-minX+1)*1)]+world[tid-1+(maxX-minX+1)+(maxX-minX+1)-((maxX-minX+1)*(maxY-minY+1))]+world[tid-1+(maxX-minX+1)-(maxX-minX+1)]+world[tid+1-(maxX-minX+1)]+world[tid+1+(maxX-minX+1)-((maxX-minX+1)*(maxY-minY+1))];//OK
  }
  else if ((check_x_shita(1, tid, minX, maxX, minY, maxY)== false) && (check_x_ue(1, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(1, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(1, tid, minX, maxX, minY, maxY) == true)){//shita
    count += world[tid-1] + world[tid+1] + world[tid+(maxX-minX+1)*1] + world[tid-((maxX-minX+1)*1)+((maxX-minX+1)*(maxY-minY+1))]+world[tid-1+(maxX-minX+1)]+world[tid-1-(maxX-minX+1)+((maxX-minX+1)*(maxY-minY+1))]+world[tid+1-(maxX-minX+1)+((maxX-minX+1)*(maxY-minY+1))]+world[tid+1+(maxX-minX+1)];
  }
  else if ((check_x_shita(1, tid, minX, maxX, minY, maxY)== false) && (check_x_ue(1, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(1, tid, minX, maxX, minY, maxY) == true) && (check_y_migi(1, tid, minX, maxX, minY, maxY) == false)){//migishita
    count += world[tid-1] + world[tid+1-(maxX-minX+1)] + world[tid+(maxX-minX+1)*1] + world[tid-((maxX-minX+1)*1)+((maxX-minX+1)*(maxY-minY+1))] + world[tid-1+(maxX-minX+1)] + world[tid-1-(maxX-minX+1)+((maxX-minX+1)*(maxY-minY+1))] + world[tid+1-(maxX-minX+1)-(maxX-minX+1)+((maxX-minX+1)*(maxY-minY+1))]+world[tid+1-(maxX-minX+1)+(maxX-minX+1)];
  }
  else if ((check_x_shita(1, tid, minX, maxX, minY, maxY)== false) && (check_x_ue(1, tid, minX, maxX, minY, maxY)==true) && (check_y_hidari(1, tid, minX, maxX, minY, maxY) == false) && (check_y_migi(1, tid, minX, maxX, minY, maxY) == true)){//hidarishita
    count += world[tid-1+(maxX-minX+1)] + world[tid+1] + world[tid+(maxX-minX+1)*1] + world[tid-((maxX-minX+1)*1)+((maxX-minX+1)*(maxY-minY+1))]+world[tid-1+(maxX-minX+1)+(maxX-minX+1)]+world[tid-1+(maxX-minX+1)-(maxX-minX+1)+((maxX-minX+1)*(maxY-minY+1))]+world[tid+1-(maxX-minX+1)+((maxX-minX+1)*(maxY-minY+1))]+world[tid+1+(maxX-minX+1)];
  }
  else {
    printf("some problems in check at tid%d\n", tid);
  }
  return count;
}
