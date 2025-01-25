#include <iostream>
using namespace std;

#include <fstream>
#include <sstream>

#define FILE_NAME  "bg5.obj"

int main() {
//Start out by reading the number of lines
	ifstream s;
	s.open(FILE_NAME);
	string line;
	int vcount = 0;
	int fcount = 0;
	int vtcount=0;
	while (getline(s,line)) {
		if (line[0] == 'v'&&line[1]==' ') vcount++;
		if (line[0] == 'v'&&line[1]=='t') vtcount++;
		if (line[0] == 'f') fcount++;
	}
	s.close();
	
	string verts[vcount];
	int indx = 0;
	int indx2 = 0;
	
	short sverts[vcount][3];
	short stverts[vtcount][2];
	
	s.open(FILE_NAME);
	while (getline(s,line)) {
		//cout << "test";
		if (line[0] == 'v'&&line[1]==' '){
			cout << line << endl;
			stringstream ss(line);
			string s;
			string v1;
			string v2; 
			string v3;
			ss >> s;
			ss >> v1;
			ss >> v2;
			ss >> v3;
			
			double d1 = stod(v1)*256;
			double d2 = stod(v2)*256;
			double d3 = stod(v3)*256;
			
			short sh1 = d1+0;
			short sh2 = d2+0;
			short sh3 = d3+0;
			
			sverts[indx][0]=sh1;
			sverts[indx][1]=sh2;
			sverts[indx][2]=sh3;
			
			verts[indx] = v1 + ", " + v2 + ", " +v3 + ", \n"; 
			//cout << verts[indx] << endl;
			cout << indx << ": "<< sverts[indx][0] << " " << sverts[indx][1]+0 << " " << sverts[indx][2] << endl;
			indx++;
		}
		
		if (line[0] == 'v'&&line[1]=='t'){
			cout << line << endl;
			stringstream ss(line);
			string s;
			string v1;
			string v2; 
			ss >> s;
			ss >> v1;
			ss >> v2;
			
			double d1 = stod(v1)*256;
			double d2 = (1-stod(v2))*256;
			
			short sh1 = d1+0;
			short sh2 = d2+0;
			
			stverts[indx2][0]=sh1;
			stverts[indx2][1]=sh2;
			
			//cout << verts[indx] << endl;
			cout << indx << ": "<< sverts[indx][0] << " " << sverts[indx][1]+0 << " "  << endl;
			indx2++;
		}
	}
	s.close();
	
	cout << "Done doing verts, doing faces now" << endl;
	ofstream out;
	ofstream out2;
	out.open("out.bin",std::ios::app | std::ios::binary);
	out2.open("out.binmap",std::ios::app | std::ios::binary);
	s.open(FILE_NAME);
	int finalcount = 0;
	while (getline(s,line)) {
		//cout << "test";
		if (line[0] == 'f'){
			cout << line << endl;
			stringstream ss(line);
			string s;
			string s1;
			string s2;
			string s3;
			string sv1;
			string sv2; 
			string sv3;
			string svt1;
			string svt2;
			string svt3;
			ss >> s;
			ss >> s1;
			ss >> s2;
			ss >> s3;
			stringstream ss1(s1);
			getline(ss1,sv1,'/');
			getline(ss1,svt1,'/');
			stringstream ss2(s2);
			getline(ss2,sv2,'/');
			getline(ss2,svt2,'/');
			stringstream ss3(s3);
			getline(ss3,sv3,'/');
			getline(ss3,svt3,'/');
			
			cout << "v" <<sv1 << sv2 << sv3 << "vt"<<svt1 << svt2 << svt3 << endl;
			int v1=stoi(sv1);
			int v2=stoi(sv2); 
			int v3=stoi(sv3);
			int vt1=stoi(svt1);
			int vt2=stoi(svt2);
			int vt3=stoi(svt3);
			
			
			//out << verts[v1-1];
			//out << verts[v2-1];
			//out << verts[v3-1];
			
			cout << "For face: " << s1 << " " << s2 << " " << s3 << ": " << endl;
			cout << v1-1 << ": "<< sverts[v1-1][0] << " " << sverts[v1-1][1]+0 << " " << sverts[v1-1][2] << endl;
			cout << v2-1 << ": "<< sverts[v2-1][0] << " " << sverts[v2-1][1]+0 << " " << sverts[v2-1][2] << endl;
			cout << v3-1 << ": "<< sverts[v3-1][0] << " " << sverts[v3-1][1]+0 << " " << sverts[v3-1][2] << endl;
			
			for (int i=0; i<3; i++) {
				uint16_t in1 = sverts[v1-1][i];
				uint8_t out1[2];
				
				out1[0] = (in1 >> 8) & 0xFF; // put highest in byte in first out byte
				out1[1] = in1 & 0xFF; // put lowest in byte in second out byte
				
				cout<<in1<<"->";
				cout<<out1[0]+0<<","<<out1[1]+0<<" "<<endl;
				cout<<sverts[v1-1][i]<<"->" <<endl;
				
				
				out.write(reinterpret_cast<char*>(&in1), sizeof(short));
				
				if (i!=2) {
					uint16_t ee1 = stverts[vt1-1][i];
					out2.write(reinterpret_cast<char*>(&ee1), sizeof(short));
				}
			}
			cout << "---" << endl;
			for (int i=0; i<3; i++) {	
				uint16_t in2 = sverts[v2-1][i];
				//uint8_t out2[2];
				
				//out2[0] = (in2 >> 8) & 0xFF; // put highest in byte in first out byte
				//out2[1] = in2 & 0xFF; // put lowest in byte in second out byte
				
				cout<<in2<<"->";
				//cout<<out2[0]+0<<","<<out2[1]+0<<" "<<endl;
				
				out.write(reinterpret_cast<char*>(&in2), sizeof(short));
				
				if (i!=2) {
					uint16_t ee1 = stverts[vt2-1][i];
					out2.write(reinterpret_cast<char*>(&ee1), sizeof(short));
				}
			}
			cout << "---" << endl;
			for (int i=0; i<3; i++) {	
				uint16_t in3 = sverts[v3-1][i];
				uint8_t out3[2];
			
				out3[0] = (in3 >> 8) & 0xFF; // put highest in byte in first out byte
				out3[1] = in3 & 0xFF; // put lowest in byte in second out byte
				
				cout<<in3<<"->";
				cout<<out3[0]+0<<","<<out3[1]+0<<" "<<endl;
				
				out.write(reinterpret_cast<char*>(&in3), sizeof(short));
				
				if (i!=2) {
					uint16_t ee1 = stverts[vt3-1][i];
					out2.write(reinterpret_cast<char*>(&ee1), sizeof(short));
				}
				
			}
			
			
			
			finalcount+=3;
		}
	}
	//s.close();
	out.close();
	
	cout << finalcount;
}