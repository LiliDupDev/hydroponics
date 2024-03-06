/**
* Name: VisualTomato
* Based on the internal Tree and Seasons tutorial, a visual representation of tomato growing 
* Author: Liliana
* Tags: 
*/


model VisualTomato

global 
{
	float 	width 		<- shape.width;
	float 	height 		<- shape.height;
	point 	main_pos 	<- {width / 2, height / 2};
	float 	length_max 	<- 75.0;//100.0;
	float 	width_ini 	<- 0.25; // 1.0
	float 	max_width_stem		<- 1.5;
	float 	max_width_branch	<- 1.5;
	float 	max_branch_length	<- 3.0;
	float 	max_stem_length		<- 7.0;
	float 	level_step 	<- 0.7; // 0.8
	float 	env_size 	<- 0.5 * length_max / (1 - level_step);
	
	image_file f_leaf <- image_file("../includes/img/leaf.png");
	
	
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
			width 			<- 30.0;
		}
	}
		
}

species plant_part
{
	plant_part 	parent		<- nil;
	point 		base 		<- {0, 0, 0};
	point 		end 		<- {0, 0, 0};
	float 		alpha 		<- 0.0;
	float 		beta 		<- 0.0;
	float 		level 		<- 1.0;
	list 		children	<- nil;

	
	float 		energy <- 0.0;
}

species plant_seed parent: plant_part
{
	bool has_main_stem <- false;
	
	reflex create_main_stem when: !has_main_stem
	{
		create stem {
			base 		<- myself.location;
			self.end 	<- self.base;
			alpha 		<- rnd(100) * 360 / 100;
			beta 		<- 90.0;
			level 		<- 1.0;
			parent 		<- myself;
			is_main_stem<- true;
			
			/*
			save data:[ cycle
					,	self.parent.name
					,	self.name
					,  	self.alpha
					,	self.beta
					, 	self.level
					,	self.base
					,	self.end
				] to:"stem_properties.csv" type:csv rewrite:false;
				* 
				*/
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
	

	aspect default
	{
		draw line([base, end], width) color: #green; 
		//draw "STEM= "+name at: end + {-3,1.5} color: #black font: font('Default', 12, #bold) ; 
	}
	
	reflex growth
	{
		energy 	<- energy + 0.3;
		
		if !is_branch
		{
			//base 	<- parent.end;
			end <- parent.base;
			
			// Este código es crecimiento 
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
		
		/* 
		save data:[   	cycle
					,	name
					, 	parent.name
					,	is_main_stem
					,	can_split
					,	is_branch
					,  	energy
					,	level
					,	length
					,	width
					,	base.x
					,	base.y
					,	base.z
					,	end.x
					,	end.y
					,	end.z
			] to:"stem_growth.csv" type:csv rewrite:false;	
		 */
			
	}
	
	
	// Only elements in the main stem can split
	reflex split when: can_split and (level < max_level) and (min_energy < energy) {
		can_split <- false;
		
		
		
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
					
					/* 
					save data:[   	cycle
								,	name
								, 	parent.name
								,	base.x
								,	base.y
								,	base.z
								,	end.x
								,	end.y
								,	end.z
					] to:"stem_growth.csv" type:csv rewrite:false;
					*/
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
		}

	}
	
}


species leaf
{
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
	
	
	aspect default {
		draw line([base, end], 0.1) color: #khaki;
		draw sphere(size) at:end color:rgb(age_ratio*255, (1-age_ratio)*255, 0);//color: #pink;
	}	
	
	reflex update {
		base		<- parent.end;
		end 		<- base + {3 * cos(beta) * cos(alpha), 3 * cos(beta) * sin(alpha), 3 * sin(beta)};
		age_ratio	<- age/maturation_time;
		
		size 	<- sin(90 * age_ratio);
		
		age <- age + 1;
	}
		
}


experiment tomato_growth type: gui autorun: false {
	float minimum_cycle_duration <- 0.0005;
	float seed <- 0.05387546426306633;
	output {
		display 'Tomato' type: opengl {//background: #lightskyblue axes: true toolbar: true {
			light #ambient intensity: 150;
			//rotation angle: cycle/1000000 dynamic: true;
			//camera #default location: {50.0,450,250} target: {50.0,50.0,40+80*(1-exp(-cycle/50000))} dynamic: true;
			species plant_seed 	aspect: default;
			species stem 		aspect: default;
			//species stem_branch aspect: default;
			species leaf 		aspect: default;
			species fruit 		aspect: default;
		}

	}

}