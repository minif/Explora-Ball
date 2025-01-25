#ifndef SIMULATION_H
#define SIMULATION_H

#define MAXOBJECTCOLLISIONS 128
#define MAXOBJECTS 128

#include "object.h"

class Simulation {
	public:
		void updateSimulation();
		void addToSimulation(Object* o);
		int isCollidingWithObject(Object* self,  colisionInfo (&col)[MAXOBJECTCOLLISIONS]);
		Simulation();
		double debugColision(Object* self, Object* other);
	//private:
		int objCount;
		double gravityX;
		double gravityY;
		Object* objectCollection[MAXOBJECTS];
};

#endif