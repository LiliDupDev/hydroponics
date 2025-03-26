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
	point 	main_pos 	<- {width / 2, height / 2};
	
	image_file f_leaf <- image_file("../../includes/img/leaf.png");
	
	init
	{
		create tomato_node number:1
		{
			alpha 	<- 70 + gauss(0, 45);  
			beta 	<- 15 + gauss(0, 5);   
			
			base 	<- main_pos;
			end 	<- base + {	spine_length * cos(beta) * cos(alpha), 
								spine_length * cos(beta) * sin(alpha), 
								spine_length * sin(beta) 
							};
		}
	}
	
}


species tomato_node parent:plant_part
{
	bool 	is_truss ;
	float	spine_length		<- 20.0;
	float 	leaflet_base_size 	<- 1.0;
	float 	center				<- 0.5;
	
	list<bool> ls_visible_leaflet <- [];
	
	// Animation attributes
	float energy_division <- 5.0;
	
	//point tangent	<- 	 base update: vector_normalize({cos(beta) * cos(alpha), cos(beta) * sin(alpha), sin(beta)});
	
	point radial_dir <-  base update: vector_normalize({ -sin(alpha), cos(alpha), 0});
	
	
	point	leaflet_1 <- base update: base + {	spine_length * cos(beta) * cos(alpha) + cos(alpha) + radial_dir.x * 0.5, 
												spine_length * cos(beta) * sin(alpha) + sin(alpha) - radial_dir.y * 0.5, 
												spine_length * sin(beta) 
											};
											
	point	leaflet_2 <- base update: base + {	2*spine_length/3 * cos(beta) * cos(alpha) - radial_dir.x * 3, 
												2*spine_length/3 * cos(beta) * sin(alpha) - radial_dir.y * 3, 
												2*spine_length/3 * sin(beta) 
											};
											
	point	leaflet_3 <- base update: base + {	2*spine_length/3 * cos(beta) * cos(alpha) + radial_dir.x * 3, 
												2*spine_length/3 * cos(beta) * sin(alpha) + radial_dir.y * 3, 
												2*spine_length/3 * sin(beta) 
											};
											
	point	leaflet_4 <- base update: base + {	spine_length/3 * cos(beta) * cos(alpha) - radial_dir.x * 2, 
												spine_length/3 * cos(beta) * sin(alpha) - radial_dir.y * 2, 
												spine_length/3 * sin(beta) 
											};
											
	point	leaflet_5 <- base update: base + {	spine_length/3 * cos(beta) * cos(alpha) + radial_dir.x*2, 
												spine_length/3 * cos(beta) * sin(alpha) + radial_dir.y*2, 
												spine_length/3 * sin(beta) 
											};
	
	
	float vector_magnitude(point a)
	{
		return sqrt(a.x^2 + a.y^2 + a.z^2);
	}
	
	point vector_normalize(point a)
	{
		float magnitude <- vector_magnitude(a);
		return {a.x/magnitude, a.y/magnitude, a.z/magnitude};
	}
	
	
	aspect default
	{
	// Spine
		draw line([base, end], leaflet_base_size) color: #green;
		
		pair<float,point> rot_spine <- rotation_composition(alpha::{0,0,1}, beta::{0,1,0});
		pair<float,point> rot_leaflet_1 <- 45::{0,0,1};
		
	// Leaflets 
		pair<float, point> rota <- rotation_composition(rot_leaflet_1, rot_spine, 90::{0,0,1} , 15::{0,1,0});
		
		draw f_leaf size: 10 rotate:rota at: leaflet_1;
		
		rota <- rotation_composition(rot_spine,  90::{0,0,1}, beta::{0,1,0}); 
		draw f_leaf size: 9 rotate: rota at: leaflet_2;
		
		rota <- rotation_composition(rot_spine, 180::{0,0,1}, beta::{0,1,0});
		draw f_leaf size: 9 rotate: rota at: leaflet_3;
		
		rota <- rotation_composition(rot_spine,  90::{0,0,1}, beta::{0,1,0});  
		draw f_leaf size: 8 rotate: rota at: leaflet_4;
		
		rota <- rotation_composition(rot_spine, 180::{0,0,1}, beta::{0,1,0});
		draw f_leaf size: 8 rotate: rota at: leaflet_5;
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
