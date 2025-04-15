/**
* Name: tomgrointegration
* Based on the internal empty template. 
* Author: Lili
* Tags: 
*/


model tomgrointegration
import "constants.gaml"


global 
{
	bool button;
	
	
	float 	width 		<- shape.width;
	float 	height 		<- shape.height;
	point 	main_pos 	<- {width / 2, height / 2};
	float 	length_max 	<- 25.0;//100.0;
	float 	width_ini 	<- 0.05; // 1.0
	float 	max_width_stem		<- 0.15;
	float 	max_width_branch	<- 0.1;
	float 	max_branch_length	<- 30.0;
	float 	max_stem_length		<- 25.0;//7.0;
	float 	level_step 	<- 0.7; // 0.8
	float 	env_size 	<- 0.5 * length_max / (1 - level_step);
	
	
	image_file f_leaf <- image_file("../includes/img/leaf.png");
	
	map<string,rgb> color_input <- ["co2":: #turquoise, "ppfd":: #gold, "temp":: #tomato];
	
	map<string,int> stem_type <- ["MAIN"::1,"BURGEON"::2];
	
	
	int 	max_level 	<- 7;//8;
	float 	min_energy 	<- 100.0;//300.0
	float 	main_split_angle_alpha 		<- 30.0;
	float 	secondary_split_angle_alpha <- 90.0;
	float 	main_split_angle_beta 		<- 20.0;
	float 	secondary_split_angle_beta 	<- 90.0;
	
	
	
	
	
	init
	{
		create plant_seed number:1 
		{
			location 		<- main_pos;
			base			<- location;
			width 			<- 30.0 #cm;
		}
		
		ask plant_seed
		{
			do create_main_stem( 	1 
								,	FTRUSN
								, 	LVSNI
								,	WLVSI
								, 	PLSTNI
								, 	WPLI
								,   WPFI
								, 	FRLG
								,	LFARI
			);
		}
	}
		
}

species plant_part
{
	plant_part 	parent		<- nil;
	plant_part	main_parent <- nil;
	point 		base 		<- {0, 0, 0};
	point 		end 		<- {0, 0, 0};
	float 		alpha 		<- 0.0;
	float 		beta 		<- 0.0;
	float 		level 		<- 1.0;
	list 		children	<- nil;
	float 		energy 		<- 0.0;
	
	
	int			truss		<- 0;
	
	// ATRIBUTES for TOMGRO
	float FTRUSN	;			// Node number on the plant that bears the first truss	
	float WPLI		;			// Initial weight per initiated leaf   
	float WPFI		;			// Initial weight per initiated fruit
	float FRLG		;			// Lag period between the time that a no (nodes) truss appears and a fruit appears on plant that truss
	float PLSTNI	;			// Initial plastochron index
	float LVSNI		;			// Initial number of leaves per plant
	float WLVSI		;			// Initial weight of leaves  // For testing purpose the value was 0.005
	float LFARI		;			// Initial leaf area per plant
}


species plant_seed parent: plant_part
{
	bool has_main_stem <- false;
	
	
	// Method to create a tomato seedling and set plant characteristics
	action create_main_stem(int segment, float _FTRUSN, float _LVSNI, float _WLVSI, float _PLSTNI, float _WPLI, float _WPFI, float _FRLG, float _LFARI)  // reflex create_main_stem when: !has_main_stem
	{
		create plant_part  number: 1
		{
			myself.main_parent <- self;
			FTRUSN   <- _FTRUSN;
			WPLI 	<- _WPLI;
			WPFI	<- _WPFI;
			FRLG	<- _FRLG;
			PLSTNI	<- _PLSTNI;
			LVSNI	<- _LVSNI;
			WLVSI	<- _WLVSI;
			LFARI	<- _LFARI;
		}
		
		
		
		create stem {
			parent		<- myself;
			main_parent	<- myself.parent;
			base 		<- myself.location;
			self.end 	<- self.base;
			alpha 		<- rnd(100) * 360 / 100;
			beta 		<- 90.0;
			level 		<- 1.0;
			parent 		<- myself;
			is_main_stem<- true;
			type		<- "MAIN";
			
			do growth_main_segment(4,3.0,20.0,100.0,20.0,0.1);
		}
		
		has_main_stem <- true;
	}
	
	
	aspect default
	{
		draw cone3D(6.0, 6.0) at: location color: #olive;//rgb(110, 170, 124);
	}
}


species burgeon parent: plant_part
{
	
	action growth_stem_leaf
	{
		stem tmp <- nil;
		create stem number: 1 {
			tmp 			<- self;
			self.level 		<- myself.level;
			self.base 		<- myself.base;
			self.end 		<- self.base;
			self.alpha 		<- myself.alpha;
			self.beta 		<- myself.beta;
			self.parent 	<- myself.parent;
			self.can_split 	<- false;
			self.is_branch	<- true;
			
			if myself.parent != nil {
				myself.parent.children <- myself.parent.children + tmp;
			}
		}
		
		
		
		create leaf {
			self.level 	 <- myself.level;
			self.parent  <- tmp;
			self.alpha 	 <- myself.alpha;
			self.beta 	 <- myself.beta;
			self.base 	 <- tmp.end;
			self.end 	 <- self.base + {5 * cos(beta) * cos(alpha), 5 * cos(beta) * sin(alpha), 5 * sin(beta)};
			tmp.children <- tmp.children + self;
			self.creation_cycle <- cycle;
		}
		
 		 
 		 
 		 
		do die;
	}
	
	
	reflex growth {
		energy <- energy + 0.3;
	}


	reflex bloom when: flip(energy / 1) {
		stem tmp <- nil;
		create stem number: 1 {
			tmp 			<- self;
			self.level 		<- myself.level;
			self.base 		<- myself.base;
			self.end 		<- self.base;
			self.alpha 		<- myself.alpha;
			self.beta 		<- myself.beta;
			self.parent 	<- myself.parent;
			self.can_split 	<- false;
			self.is_branch	<- true;
			self.type		<- "BURGEON";
			
			if myself.parent != nil {
				myself.parent.children <- myself.parent.children + tmp;
			}
		}			
		 
		create leaf {
			self.level 	 <- myself.level;
			self.parent  <- tmp;
			self.alpha 	 <- myself.alpha;
			self.beta 	 <- myself.beta;
			self.base 	 <- tmp.end;
			self.end 	 <- self.base + {5 * cos(beta) * cos(alpha), 5 * cos(beta) * sin(alpha), 5 * sin(beta)};
			tmp.children <- tmp.children + self;
			self.creation_cycle <- cycle;
		}
		
 
		do die;
	}
}



species stem parent: plant_part
{
	float 	width;
	float 	length;
	bool 	is_main_stem <- false;
	bool 	can_split	 <- true;
	bool 	is_branch	 <- false;
	
	
	// Atribute to work with TOMGRO
	int 	age_class	<- 0;
	string	type		;
	float	weight		;
	
	init
	{
		truss <- index;
	}

	aspect default
	{
		draw line([base, end], width) color: #green; 
	}
	
	
	action growth_main_segment(int segments, float _correction_factor, float _width_correction, float _energy, float _length, float _width)
	{
		if !is_branch
		{	
			float level_correction <- _correction_factor * 0.3 ^ level;  // 1.8
			length 		<- length > max_stem_length ? length : level_correction * (length_max * (1 - min([1, exp(-_energy)])));
			width 		<- _width > max_width_stem ? _width :length / level_correction / _width_correction;
			end 		<- base + {length * cos(beta) * cos(alpha), length * cos(beta) * sin(alpha), length * sin(beta)};	
			base 		<- end - {length * cos(beta) * cos(alpha), length * cos(beta) * sin(alpha), length * sin(beta)};
			parent.base <- end;
			
			if segments > 1
			{
				loop i from: 0 to: segments-1
				{
					float branch1_alpha	<- rnd(100) / 100 * 360;
					float branch1_beta 	<- 30 + rnd(100) / 100 * 40;
			
					stem tmp <- nil;
					create stem number:1 
					{
						main_parent			<- myself.main_parent;
						tmp 				<- self;
						self.level 			<- myself.level + 2.1;
						point p_location 	<- {myself.end.x, myself.end.y, rnd(myself.base.z, myself.base.z + myself.length)};
						self.base 			<- p_location;
						
						self.alpha 			<- branch1_alpha;
						self.beta 			<- branch1_beta;
						self.parent 		<- myself;
							
						self.length 	<- rnd(10.0,15.0);
						self.width 		<- rnd(0.7,1.2);
						self.base 		<- p_location;
						self.end 		<- self.base + {self.length * cos(self.beta) * cos(self.alpha), self.length * cos(self.beta) * sin(self.alpha), self.length * sin(self.beta)};	
							
							
						self.can_split 	<- false;
						self.is_branch	<- true;
						self.type		<- "BURGEON";
							
						if myself.parent != nil {
								myself.parent.children <- myself.parent.children + tmp;
						}
							
					}
					
					create leaf {
						self.level 	 <- myself.level + 2.1;//myself.level;
						self.parent  <- tmp;
						self.alpha 	 <- branch1_alpha;
						self.beta 	 <- branch1_beta;
						self.base 	 <- tmp.end;
						self.end 	 <- self.base + {10 * cos(self.beta) * cos(self.alpha), 10 * cos(self.beta) * sin(self.alpha), 10 * sin(self.beta)};
						tmp.children <- tmp.children + self;
						self.creation_cycle <- cycle;
						self.size  	<- rnd(10.0,20.0);
					}
				}
				 				
			}	
		}
	}
	
	

	reflex first_bloom when: truss=main_parent.FTRUSN
	{
		float branch1_alpha	<- rnd(100) / 100 * 360;
			float branch1_beta 	<- 30 + rnd(100) / 100 * 40;
		create burgeon number: 1 {
			self.level 	<- myself.level + 2.1;
			point p_location <- {myself.end.x, myself.end.y, rnd(myself.base.z, myself.base.z + myself.length)};
			self.base 	<- p_location;//myself.end;
			self.end	<- p_location;//myself.end;
			self.alpha 	<- branch1_alpha;
			self.beta 	<- branch1_beta;
			self.parent <- myself;
		}
	}

	
	/* 
	reflex growth
	{
		energy 	<- energy + 0.3;
		
		if !is_branch
		{
			end <- parent.base;
			
			float level_correction <- 1.8 * 0.3 ^ level;
			length 		<- length > max_stem_length ? length : level_correction * (length_max * (1 - min([1, exp(-energy / 1000)])));
			width 		<- width > max_width_stem ? width :length / level_correction / 13.0;
			end 		<- base + {length * cos(beta) * cos(alpha), length * cos(beta) * sin(alpha), length * sin(beta)};	
			base 		<- end - {length * cos(beta) * cos(alpha), length * cos(beta) * sin(alpha), length * sin(beta)};
			parent.base <- end;
		}
		else
		{
			base 	<- parent.end;
			length 	<- length > max_branch_length ? length :level_step ^ level * (length_max * (1 - min([1, exp(-energy / 1000)])));
			width 	<- width > max_width_branch ? width :length / 10 * (4 + max_level - level) / (4 + max_level);
			end 	<- base + {length * cos(beta) * cos(alpha), length * cos(beta) * sin(alpha), length * sin(beta)};
			
		}
		if type="MAIN"
		{
			save data:[ cycle
					,	type
					,	name
					,	level
					,	length
					, 	width
				] to:"/output/integration/stem_properties.csv" format:"csv" rewrite:false;
		}
			
	}
	*/
	
	
	// Only elements in the main stem can split
	reflex split when: can_split and (level < max_level) and (min_energy < energy) {
		can_split <- false; // Once stem has split there is no more split
		
		
		
		int possible_burgeon <- rnd(8);
		
		loop i from: 0 to: possible_burgeon
		{
			float branch1_alpha	<- rnd(100) / 100 * 360;
			float branch1_beta 	<- 30 + rnd(100) / 100 * 40;
			if flip(0.7) 
			{
				create burgeon number: 1 {
					self.level 	<- myself.level + 2.1;
					point p_location <- {myself.end.x, myself.end.y, rnd(myself.base.z, myself.base.z + myself.length)};
					self.base 	<- p_location;//myself.end;
					self.end	<- p_location;//myself.end;
					self.alpha 	<- branch1_alpha;
					self.beta 	<- branch1_beta;
					self.parent <- myself;
				}
			}	
				
		} 
		
		 

		create stem number: 1 {
			self.level 			<- myself.level + 0.3;
			self.base			<- myself.base;
			self.end			<- myself.base;
			self.alpha 			<- myself.alpha - 10 + rnd(200) / 10;
			self.beta 			<- myself.beta - 10 + rnd(200) / 10;
			self.parent 		<- myself;
			self.is_main_stem 	<- false;
			self.type			<- "MAIN";
			
			
			//save data:[ cycle
			//		,	"STEM"
			//		,	name
			//		,	level
			//		,	parent
			//		,	is_main_stem
			//		, 	can_split
			//		,	is_branch
			//		,	base
			//		,  	end
			//	] to:"/output/integration/stem_properties.csv" format:"csv" rewrite:false;
		}

	}
	
}




species leaf
{
	// Visual variables
	int   creation_cycle<- -1;
	float level 		<- 1.0;
	float alpha 		<- 0.0;
	float beta 			<- 0.0;
	
	stem 		parent;
	point 		base;
	point 		end;
	
	float size 		<- 3.0;//0.5;
	float max_size 	<- 3.0;
	
	
	pair<float, point> rota <- rotation_composition(float(rnd(180))::{1, 0, 0}, float(rnd(180))::{0, 1, 0}, float(rnd(180))::{0, 0, 1});
	
	
	aspect default {
		draw line([base, end], min([parent.width, 1])) color: #green;
		//draw triangle(size) rotate: rota at: end color: #lime;
		draw f_leaf size: size rotate: rota at: end ;
	}
	
	
	reflex update {
		base 	<- parent.end;
		end 	<- base + {5 * cos(beta) * cos(alpha), 5 * cos(beta) * sin(alpha), 5 * sin(beta)};
		//size	<- size < max_size ? size : size+0.3 ;
		// TODO: Change variable size for growing leaves
	}
	
	
	reflex split when: (level < max_level) and flip(1 - exp(level * (min_energy - parent.energy) / 50)) {
		
		if level < max_level
		{
			
			int side1 <- -1 + 2 * rnd(1);
			int side3 <- -1 + 2 * rnd(1);
			
			float factor <- secondary_split_angle_alpha / 100;
			float branch1_alpha <- parent.alpha + side1 * rnd(100) / 100 * main_split_angle_alpha;
			float branch2_alpha <- parent.alpha - side1 * rnd(100) * factor;
			float branch3_alpha <- parent.alpha + side3 * rnd(100) * factor;
			float branch4_alpha <- parent.alpha - side3 * rnd(100) * factor;
			int sideb <- -1 + 2 * rnd(1);
			 factor <- secondary_split_angle_beta / 100;
			float branch1_beta <- parent.beta + sideb * rnd(100) / 100 * main_split_angle_beta;
			float branch2_beta <- -20 + rnd(100) * factor;
			float branch3_beta <- -20 + rnd(100) * factor;
			float branch4_beta <- -20 + rnd(100) * factor;
			
			create burgeon number: 1 {
				self.level 	<- myself.parent.level + 1;
				point ini_location <- {myself.base.x, myself.base.y, rnd(myself.base.z, myself.parent.length)};
				
				self.base 	<- ini_location;//myself.base;
				self.end 	<- ini_location;//self.base;
				self.alpha 	<- branch1_alpha;
				self.beta 	<- branch1_beta;
				self.parent <- myself.parent;
			}
	
			create burgeon number: 1 {
				self.level 	<- myself.parent.level + 1.2;
				
				point ini_location <- {myself.base.x, myself.base.y, rnd(myself.base.z, myself.parent.length)};
				
				self.base 	<- ini_location;//myself.base; 
				self.end 	<- ini_location;//self.base;   
				self.alpha 	<- branch2_alpha;
				self.beta 	<- branch2_beta;
				self.parent <- myself.parent;
			}
			
			if flip(0.6) {
				create burgeon number: 1 {
					self.level 	<- myself.parent.level + 1.7;
					
					point ini_location <- {myself.base.x, myself.base.y, rnd(myself.base.z, myself.parent.length)};
					
					self.base 	<- ini_location;//myself.base; 
					self.end 	<- ini_location;//self.base;   
					self.alpha 	<- branch3_alpha;
					self.beta 	<- branch3_beta;
					self.parent <- myself.parent;
				}
	
			}
			
			
			if flip(0.3) {
				create burgeon number: 1 {
					self.level 	<- myself.parent.level + 2;
					point ini_location <- {myself.base.x, myself.base.y, rnd(myself.base.z, myself.parent.length)};
					
					self.base 	<- ini_location;//myself.base; 
					self.end 	<- ini_location;//self.base;  
					self.alpha 	<- branch4_alpha;
					self.beta 	<- branch4_beta;
					self.parent <- myself.parent;
				}
	
			}
			
			/* 
			if flip(0.8) {
				create burgeon number: 1 {
					self.level 	<- myself.parent.level + 3.5;
					self.base 	<- myself.base;
					self.end 	<- self.base;
					self.alpha 	<- branch4_alpha;
					self.beta 	<- branch4_beta;
					self.parent <- myself.parent;
				}
	
			}
			*/
			
			
			if flip(0.3) {
				create fruit number: (1 + rnd(2)) {
					self.base 	<- myself.base;
					self.end 	<- myself.base + {3 * cos(beta) * cos(alpha), 3 * cos(beta) * sin(alpha), 3 * sin(beta)};
					self.parent <- myself.parent;
					self.alpha 	<- myself.alpha + (-1 + 2 * rnd(1)) * 30;
					self.beta 	<- -40.0 + rnd(80);
				}
				
				//write "fruit created";
			 
			}
			
			
			self.parent.children <- self.parent.children - self;		
		}

		
		do die;
	}
	
}




species fruit
{
	stem	parent;
	point 	base;
	point 	end;
	float 	alpha;
	float 	beta;
	float 	size;
	int		maturation_time <- 42;
	int		age 			<- 0;
	float 	age_ratio		<- 0.0;
	int 	age_class		<- 0;
	
	
	aspect default {
		draw line([base, end], 0.1) color: #khaki;
		draw sphere(size) at:end color:rgb(age_ratio*255, (1-age_ratio)*255, 0);//color: #pink;
	}	
	
	reflex update {
		base		<- parent.end;
		end 		<- base + {3 * cos(beta) * cos(alpha), 3 * cos(beta) * sin(alpha), 3 * sin(beta)};
		age_ratio	<- age/maturation_time;
		
		size 	<- sin(90 * age_ratio);
		
		  
		if size < 0 
		{
			do die;
		}
		
		age <- age + 1;
		
		age_class <- age_class + parent.level as int;
		
		save data:[ 	cycle
					,	name
					,	size
					, 	age_class
					,	parent.name
					,	parent.is_main_stem
					, 	parent.level
			] to:"output/integration/fruit.csv" format:"csv" rewrite:false;
	}
		
}




species vision_module
{
	
	aspect obj
	{
		pair<float,point> r0 	<-  -90::{1,1,1};	
		pair<float,point> pitch <-  5 * cos(10) ::{1,0,0};//5 * cos(10) ::{1,0,0};		// axis Y		
		pair<float,point> roll 	<-  20*sin(3)::{0,1,0};  		// axis X
		pair<float,point> yaw 	<- 	1*sin(7)::{0,0,1};			// axis Z
		
		draw obj_file("../includes/3d_obj/camera.obj", rotation_composition(r0,pitch,roll,yaw)) at: location + {-80,0,10} size: 7 ;
	}
}






species illumination_module
{
	aspect obj
	{
		pair<float,point> r0 	<-  -90::{1,1,1};	
		pair<float,point> pitch <-   5 * cos(10)::{1,0,0};		// axis Y		
		pair<float,point> roll 	<-  20 * sin(3)	::{0,1,0};  	// axis X
		pair<float,point> yaw 	<- 	 1 * sin(7)	::{0,0,1};		// axis Z
		
		
		// rotation_composition(r0,pitch,roll,yaw)
		
		draw obj_file("../includes/3d_obj/lamp.obj","../includes/3d_obj/lamp.mlt", 90.0::{1,0,0}) at: {main_pos.y,main_pos.x,50} size:5 ;
	}
}



species fan_module
{
	aspect obj
	{
		pair<float,point> r0 	<-  -90::{1,1,1};	
		pair<float,point> pitch <-   5 * cos(10) ::{1,0,0};		// axis Y		
		pair<float,point> roll 	<-  20 * sin(3)::{0,1,0};  		// axis X
		pair<float,point> yaw 	<- 	 1 * sin(7)::{0,0,1};			// axis Z
		
		draw obj_file("../includes/3d_obj/cooling_fan.obj","../includes/3d_obj/cooling_fan.mlt", 90.0::{-1,0,0}) at: location + {100,-60,5} size: 10 ;			
	}

}


experiment tomato_growth type: gui autorun: false {
	
	// Variables used to position camera
	float w -> simulation.shape.width ; 
	float h -> simulation.shape.height ;
	point p -> first(plant_seed).location ;
	float factor <- 1.0;
	
	// Simulation variables
	float minimum_cycle_duration <- 0.0005;
	float seed <- 0.05387546426306633;
	
	
	parameter "turn on/off the ligth" var:button init:true;
	
	
	// Screen
	output {
		display 'Tomato' type: opengl background: #black{//background: #lightskyblue axes: true toolbar: true {
			
			// Setting camera
			//light #ambient 	 intensity: 100;
			camera #default  location: {w / 2, h * 2, w / factor} target: {w / 2, h / 2, 0} ;
			
			light #ambient intensity: button?150:50;
			
			
			// Creating chart with inputs
			overlay position: { 5, 5 } size: { 180 #px, 100 #px } background: # white transparency: 0.5 border: #black rounded: true
            {
            	//for each possible type, we draw a square with the corresponding color and we write the values
                float y <- 30#px;
	            loop type over: color_input.keys
	            {
	            	draw square(10#px) at: { 20#px, y } color: color_input[type] border: #white;
	            	draw type at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 18, #bold);
	                y <- y + 25#px;
	            }
            }
			
			
			
			// Scenario
			species plant_seed 			aspect: default;
			species stem 				aspect: default;
			species leaf 				aspect: default;
			species fruit 				aspect: default;
			species vision_module		aspect: obj;
			species illumination_module aspect: obj;
			species fan_module			aspect: obj;
		}
		
	}

}



