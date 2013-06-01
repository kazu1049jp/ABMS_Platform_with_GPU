#include "output.h"
#include <fstream>

using namespace std;


/*ファイルにエージェントの座標データを書き込み*/
template <typename T>
void make_output_coordinates(vector<T> x, vector<T> y, int N){
  ofstream ofs("agent_coordinates.csv");
  ofs << "agent id,x,y" << endl;
  for (int i=0; i<N; ++i){
    ofs << i << "," <<  x[i] << "," << y[i] << endl;
  }
}
template void make_output_coordinates<int>(vector<int> x, vector<int> y, int N);
template void make_output_coordinates<float>(vector<float> x, vector<float> y, int N);
template void make_output_coordinates<double>(vector<double> x, vector<double> y, int N);
	
