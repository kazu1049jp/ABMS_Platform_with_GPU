#ifndef _WORLDDEF_
#define _WORLDDEF_

template <class T>
class worldDefinition{
 private:
  T maxX;
  T maxY;
  T minX;
  T minY;

 public:
  worldDefinition();
  ~worldDefinition();
  T getMax_X();
  T getMax_Y();
  T getMin_X();
  T getMin_Y();
  void setMax_X(T x);
  void setMax_Y(T y);
  void setMin_X(T x);
  void setMin_Y(T y);
};



#endif
