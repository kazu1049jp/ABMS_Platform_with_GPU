#ifndef _WORLDCREATOR_
#define _WORLDCREATOR_

template <class T>
class worldCreator{
private:
  int* field;
  T max_x;
  T max_y;
  T min_x;
  T min_y;
  int N;
public:
  worldCreator();
  ~worldCreator();
  void setRange(T minX, T maxX, T minY, T maxY);
  T getMax_X();
  T getMin_X();
  T getMax_Y();
  T getMin_Y();
  void make_2D_World();
  int* getField();
  void setField(int* dataP, int N);
};

template <class T>
__global__ void fieldSet(T* field, int N);

#endif
