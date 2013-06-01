/*
  とりあえず整数型にしているが、あとでテンプレートで柔軟性を持たせること
*/


#include "worldDefinition.h"
#include <iostream>
#include <string>
#include <fstream>
#include <sstream>

using namespace std;

template <class T>
worldDefinition<T>::worldDefinition(){
  string max_x, max_y, min_x, min_y;
  string str;
  ifstream ifs("model.props");
  getline(ifs, str);
  getline(ifs, str);
  max_x = str;
  getline(ifs, str);
  getline(ifs, str);
  max_y = str;
  getline(ifs, str);
  getline(ifs, str);
  min_x = str;
  getline(ifs, str);
  getline(ifs, str);
  min_y = str;

  /*文字列データを数値へ変換*/
  stringstream ss;
  ss << max_x;
  ss >> this->maxX;
  ss.clear();
  ss.str("");
  //cout << "maxX:" << this->maxX << endl;
  ss << max_y;
  ss >> this->maxY;
  ss.clear();
  ss.str("");
  //cout << "maxY:" << this->maxY << endl;
  ss << min_x;
  ss >> this->minX;
  ss.clear();
  ss.str("");
  //cout << "minX:" << this->minX << endl;
  ss << min_y;
  ss >> this->minY;
  ss.clear();
  ss.str("");
  //cout << "minY:" << this->minY << endl;
}
template worldDefinition<int>::worldDefinition();
template worldDefinition<float>::worldDefinition();
template worldDefinition<double>::worldDefinition();

template <class T>
worldDefinition<T>::~worldDefinition(){
}
template worldDefinition<int>::~worldDefinition();
template worldDefinition<float>::~worldDefinition();
template worldDefinition<double>::~worldDefinition();

template <class T>
T worldDefinition<T>::getMax_X(){
  return this->maxX;
}
template int worldDefinition<int>::getMax_X();
template float worldDefinition<float>::getMax_X();
template double worldDefinition<double>::getMax_X();

template <class T>
T worldDefinition<T>::getMax_Y(){
  return this->maxY;
}
template int worldDefinition<int>::getMax_Y();
template float worldDefinition<float>::getMax_Y();
template double worldDefinition<double>::getMax_Y();

template <class T>
T worldDefinition<T>::getMin_X(){
  return this->minX;
}
template int worldDefinition<int>::getMin_X();
template float worldDefinition<float>::getMin_X();
template double worldDefinition<double>::getMin_X();

template <class T>
T worldDefinition<T>::getMin_Y(){
  return this->minY;
}
template int worldDefinition<int>::getMin_Y();
template float worldDefinition<float>::getMin_Y();
template double worldDefinition<double>::getMin_Y();

template <class T>
void worldDefinition<T>::setMax_X(T x){
  this->maxX = x;
}
template void worldDefinition<int>::setMax_X(int x);
template void worldDefinition<float>::setMax_X(float x);
template void worldDefinition<double>::setMax_X(double x);

template <class T>
void worldDefinition<T>::setMax_Y(T y){
  this->maxY = y;
}
template void worldDefinition<int>::setMax_Y(int y);
template void worldDefinition<float>::setMax_Y(float y);
template void worldDefinition<double>::setMax_Y(double y);

template <class T>
void worldDefinition<T>::setMin_X(T x){
  this->minX = x;
}
template void worldDefinition<int>::setMin_X(int x);
template void worldDefinition<float>::setMin_X(float x);
template void worldDefinition<double>::setMin_X(double x);

template <class T>
void worldDefinition<T>::setMin_Y(T y){
  this->minY = y;
}
template void worldDefinition<int>::setMin_Y(int y);
template void worldDefinition<float>::setMin_Y(float y);
template void worldDefinition<double>::setMin_Y(double y);
