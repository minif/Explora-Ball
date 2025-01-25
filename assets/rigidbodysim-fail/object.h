#ifndef OBJECT_H
#define OBJECT_H

#define PUSH_TOLERANCE 1.77636e-6

class Object;

struct colisionInfo {
	double x1, x2, y1, y2, d1, d2, direction, distancePushingIn;
	Object* other;
};

class Simulation;

class Object {
	public:
		double getX();
		double getY();
		double getRotation();
		double getWeight();
		void setX(double newX);
		void setY(double newY);
		void setRotation(double newRotation);
		void setWeight(double newWeight);
		double getDistanceToEdge(double angle);
		virtual void setColisionCenter(double& xcol, double& ycol, double& colDistance, double xother, double yother);
		Object();
		Object(double xval, double yval, double rotationval);
		Object(double xval, double yval, double rotationval, double weightValue);
		void addSim(Simulation* s);
		void move(double xPos, double yPos);
		void move();
		void place(double xPos, double yPos);
		void accelerate(double xVel, double yVel);
		void handleColision(double& pushBackX, double& pushBackY);
		void handleColision();
		void rotate(double angleDeg);
		void push(double dir,double distance,double wt,double& pushBackX,double& pushBackY);
	//protected:
		Simulation* sim;
		double x;
		double y;
		double rotation;
		double weight;
		double xvel;
		double yvel;
		double motionDirection;
};

#endif