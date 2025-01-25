#include "square.h"
#include <cmath>
#include <iostream>
#include <stdlib.h>
using namespace std;

Square::Square() {
	x=0;
	y=0;
	rotation=0;
	weight=0;
	width=1;
	height=1;
	maxRadius = sqrt((width/2)*(width/2)+(height/2)*(height/2));
}

Square::Square(double xval, double yval, double widthval, double heightval, double rotationval) {
	x=xval;
	y=yval;
	rotation=rotationval;
	weight=1;
	width=widthval;
	height=heightval;
	maxRadius = sqrt((width/2)*(width/2)+(height/2)*(height/2));
}

Square::Square(double xval, double yval, double widthval, double heightval, double rotationval, double weightValue) {
	x=xval;
	y=yval;
	rotation=rotationval;
	weight=weightValue;
	width=widthval;
	height=heightval;
	maxRadius = sqrt((width/2)*(width/2)+(height/2)*(height/2));
}

double Square::getWidth() {
	return width;
}

void Square::setWidth(double newWidth) {
	width = newWidth;
}

double Square::getHeight() {
	return height;
}

void Square::setHeight(double newHeight) {
	height = newHeight;
}

void Square::setDimentions(double newWidth, double newHeight) {
	width = newWidth;
	height = newHeight;
}

double Square::getDistanceToEdge(double angle)  {
	angle+=rotation*(3.1415926535/180);
	return fmin(width/2*abs(1/cos(angle)),height/2*abs(1/sin(angle)));
}

double clamp(double val, double min, double max) {
	if (val<min) return min;
	if (val>max) return max;
	return val;
}

void Square::setColisionCenter(double& xcol, double& ycol, double& colDistance, double xother, double yother) {
	//First, translate and rotate other point relative to center of this rotation
	xother-=x;
	yother-=y;
	
	double xprime = xother*cos(-rotation*(3.1415926535/180))-yother*sin(-rotation*(3.1415926535/180));
	double yprime = xother*sin(-rotation*(3.1415926535/180))+yother*cos(-rotation*(3.1415926535/180));
	
	//Now do bounds check
	/*
	if (xprime>-width/2&&xprime<width/2) { //in line vertical
		cout << "In line vertical " << xprime << "+-" << width/2 << endl;
		yprime = 0;
		colDistance = height/2;
	} else if (yprime>-height/2&&yprime<height/2) {//in line horizontal
		cout << "In line horizontal " << yprime << "+-" << height/2 << endl;
		xprime = 0; 
		colDistance = width/2;
	} else {
		xprime=0;
		yprime=0;
		colDistance = 0;
	}
	*/
	xprime = clamp(xprime, -width/2, width/2);
	yprime = clamp(yprime, -height/2, height/2);
	colDistance = 0;
	
	//Rotate and translate xcol and ycol back
	xcol = xprime*cos(rotation*(3.1415926535/180))-yprime*sin(rotation*(3.1415926535/180));
	ycol = xprime*sin(rotation*(3.1415926535/180))+yprime*cos(rotation*(3.1415926535/180));
	
	xcol+=x;
	ycol+=y;
}