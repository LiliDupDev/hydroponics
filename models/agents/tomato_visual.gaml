/**
* Name: tomatovisual
* Based on the internal empty template. 
* Author: Liliana Duran Polanco
* Tags: 
*/


model tomatovisual

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
	float 	level_step 			<- 0.7; // 0.8
	float 	env_size 			<- 0.5 * length_max / (1 - level_step);
	
	int 	max_level 					<- 7;//8;
	float 	min_energy					<- 100.0;//300.0
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



species plant_part {
	plant_part 	parent 		<- nil;
	point 		vector 		<- {0, 0, 0};
	point 		base 		<- {0, 0, 0};
	point 		end 		<- {0, 0, 0};
	float 		alpha 		<- 0.0;
	float 		beta 		<- 0.0;
	float 		level 		<- 1.0;
	list 		children 	<- nil;
	float 		energy 		<- 0.0;
}


species plant_seed parent: plant_part {
	bool has_tree <- false;
	point end -> self.location;
	point vector <- {0, 0, 1};

	reflex create_tree  {
		create stem {
			base 		<- myself.location;
			self.end 	<- self.base;
			alpha 		<- rnd(100) * 360 / 100;
			beta 		<- 90.0;
			level 		<- 1.0;
			parent 		<- myself;
		}

		has_tree <- true;
	}

	aspect default 
	{
		draw cone3D(6.0, 6.0) at: location color: #olive;
	}
}



species stem parent: plant_part
{
	float 	length 		<- 0.0;
	float 	width 		<- 0.0; 
	bool 	can_split 	<- true;
	
	
	aspect default {
		draw line([base, end], width) color: #green;
	}
	
	reflex growth
	{
		energy 	<- energy + 0.3;
		
		base 	<- parent.end;
		length 	<- length > max_branch_length ? length :level_step ^ level * (length_max * (1 - min([1, exp(-energy / 1000)])));
		width 	<- width > max_width_branch ? width :length / 10 * (4 + max_level - level) / (4 + max_level);
		end 	<- base + {length * cos(beta) * cos(alpha), length * cos(beta) * sin(alpha), length * sin(beta)};
		
		
	}
	
}



experiment tomato_growth type: gui autorun: false 
{
	// Variables used to position camera
	float w -> simulation.shape.width; 
	float h -> simulation.shape.height;
	point p -> first(plant_seed).location;
	float factor <- 1.0;
	
	// Simulation variables
	float minimum_cycle_duration <- 0.0005;
	float seed <- 0.05387546426306633;
	
	
	
	// Screen
	output {
		display 'Tomato' type: opengl background: #black{//background: #lightskyblue axes: true toolbar: true {
			
			// Setting camera
			//light #ambient 	 intensity: 100;
			camera #default  location: {w / 2, h * 2, w / factor} target: {w / 2, h / 2, 0} ;
			
			light #ambient intensity: 150;
			
		
			
			// Scenario
			species plant_seed 			aspect: default;
			species stem 				aspect: default;
		}
		
	}

}