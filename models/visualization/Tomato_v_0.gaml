/**
* Name: Tomatov0
* First iteration of new structure of tomato 
* Author: Liliana Durán-Polanco
* Tags: 
*/


model Tomatov0

global
{
	geometry shape <- rectangle(50,50);
	
	float	length_max 			<- 2000.0;		// Altura total de planta
	
	int 	max_level 			<- 7;
	float 	level_step 			<- 0.7;
	
	float 	max_stem_length		<- 70.0 ;
	float 	max_branch_length	<- 250.0;
	
	
	float 	max_width_stem		<- 15.0;
	float 	max_width_branch	<- 13.0;
	
	float 	min_energy 			<-  1.0;
	float	energy_divisor		<- 50.0;
	float   width_divisor		<- 10.0;
	
	float 	width 		<- shape.width;
	float 	height 		<- shape.height;
	point 	main_pos 	<- {width / 2, height / 2};
	
	float 	scale	 	<- 0.1;
	
	init
	{
		step <- 1#h;
		
		create plant_seed number:1 returns:p_seed
		{
			base  	<- {main_pos.x,main_pos.y,0};
			end  	<- {main_pos.x,main_pos.y,0};
			level	<- 0.0;
		}
		
		create stem number:1 returns:stm
		{
			parent 		<- first(p_seed);
			base  		<- {main_pos.x,main_pos.y,0};
			end	  		<- base;
			level 		<- 1.0;
			can_split	<- true;
			main_stem	<- true;
			is_branch	<- false;
			beta 		<- 90.0;
			length		<- 0.0;
			width		<- 1.0;
		}
		
		
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
	float		length		<- 0.0;
	float 		width		<- 0.0;
	
	// animation attributes
	float 		energy  <- 0.0;
	float 		level 	<- 1.0;
	
	
	
}

species plant_seed parent:plant_part
{
	
}


species stem parent: plant_part
{
	bool main_stem;
	bool can_split;
	bool is_branch;
	
	aspect default
	{
		draw line([base, end], scale*width) color: #green; 
	}

	reflex growth when:every(24#h)
	{
		energy 	<- energy + 0.3;
		
		if !is_branch
		{
			float level_correction <- 1.8 * 0.3 ^ level;
			base 		<- parent.end;
			
			length 		<- length > max_stem_length ? length : level_correction * (length_max * (1 - min([1, exp(-energy / energy_divisor)]))) ;
			width 		<- width > max_width_stem ? width : length / level_correction / width_divisor ;
			
			end 		<- base + {	scale*length * cos(beta) * cos(alpha), 
									scale*length * cos(beta) * sin(alpha), 
									scale*length * sin(beta)
								  };	
			
			write "Day: "+int(cycle/24)+"   - Length: "+length + "    - Width: "+width;
		}
		else
		{
			base 	<- parent.end;
			length 	<- length > max_branch_length ? length :level_step ^ level * (length_max * (1 - min([1, exp(-energy / energy_divisor)])));
			width 	<- width > max_width_branch ? width :length / 10 * (4 + max_level - level) / (4 + max_level);
			end 	<- base + {	length * cos(beta) * cos(alpha), 
								length * cos(beta) * sin(alpha), 
								length * sin(beta)
							  };	
		}
	}
	
	
	reflex split when: can_split and (min_energy < energy) // and (level < max_level) 
	{
		can_split <- false;
		
		create stem number: 1 
		{
				self.level 					<- myself.level + 0.3;
				self.base					<- myself.base;
				self.end					<- myself.base;
				self.alpha 					<- 0.0; //myself.alpha - 10 + rnd(200) / 10;
				self.beta 					<- 90.0;//myself.beta  - 10 + rnd(200) / 10;
				self.parent 				<- myself;
				self.main_stem 				<- false;
				can_split					<- true;
				is_branch					<- false;
		}
				
	}
	
}


experiment drawing type: gui autorun: false 
{	
	
	/* 
	//float minimum_cycle_duration <- 0.05;
	
	float seed <- 0.05387546426306633;
	*/
	
	// Screen
	output {
		display 'Turtle' type: opengl {
			
			species stem 				aspect: default;
			
		}
			
			
	}
	
		
}

