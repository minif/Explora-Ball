#ifndef SQUARE_H
#define SQUARE_H

#include "object.h"

class Square: public Object {
	public:
		double getWidth();
		double getHeight();
		void setWidth(double newWidth);
		void setHeight(double newHeight);
		void setDimentions(double newWidth, double newHeight);
		Square();
		Square(double xval, double yval, double widthval, double heightval, double rotationval);
		Square(double xval, double yval, double widthval, double heightval, double rotationval, double weightValue);
		double getDistanceToEdge(double angle);
		void setColisionCenter(double& xcol, double& ycol, double& colDistance, double xother, double yother);
};



#endif