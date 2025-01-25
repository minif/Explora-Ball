#include "circle.h"
#include "simulation.h"
#include <cmath>

Circle::Circle() {
	x=0;
	y=0;
	rotation=0;
	weight=0;
	radius=1;
	width=radius*2;
	height=radius*2;
	maxRadius = radius;
}

Circle::Circle(double xval, double yval, double radiusval, double rotationval) {
	x=xval;
	y=yval;
	rotation=rotationval;
	weight=1;
	radius=radiusval;
	width=radius*2;
	height=radius*2;
	maxRadius = radiusval;
}

Circle::Circle(double xval, double yval, double radiusval, double rotationval, double weightValue) {
	x=xval;
	y=yval;
	rotation=rotationval;
	weight=weightValue;
	radius=radiusval;
	width=radius*2;
	height=radius*2;
	maxRadius = radiusval;
	
}

double Circle::getRadius() {
	return radius;
}

void Circle::setRadius(double newRadius) {
	radius = newRadius;
}

double Circle::getDistanceToEdge(double angle)  {
	return radius;
}

void Circle::setColisionCenter(double& xcol, double& ycol, double& colDistance, double xother, double yother) {
	xcol = x; 
	ycol = y;
	colDistance = radius;
}

int Circle::changeSize(double s) {
	double oldr = radius;
	double oldy = y;
	radius+=s;
	if (s>0) y+=s*2;
	if (radius>40) radius = 40;
	if (radius<2) radius = 2;
	colisionInfo colProperties[MAXOBJECTCOLLISIONS];
	int count = sim->isCollidingWithObject(this,colProperties);
	Object* colidingObject;
	for (int i=0; i<count; i++) {
		colidingObject = colProperties[i].other;
		if (colidingObject->inactiveStatus) continue;
		double canPushX = 0;
		double canPushY = 0;
		double distancePush = colProperties[i].distancePushingIn;
		double collidingAngle = (colProperties[i].direction);
		double distToMoveX = distancePush*cos(collidingAngle);
		double distToMoveY = -distancePush*sin(collidingAngle);
		colidingObject->push(distToMoveX,distToMoveY,collidingAngle,this,canPushX,canPushY);
	}
	if (count>0&&oldr<radius) {
		radius = oldr;
		y = oldy;
		return 0;
	}
	width=radius*2;
	height=radius*2;
	maxRadius = radius;
	
	

	return 1;
}