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
	xvel_static=0;
	yvel_static=0;
	rvel_static=0;
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
}

void Object::setY(double newY) {
	motionDirection = atan2(newY-y,0);
	y = newY;
}

void Object::setRotation(double newRotation) {

}

void Object::setWeight(double newWeight) {

}

void Object::move(double xPos, double yPos){
	
}

void Object::move(){

}

void Object::place(double xPos, double yPos) {

}

void Object::accelerate(double xVel, double yVel) {
	xvel+=xVel;
	yvel+=yVel;
}

void Object::rotateAngle(double angle, double& xx, double& yy ) {
	double xprime = xx*cos(angle)-yy*sin(angle);
	double yprime = xx*sin(angle)+yy*cos(angle);
	
	xx=xprime;
	yy=yprime;
}

void Object::staticUpdate() {
	if (!xvel_static && !yvel_static && !rvel_static) return;
	double oldx=x;
	double oldy=y;
	double oldr=rotation;
	x+=xvel_static;
	y+=yvel_static;
	rotation+=rvel_static;
	
	colisionInfo colProperties[MAXOBJECTCOLLISIONS];
	int count = sim->isCollidingWithObject(this,colProperties);
	Object* colidingObject;
	int couldPush = 1;
	for (int i=0; i<count; i++) {
		colidingObject = colProperties[i].other;
		double xd = colProperties[i].distancePushingIn*cos(colProperties[i].direction);
		double yd = colProperties[i].distancePushingIn*sin(colProperties[i].direction);
		couldPush &= colidingObject->hardPush(xd,-yd);
	}
	
	if (!couldPush) {
		x=oldx;
		y=oldy;
		rotation=oldr;
		
	}
}

void Object::update() {
	if (weight==0) {
		xvel=0;
		yvel=0;
		staticUpdate();
		return;
	}
	double oldx=x;
	double oldy=y;
	x+=xvel;
	y+=yvel;
	colisionInfo colProperties[MAXOBJECTCOLLISIONS];
	int count = sim->isCollidingWithObject(this,colProperties);
	Object* colidingObject;
	for (int i=0; i<count; i++) {
		colidingObject = colProperties[i].other;
		//colProperties[i].direction;
		//colProperties[i].distancePushingIn;
		
		
		//2D (elastic) collision! (Using rotation matrix to turn into 1D)
		//First get temporary values of other weight and velocity
		double otherWeight = colidingObject->getWeight();
		double otherXVel = colidingObject->xvel;
		double otherYVel = colidingObject->yvel;
		double newVel;
		double newVelOther;
		
		//Get the angle difference between the collision normal and direction of motion
		double currentDirection = atan2(yvel,xvel);
		double collidingAngle = (colProperties[i].direction);
		
		//cout << ">>>Direction " << colProperties[i].direction*(180/3.14159265) << endl;
		//cout << "Colliding angle: " << collidingAngle*(180/3.14159265) << endl;
		//cout << "My Y Velocity: " << yvel << endl;
		//Align to new coordinate plane (so x = colliding plane, y = perpendicular)
		rotateAngle(collidingAngle,xvel,yvel);
		rotateAngle(collidingAngle,otherXVel,otherYVel);
		
		if (abs(xvel)>0.01||abs(otherXVel)>0.01) {
		//cout << xvel << endl;
		//cout << otherXVel << endl;
		//cout << "My Collision Velocity: " << xvel << endl;
		//cout << "My Y Velocity: " << yvel << endl;
			if (otherWeight!=0) {
				//Solve 1D collision
				newVel = (xvel*(weight-otherWeight)+2*otherWeight*otherXVel)/(weight+otherWeight);
				newVelOther = (otherXVel*(otherWeight-weight)+2*weight*xvel)/(weight+otherWeight);
			} else {
				newVel = -xvel;
				newVelOther = otherXVel;
			}
		
		
			xvel = newVel/1.5;
			otherXVel = newVelOther/1.5;
		}
		
		
		//cout << "My Velocity: " << xvel << endl;
		//cout << "My Y Velocity: " << yvel << endl;
		//Rotate back
		rotateAngle(-collidingAngle,xvel,yvel);
		rotateAngle(-collidingAngle,otherXVel,otherYVel);
		//cout << "My Y Velocity: " << yvel << endl;
		if (otherWeight!=0) {
			//Apply values
			colidingObject->xvel = otherXVel;
			colidingObject->yvel = otherYVel;
		}
		
		//rotateAngle(3.14159265,xvel,yvel);
		//rotateAngle(3.14159265,colidingObject->xvel,colidingObject->yvel);
		
		//PUSHING!
		double distancePush = colProperties[i].distancePushingIn;
		double distToMoveX = distancePush*cos(collidingAngle);
		double distToMoveY = -distancePush*sin(collidingAngle);
		double canPushX = 0;
		double canPushY = 0;
		colidingObject->push(distToMoveX,distToMoveY,collidingAngle,this,canPushX,canPushY);
		x-=(distToMoveX-canPushX);
		y-=(distToMoveY-canPushY);
	}
	if (sim->isCollidingWithObject(this,colProperties)) { //Might remove???
		x=oldx;
		y=oldy;
	}
}

void Object::rotate(double angleDeg) {
	rotation+=angleDeg;
	motionDirection = -99;
	//This one is dependent on where the collision happens, probably better to just push out
	handleColision();
}

void Object::push(double pushX, double pushY, double angle, Object* other,double& successfulPushX, double& successfulPushY) {
	rotateAngle(angle,pushX,pushY);
	successfulPushX = 0;
	successfulPushY = pushY;
	if (weight!=0) {
		rotateAngle(angle,xvel,yvel);
		rotateAngle(angle,other->xvel,other->yvel);
		if (abs(other->xvel-xvel)<0.02)
			xvel*=2;
		
		rotateAngle(-angle,xvel,yvel);
		rotateAngle(-angle,other->xvel,other->yvel);
	}
	rotateAngle(-angle,successfulPushX,successfulPushY);	
}

int Object::hardPush(double pushX, double pushY) {
	if (weight==0) return 0;
	double oldX = x;
	double oldY = y;
	x+=pushX*1.01;
	y+=pushY*1.01;
	xvel+=pushX;
	yvel+=pushY;
	
	colisionInfo colProperties[MAXOBJECTCOLLISIONS];
	int count = sim->isCollidingWithObject(this,colProperties);
	Object* colidingObject;
	int couldPush = 1;
	for (int i=0; i<count; i++) {
		colidingObject = colProperties[i].other;
		if (colProperties[i].distancePushingIn>0.01) {
			double xd = colProperties[i].distancePushingIn*cos(colProperties[i].direction);
			double yd = colProperties[i].distancePushingIn*sin(colProperties[i].direction);
			couldPush &= colidingObject->hardPush(pushX,pushY);
		}
	}
	if (!couldPush) {
		double currentDirection = atan2(pushX,pushY);
		double tempx = x;
		double tempy = y;
		for (int i=0; i<10; i++) {
			x = tempx;
			y = tempy;
			rotateAngle(currentDirection,x,y);
			x += i;
			rotateAngle(-currentDirection,x,y);
			if (!sim->isCollidingWithObject(this,colProperties)) return 1;
			x = tempx;
			y = tempy;
			rotateAngle(currentDirection,x,y);
			x -= i;
			rotateAngle(-currentDirection,x,y);
			if (!sim->isCollidingWithObject(this,colProperties)) return 1;
		}
		x = oldX;
		y = oldY;
		return 0;
	}
	return 1;
}

void Object::handleColision() {
	

}

void Object::handleColision(double& pushBackX, double& pushBackY) {
	
}





