#ifndef CIRCLE_H
#define CIRCLE_H

#include "object.h"

class Circle: public Object {
	public:
		double getRadius();
		void setRadius(double newRadius);
		Circle();
		Circle(double xval, double yval, double radiusval, double rotationval);
		Circle(double xval, double yval, double radiusval, double rotationval, double weightValue);
		double getDistanceToEdge(double angle);
		void setColisionCenter(double& xcol, double& ycol, double& colDistance, double xother, double yother);
	private:
		double radius;
};


#endif