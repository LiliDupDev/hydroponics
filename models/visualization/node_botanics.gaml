/**
* Name: nodebotanics
* This is the grapich agent of a node element in a tomato plant. Node can become a truss or a leaf. 
* Author: Liliana Durán-Polanco
* Tags: 
*/


model nodebotanics

global
{
	geometry shape 	<- 	rectangle(50,50);
	float scale 	<-	0.1;
	
	float 	width 		<- shape.width;
	float 	height 		<- shape.height;
	point 	main_pos 	<- {0,0};//{width / 2, height / 2};
	
	image_file f_leaf <- image_file("../../includes/img/leaf.png");
	
	init
	{
		create tomato_node number:1
		{
			beta	<- 45.0;
			alpha	<- 0.0;
			base 	<- main_pos;
			end 	<- base + {	spine_length * cos(beta) * cos(alpha), 
								spine_length * cos(beta) * sin(alpha), 
								spine_length * sin(beta)
							};
			//end		<- main_pos+{0,0,spine_length};
		}
	}
	
}


species tomato_node parent:plant_part
{
	bool 	is_truss ;
	int 	leaflet	  	<- 7;
	float	base_angle	<- 45.0;
	float	spine_length<- 20.0;
	
	//pair<float, point> rota <- rotation_composition(float(rnd(180))::{1, 0, 0}, float(rnd(180))::{0, 1, 0}, float(rnd(180))::{0, 0, 1});
	
	
	
	aspect default
	{
		
		//pair<float,point> r0 <-  -90::{1,0,0};	
		//pair<float,point> pitch <-  5 * cos(cycle*10) ::{1,0,0};
		//pair<float,point> roll <- 20*sin(cycle*3)::{0,1,0};
		//pair<float,point> yaw <- 1*sin(cycle*7)::{0,0,1};
		
		// Spine
		draw line([base, end], 1) color: #green;
		
		pair<float,point> rot_spine <- rotation_composition(alpha::{0,0,1}, beta::{0,1,0});
		
		// End Leaflet
		pair<float, point> rota <- rotation_composition(beta::{0,1,0}, 45::{0,0,1},-90::{1,0,0});
		//draw f_leaf size: 10 rotate:rota at: end+{0,0,3};
		draw f_leaf size: 10 rotate:rota at: end;
		
		// Leaflet 1
		//rota <- rotation_composition(rot_spine,-90::{1,0,0});
		//draw f_leaf size: 8 rotate:rota at: end-{3,0,5};
		//
		//// Leaflet 3
		//rota <- rotation_composition(rot_spine,-90::{1,0,0},-180::{0,0,1});
		//draw f_leaf size: 8 rotate:rota at: end+{3,0,-5};
		//
		//// Leaflet 4
		//rota <- rotation_composition(rot_spine,-90::{1,0,0});
		//draw f_leaf size: 7 rotate:-90::{1,0,0} at: end-{3,0,12};
		//
		//// Leaflet 5
		//rota <- rotation_composition(rot_spine,-90::{1,0,0},-180::{0,0,1});
		//draw f_leaf size: 7 rotate:rota at: end+{3,0,-12 };
		
		//draw triangle(2) rotate: rota at: end color: #lime;
	}
}


species plant_part
{
	plant_part 	parent		<- nil;
	
	// position
	point 		base 		<- {0, 0, 0};
	point 		end 		<- {0, 0, 0};
	float 		alpha 		<- 0.0;
	float 		beta 		<- 0.0;
	float		gamma		<- 0.0;
	
	// visualization attributes
	float		length		<- 5.0;
	float 		width		<- 2.0;
	
	// animation attributes
	float 		energy  <- 0.0;
	float 		level 	<- 1.0;
}

experiment drawing type: gui autorun: false 
{	
	
	// Screen
	output {
		display 'Leaf' type: opengl {
			species tomato_node;
		}
			
			
	}
	
		
}
