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
	float 	 scale 	<-	0.1;
	
	float 	width 		<- shape.width;
	float 	height 		<- shape.height;
	point 	main_pos 	<- {width / 2, height / 2};
	
	image_file f_leaf <- image_file("../../includes/img/leaf.png");
	
	init
	{
		step <- 1#h;
		
		create tomato_node number:1
		{
			alpha 	<- 70 + gauss(0, 45);  
			beta 	<- 15 + gauss(0, 5);   
			length	<- 0.0;
			width	<- 1.0;
			level	<- 1.3;
			
			base 	<- main_pos;
			end 	<- base + {	length * cos(beta) * cos(alpha), 
								length * cos(beta) * sin(alpha), 
								length * sin(beta) 
							};
		}
	}
	
}


species tomato_node parent:plant_part
{
	bool 	is_truss ;
	float 	center				<- 0.5;
	
	float	max_length			<- 260.0;
	float	energy_divisor		<- 5.0;
	float 	level_correction 	<- 1.8 * 0.3 ^ level;
	
	// Animation attributes
	float 				leaflet_energy_divisor	<- 2.5;
	map<string,int> 	leaflet_current_size 	<- ["leaflet_1":: 0  ,"leaflet_2":: 0  ,"leaflet_3":: 0  ,"leaflet_4":: 0  ,"leaflet_5":: 0  ];
	map<string,float> 	leaflet_max_size 		<- ["leaflet_1":: 7.0,"leaflet_2":: 5.0,"leaflet_3":: 5.0,"leaflet_4":: 4.0,"leaflet_5":: 4.0];
	map<string,float>	leaflet_energy_delay	<- ["leaflet_1":: 0.6,"leaflet_2":: 2.3,"leaflet_3":: 2.9,"leaflet_4":: 4.5,"leaflet_5":: 3.6];
	
	
	point radial_dir <-  base update: vector_normalize({ -sin(alpha), cos(alpha), 0});
	
	
	point	leaflet_1 <- base update: base + {	scale*length * cos(beta) * cos(alpha) + cos(alpha) + radial_dir.x * leaflet_current_size["leaflet_1"]/10 + width,
												scale*length * cos(beta) * sin(alpha) + sin(alpha) + radial_dir.y * leaflet_current_size["leaflet_1"]/15 , 
												scale*length * sin(beta) 
											};
											
	point	leaflet_2 <- base update: base + {	2/3*scale*length * cos(beta) * cos(alpha) - radial_dir.x * leaflet_current_size["leaflet_2"]/4,
												2/3*scale*length * cos(beta) * sin(alpha) - radial_dir.y * leaflet_current_size["leaflet_2"]/4,
												2/3*scale*length * sin(beta)                             
											};
											
	point	leaflet_3 <- base update: base + {	2/3*scale*length * cos(beta) * cos(alpha) + radial_dir.x * leaflet_current_size["leaflet_3"]/4, 
												2/3*scale*length * cos(beta) * sin(alpha) + radial_dir.y * leaflet_current_size["leaflet_3"]/4, 
												2/3*scale*length * sin(beta) 
											};
											
	point	leaflet_4 <- base update: base + {	scale*length/3 * cos(beta) * cos(alpha) - radial_dir.x * leaflet_current_size["leaflet_4"]/4,
												scale*length/3 * cos(beta) * sin(alpha) - radial_dir.y * leaflet_current_size["leaflet_4"]/4,
												scale*length/3 * sin(beta) 
											};
											
	point	leaflet_5 <- base update: base + {	scale*length/3 * cos(beta) * cos(alpha) + radial_dir.x * leaflet_current_size["leaflet_5"]/4, 
												scale*length/3 * cos(beta) * sin(alpha) + radial_dir.y * leaflet_current_size["leaflet_5"]/4, 
												scale*length/3 * sin(beta) 
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
	
	
	reflex growth when:every(24#h)
	{
		
		energy <- energy + 0.3;
		//base 		<- parent.end;
			
	// Spine growth
		length 		<- length > max_length ? length : level_correction * (max_length * (1 - min([1, exp(-energy / energy_divisor)]))) ;
		width 		<- 1.0;//width  > max_width_stem ? width : length / level_correction / width_divisor ;
			
		end 		<- base + {	scale* length * cos(beta) * cos(alpha), 
								scale* length * cos(beta) * sin(alpha), 
								scale* length * sin(beta)
							  };	
							  
	// Leaflet growth
		float energy_efficiency <- 0.0;
		loop key over: leaflet_current_size.keys {
			energy_efficiency 			<- max(0 , energy-leaflet_energy_delay[key]);
			leaflet_current_size[key] 	<- leaflet_max_size[key] * (1 - exp( -energy_efficiency/leaflet_energy_divisor ) );
		}
		 				  
	}
	
	aspect default
	{
	// Spine
		draw line([base, end], width) color: #green;
		
		pair<float,point> rot_spine <- rotation_composition(alpha::{0,0,1}, beta::{0,1,0});
		pair<float,point> rot_leaflet_1 <- 45::{0,0,1};
		
	// Leaflets 
		pair<float, point> rota <- rotation_composition(rot_leaflet_1, rot_spine, 90::{0,0,1});//, 15::{0,1,0});
		
		draw f_leaf size: leaflet_current_size["leaflet_1"] rotate:rota  at: leaflet_1;
		
		rota <- rotation_composition(rot_spine,  90::{0,0,1}, beta::{0,1,0}); 
		draw f_leaf size: leaflet_current_size["leaflet_2"] rotate: rota at: leaflet_2;
		
		rota <- rotation_composition(rot_spine, 180::{0,0,1}, beta::{0,1,0});
		draw f_leaf size: leaflet_current_size["leaflet_3"] rotate: rota at: leaflet_3;
		
		rota <- rotation_composition(rot_spine,  90::{0,0,1}, beta::{0,1,0});  
		draw f_leaf size: leaflet_current_size["leaflet_4"] rotate: rota at: leaflet_4;
		
		rota <- rotation_composition(rot_spine, 180::{0,0,1}, beta::{0,1,0});
		draw f_leaf size: leaflet_current_size["leaflet_5"] rotate: rota at: leaflet_5;
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
