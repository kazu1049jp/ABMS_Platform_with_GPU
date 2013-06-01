#ifndef _WORLDCREATOR_
#define _WORLDCREATOR_
class worldCreator{
private:
	int* field;
	int max_x;
	int max_y;
	int min_x;
	int min_y;
public:
	worldCreator();
	~worldCreator();
	void setRange(int minX, int maxX, int minY, int maxY);
	int getMax_X();
	int getMin_X();
	int getMax_Y();
	int getMin_Y();
	void make_2D_World();
	int* getField();
};

#endif
