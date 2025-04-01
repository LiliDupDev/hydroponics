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
		
		create tomato_truss number:1
		{
			base 	<- {0,0,0};
			length 	<- 10.0;
			alpha	<- 137.5 + gauss(0,10);
			beta 	<- 35.0 + gauss(0,5); 		// TODO: change beta to simulate weight inclination
												// Hanging trusses require beta 60 to 90°
												// Upright trusses require an angle of 10 to 20°
			width	<- 1.0;
			level	<- 1.3;
			
			end 	<- base + {	length * cos(beta) * cos(alpha), 
								length * cos(beta) * sin(alpha), 
								length * sin(beta) 
							};
			
			do draw_pedicel;
		}
		//create tomato_leaf number:1
		//{
		//	alpha 	<- -70 + gauss(0, 45);  
		//	beta 	<-  15 + gauss(0, 5);   
		//	length	<- 0.0;
		//	width	<- 1.0;
		//	level	<- 1.3;
		//	
		//	base 	<- main_pos;
		//	end 	<- base + {	scale * length * cos(beta) * cos(alpha), 
		//						scale * length * cos(beta) * sin(alpha), 
		//						scale * length * sin(beta) 
		//					};
		//}
	}
	
}


species tomato_truss parent:plant_part
{
	float 	radius 				<- 0.5;
	int 	fruit_number 		<- rnd(5,8);
	float	phyllotaxy_angle	<- 137.5;
	float	inclination_angle	<- 25.0; //20-40
	float 	pedicel_length		<- 3.0;
	
	map<string,point> pedicel_base	<-[];
	map<string,point> pedicel_end	<-[];
	map<string,float> pedicel_alpha	<-[];
	map<string,float> pedicel_beta	<-[];
	
	action draw_pedicel
	{
		string 	nm 				<- "";
		float	beta_pedicel	<- 0.0;
		float	alpha_pedicel	<- 0.0;
		float	z_pedicel		<- 0.0;
		
		point 	pedicel_local;
		point 	pedicel_global;
		point 	pedicel_global_end;
		point	direction;
		
		
		loop id from: 0 to: fruit_number - 1
		{
			nm 			<- "pedicel_"+id;
			z_pedicel	<- (id/fruit_number) * length; // position on peduncle
			alpha_pedicel  	<- id *  phyllotaxy_angle;
			beta_pedicel	<- inclination_angle;
			
			// Local radial position, no peduncle rotation
			//pedicel_local <- {
			//					radius * cos(alpha_pedicel) * sin(beta_pedicel),
			//					radius * sin(alpha_pedicel) * sin(beta_pedicel),
			//					z_pedicel + radius * cos(beta_pedicel)
			//					};
						
			// Appliying peduncle rotation
			//pedicel_global <- {
			//					pedicel_local.x * cos(alpha) - pedicel_local.y * sin(alpha),
			//					pedicel_local.x * sin(alpha) + pedicel_local.y * cos(alpha),
			//					pedicel_local.z
			//					};
			//					
			//pedicel_global_end <-{
			//						pedicel_global.x + pedicel_length * cos(alpha) * sin(beta),
			//						pedicel_global.x + pedicel_length * sin(alpha) * sin(beta),
			//						pedicel_global.z + pedicel_length * cos(beta)
			//					};
			//
			//add nm::pedicel_global+base to: pedicel_base	;
			//add nm::pedicel_global_end 	to: pedicel_end	    ;
			//add nm::alpha_pedicel 		to: pedicel_alpha	;
			//add nm::beta_pedicel 		to: pedicel_beta	;
			
				
			pedicel_local <- { 
								base.x,
								base.y,
								base.z + z_pedicel
							};
			
			direction	<- apply_rotation({1,0,0}  , {0,0,1}, alpha_pedicel);
			direction	<- apply_rotation(direction, {0,1,0}, beta_pedicel);
			
			pedicel_global_end <- {
									pedicel_local.x * direction.x * 3,
									pedicel_local.y * direction.y * 3,
									pedicel_local.z * direction.z * 3
									};
									
			add nm::pedicel_local 		to: pedicel_base;
			add nm::pedicel_global_end 	to: pedicel_end	;
			
		} 
	}
	
	
	// Rodrigus Rotation
	point apply_rotation(point vector, point axis, float theta)
	{
		point k <- vector_normalize(axis);	
		
		point term_1 <- {
						 vector.x * cos(theta) ,
						 vector.y * cos(theta) ,
						 vector.z * cos(theta)		
						};
						
		point cross <- cross_product(k,vector);
		
		point term_2 <- {
						 cross.x * sin(theta) , 
						 cross.y * sin(theta) , 
						 cross.z * sin(theta) 
						};
		float scalar <- dot_product(k,vector) * (1-cos(theta));
		
		point term_3 <- {
						 k.x * scalar,
						 k.y * scalar,
						 k.z * scalar
						};
		
		return {
				term_1.x + term_2.x + term_3.x , 
				term_1.y + term_2.y + term_3.y ,
				term_1.z + term_2.z + term_3.z 
				};			
	}
	
	
	point cross_product(point k, point v)
	{
		return {
				 k.y * v.z - k.z * v.y ,
				 k.z * v.x - k.z * v.z ,
				 k.x * v.y - k.y * v.x
				};
	}
	
	
	float dot_product(point k, point v)
	{
		return k.x * v.x + k.y * v.y + k.z * v.z;
	}
	
	
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
		draw line([base, end], width) color: #green;
		pair<float,point> rot_peduncle <- rotation_composition(alpha::{0,0,1}, beta::{0,1,0});
		pair<float,point> rot_pedicel;// <- rotation_composition(alpha::{0,0,1}, beta::{0,1,0});
		
		loop key over: pedicel_base.keys
		{
			//rot_pedicel <- rotation_composition(rot_peduncle, pedicel_alpha[key]::{0,0,1}, pedicel_beta::{1,0,0});
			draw line([pedicel_base[key], pedicel_end[key]], radius) color: #green; 
		} 
		
		
		//draw line([{0,0,0}, {1.2,0,0}], 0.1) color: #green;                                                       
		//draw sphere(0.2) at:{ 1.2 ,  0.0 , 0.0 } color:#yellow ;
		//draw sphere(0.2) at:{-0.6 ,  1.04, 0.4 } color:#yellow ;
		//draw sphere(0.2) at:{-1.1 , -0.3 , 0.8 } color:#yellow ;
		//draw sphere(0.2) at:{ 0.3 , -1.15, 1.2 } color:#yellow ;
		//draw sphere(0.2) at:{ 1.15,  0.5 , 1.6 } color:#yellow ;
		//draw sphere(0.2) at:{-0.45,  1.1 , 2.0 } color:#yellow ;
	}                 
}



species tomato_leaf parent:plant_part
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
	
	
	point 	radial_dir<-  base update: vector_normalize({ -sin(alpha), cos(alpha), 0});
	
	
	point	leaflet_1 <- base update: base + {	scale*length * cos(beta) * cos(alpha) + cos(alpha) + radial_dir.x * leaflet_current_size["leaflet_1"]/10 + (alpha < 0 ? -width : width),
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
		display 'Truss' type: opengl {
			//species tomato_leaf;
			species tomato_truss;
		}
			
			
	}
	
		
}
