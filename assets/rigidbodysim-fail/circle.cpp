#include "circle.h"

Circle::Circle() {
	x=0;
	y=0;
	rotation=0;
	weight=0;
	radius=1;
}

Circle::Circle(double xval, double yval, double radiusval, double rotationval) {
	x=xval;
	y=yval;
	rotation=rotationval;
	weight=1;
	radius=radiusval;
}

Circle::Circle(double xval, double yval, double radiusval, double rotationval, double weightValue) {
	x=xval;
	y=yval;
	rotation=rotationval;
	weight=weightValue;
	radius=radiusval;
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