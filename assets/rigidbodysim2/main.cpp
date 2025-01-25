#include <SFML/Graphics.hpp>
#include "simulation.h"
#include "object.h"
#include "circle.h"
#include "square.h"
#include <iostream>
using namespace std;

int main()
{
	
	Simulation sim;
	cout << "test";
	Circle o(150,20000,30,0,1);
	//Circle o3(250,150,30,0,1);
	Circle circles[] = {Circle(50,50,15,0,1),Circle(200,-20,15,0,1),
						Circle(100,0,15,0,1),Circle(150,0,15,0,1),
						Circle(100,40,15,0,1),Circle(150,40,15,0,1),
						Circle(100,80,15,0,1),Circle(150,80,15,0,1),
						Circle(100,120,15,0,1),Circle(150,120,15,0,1),
						Circle(100,160,15,0,1),Circle(150,160,15,0,1),
						Circle(250,100,15,0,1),Circle(200,200,15,0,1)};
	//Square o2(150,150,30,200,45,0);
	Square squares[] = {Square(200,230,30,200,90,0),Square(50,250,30,200,-45,0),Square(200,300,30,200,90,0),Square(350,250,30,200,45,0),
						Square(0,0,30,1000,0,0),Square(400,0,30,1000,0,0),Square(-100,-40,1000,30,0,0)};
	
    sf::RenderWindow window(sf::VideoMode(480, 320), "SFML works!");
    sf::CircleShape shape(100.f);
    
    sf::CircleShape debug(1.f);
    double debugX, debugY;
    
    sf::RectangleShape rectangleee(sf::Vector2f(120.f, 50.f));
    //rectangleee.setSize(sf::Vector2f(100.f, 100.f));
    rectangleee.rotate(45.f);
    shape.setFillColor(sf::Color::Green);
    rectangleee.setFillColor(sf::Color::Red);
    debug.setFillColor(sf::Color::Blue);
    
    cout << o.getDistanceToEdge(0) << endl;
    //cout << o2.getDistanceToEdge(0.785398163397448) << endl;
    
    sim.addToSimulation(&o);
    
    int csize=6;//14
    for (int i=0; i<csize; i++) sim.addToSimulation(&circles[i]);
    
    sf::CircleShape gfxcircles[csize];
    
    int ssize=7;
    for (int i=0; i<ssize; i++) sim.addToSimulation(&squares[i]);
    
    sf::RectangleShape gfxsquares[ssize];

	int i = 0;
	
    
	sim.gravityX=0;
	sim.gravityY=0.001;
	
	

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }
        
        sf::Vector2i localPosition = sf::Mouse::getPosition(window);
        
        sim.gravityX=0;
        
        if (sf::Mouse::isButtonPressed(sf::Mouse::Left)) {
        	o.place(localPosition.x,localPosition.y);
        	//o.xvel=0;
        	sim.gravityX=-0.002;
        	//o.yvel=0;
        }
        
        if (sf::Mouse::isButtonPressed(sf::Mouse::Right)) {
        	o.place(localPosition.x,localPosition.y);
        	//o.xvel=0;
        	sim.gravityX=0.002;
        	//o.yvel=0;
        }
        i++;
        cout << i/60 << endl;
        
        
        squares[0].rvel_static=0.1;
        
        //sim.isCollidingWithObject(&o,debugX, debugY);
        
        shape.setOrigin(o.getRadius(),o.getRadius());
		shape.setRadius(o.getRadius());
		shape.setPosition(o.getX(),o.getY());
		shape.setRotation(o.getRotation());
		sim.updateSimulation();
        window.clear();
        
        for(int j=0; j<csize; j++) {
        	//circles[j].move(0,1);
    		gfxcircles[j].setOrigin(circles[j].getRadius(),circles[j].getRadius());
			gfxcircles[j].setRadius(circles[j].getRadius());
			gfxcircles[j].setPosition(circles[j].getX(),circles[j].getY());
			gfxcircles[j].setRotation(circles[j].getRotation());
			gfxcircles[j].setFillColor(sf::Color::Blue);
			window.draw(gfxcircles[j]);
    	}
    
    	for(int j=0; j<ssize; j++) {
    		gfxsquares[j].setOrigin(squares[j].getWidth()/2,squares[j].getHeight()/2);
			gfxsquares[j].setSize(sf::Vector2f(squares[j].getWidth(),squares[j].getHeight()));
			gfxsquares[j].setPosition(squares[j].getX(),squares[j].getY());
			gfxsquares[j].setRotation(squares[j].getRotation());
			gfxsquares[j].setFillColor(sf::Color::Red);
			window.draw(gfxsquares[j]);
    	}
        window.draw(shape);
        window.display();
        
        sf::sleep(sf::milliseconds(1000/60));
        //cout << sim.objectCollection[1]->getX() << endl;
    }

    return 0;
    
}