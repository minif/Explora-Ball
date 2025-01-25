#include "object.h"
#include "simulation.h"
#include <iostream>
using namespace std;

#define MAX_COLISIONS 1;

Object::Object() {
	x=0;
	y=0;
	xvel=0;
	yvel=0;
	rotation=0;
	weight=0;
}

Object::Object(double xval, double yval, double rotationval) {
	x=xval;
	y=yval;
	xvel=0;
	yvel=0;
	rotation=rotationval;
	weight=0;
}

Object::Object(double xval, double yval, double rotationval, double weightValue) {
	x=xval;
	y=yval;
	xvel=0;
	yvel=0;
	rotation=rotationval;
	weight=weightValue;
}

void Object::addSim(Simulation* s) {
	sim = s;
}

void Object::setColisionCenter(double& xcol, double& ycol, double& colDistance, double xother, double yother) {
	xcol = x; //Not implemented in base object class
	ycol = y;
	colDistance = 0;
	cout << "this should not be called" << endl;
}

double Object::getDistanceToEdge(double angle) {
	return 0; //Not implemented in the base object class
	//TODO: add whatever specific c++ inheritance practice that implements this
}

double Object::getX() {
	return x;
}

double Object::getY() {
	return y;
}

double Object::getRotation() {
	return rotation;
}

double Object::getWeight() {
	return weight;
}

void Object::setX(double newX) {
	motionDirection = atan2(0,newX-x);
	x = newX;
	handleColision();
}

void Object::setY(double newY) {
	motionDirection = atan2(newY-y,0);
	y = newY;
	handleColision();
}

void Object::setRotation(double newRotation) {
	rotation = newRotation;
}

void Object::setWeight(double newWeight) {
	weight = newWeight;
}

void Object::move(double xPos, double yPos){
	motionDirection = atan2(yPos,xPos);
	x+=xPos;
	y+=yPos;
	handleColision();
}

void Object::move(){
	if (!weight) return;
	motionDirection = atan2(yvel,xvel);
	x+=xvel;
	y+=yvel;
	handleColision();
}

void Object::place(double xPos, double yPos) {
	motionDirection = atan2(yPos-y,xPos-x);
	x=xPos;
	y=yPos;
	handleColision();
}

void Object::accelerate(double xVel, double yVel) {
	if (!weight) return;
	xvel+=xVel;
	yvel+=yVel;
}

void Object::rotate(double angleDeg) {
	rotation+=angleDeg;
	motionDirection = -99;
	//This one is dependent on where the collision happens, probably better to just push out
	handleColision();
}

void Object::push(double dir,double distance,double wt,double& pushBackX,double& pushBackY) {
	if (distance<PUSH_TOLERANCE) return;
	double distToMoveX = distance*cos(dir);
	double distToMoveY = -distance*sin(dir);
	if (weight==0) {
		pushBackX=-distToMoveX;
		pushBackY=-distToMoveY;
		return;
	}
	return;
	double totalWeight=weight+wt;
	motionDirection = atan2(distToMoveY,distToMoveX);
	x+=distToMoveX;//*(weight/totalWeight);
	y+=distToMoveY;//*(weight/totalWeight);
	handleColision(pushBackX, pushBackY);
	x+=pushBackX;
	y+=pushBackY;
	//pushBackX=-distToMoveX*(weight/totalWeight);
	//pushBackY=-distToMoveY*(weight/totalWeight);
}

void Object::handleColision() {
	double xc = 0;
	double yc = 0;
	handleColision(xc, yc);
	x+=xc;
	y+=yc;
}

void Object::handleColision(double& pushBackX, double& pushBackY) {
	Object* colidingObject;
	int colisions = MAX_COLISIONS;
	colisionInfo colProperties[MAXOBJECTCOLLISIONS];
	
	int count = sim->isCollidingWithObject(this,colProperties);
	
	for (int i=0; i<count; i++) {
		cout << "COLLISION!!!!!!!!!!!!!!!!!!!!!!  " << i << endl;
		colidingObject = colProperties[i].other;
		double pbx = 0;
		double pby = 0;
		colidingObject->push(colProperties[i].direction, colProperties[i].distancePushingIn, weight, pbx, pby);
		if (pbx*pushBackX>=0) {
			if (abs(pbx)>abs(pushBackX)) pushBackX=pbx;
		} else {
			pushBackX-=pbx;
		}
		if (pby*pushBackY>=0) {
			if (abs(pby)>abs(pushBackY)) pushBackY=pby;
		} else {
			pushBackY-=pby;
		}
		
		cout << pushBackY << endl;
		cout << colProperties[i].other << endl;
	}
	
	if (pushBackY!=0||pushBackX!=0) {
		
		double dir1 = atan2(-yvel,-xvel);
		double dir2 = atan2(pushBackY,pushBackX);
		double angle = dir2-dir1;
		
		cout << "angle "<<angle*180/3.14159265358979<<endl;
		
		double xprime = xvel*cos(-angle*2)-yvel*sin(-angle*2);
		double yprime = xvel*sin(-angle*2)+yvel*cos(-angle*2);
		
		xvel=xprime/1;
		yvel=yprime/1;
		return;
		xprime = xvel*cos(-dir1)-yvel*sin(-dir1);
		yprime = xvel*sin(-dir1)+yvel*cos(-dir1);
		
		xvel=xprime;
		yvel=yprime;
		//x+=xvel;
		//y+=yvel;
	}
	
	
	/*
	do {
		
		if (!colidingObject) break;
		
		cout << colProperties.direction*180/3.14159265<<endl;
		cout << colProperties.distancePushingIn<<endl;
		
	} while (colidingObject!=nullptr&&--colisions);
	*/
}





