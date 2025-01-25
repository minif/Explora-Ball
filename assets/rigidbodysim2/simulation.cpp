#include "simulation.h"
#include "math.h"
#include <iostream>
using namespace std;

Simulation::Simulation() {
	objCount = 0;
}

void Simulation::updateSimulation() {	
	for (int times=0; times<10; times++)
	for (int i=0; i<objCount; i++) {
		objectCollection[i]->accelerate(gravityX,gravityY);
		objectCollection[i]->update();
	}
}

void Simulation::addToSimulation(Object* o) {
	objectCollection[objCount] = o;
	o->addSim(this);
	objCount++;
}

double Simulation::debugColision(Object* self, Object* other) {
	double x1,y1,d1,x2,y2,d2;
	self->setColisionCenter(x1,y1,d1, other->getX(), other->getY());
	other->setColisionCenter(x2,y2,d2, self->getX(), self->getY());
	double xdiff = x2-x1;
	double ydiff = y2-y1;
	double totalDistance = sqrt(xdiff*xdiff+ydiff*ydiff);
	return (d1+d2)-totalDistance;
}

int Simulation::isCollidingWithObject(Object* self, colisionInfo (&col)[MAXOBJECTCOLLISIONS]) {
	/*
	This is called by an object after it moves. The calling object puts itself as the argument.
	*/
	
	int colCount = 0;
	
	for (int i=0; i<objCount; i++) {
		Object* other = objectCollection[i];
		//Check if objects are the same 
		if (self==other) continue;
		//Determine the "middle of collision"
		//In the case of the circle it is always the center
		//For a rectangle it is more complicated and thus must be determined.
		self->setColisionCenter(col[colCount].x1,col[colCount].y1,col[colCount].d1, other->getX(), other->getY());
		other->setColisionCenter(col[colCount].x2,col[colCount].y2,col[colCount].d2, self->getX(), self->getY());
		
		//Determine the "direction" fron the caller self to the other object
		double xdiff = col[colCount].x2-col[colCount].x1;
		double ydiff = col[colCount].y2-col[colCount].y1;
		col[colCount].direction = atan2(-ydiff,xdiff);
		//if (col.direction<0) col[colCount].direction+=3.1415926535;
		
		//Determine the "distance"
		double totalDistance = sqrt(xdiff*xdiff+ydiff*ydiff);
		
		//If distance<radius1+radius2 collision is happening!
		if (totalDistance<col[colCount].d1+col[colCount].d2) {
			col[colCount].distancePushingIn = (col[colCount].d1+col[colCount].d2)-totalDistance;
			col[colCount].other = other;
			colCount++;
			//return other;
		} else {
			//col[colCount].distancePushingIn = -1;
		}
	}
	
	//col.colisions = 
	return colCount;
	
}