/**
* Name: Tomatov0
* First iteration of new structure of tomato 
* Author: Liliana Durán-Polanco
* Tags: 
*/


model Tomatov0

global
{
	float	length_max 			<- 1000.0#mm;		// Altura total de planta
	
	int 	max_level 			<- 7;
	float 	level_step 			<- 0.7;
	
	float 	max_stem_length		<- 70#mm ;
	float 	max_branch_length	<- 150#mm;
	
	
	float 	max_width_stem		<- 15#mm;
	float 	max_width_branch	<- 13#mm;
	
	float 	min_energy 			<- 100.0;
	
	init
	{
		step <- 1#h;
		
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


species stem parent: plant_part
{
	bool main_stem;
	bool can_split;
	bool is_branch;

	reflex growth when:every(24#h)
	{
		energy 	<- energy + 0.3;
		
		if !is_branch
		{
			//base 	<- parent.end;
			end <- parent.base;
			
			
			float level_correction <- 1.8 * 0.3 ^ level;
			
			length 		<- length > max_stem_length ? length : level_correction * (length_max * (1 - min([1, exp(-energy / 1000)])));
			width 		<- width > max_width_stem ? width :length / level_correction / 13.0;
			
			end 		<- base + {	length * cos(beta) * cos(alpha), 
									length * cos(beta) * sin(alpha), 
									length * sin(beta)
								  };	
			base 		<- end - {	length * cos(beta) * cos(alpha), 
									length * cos(beta) * sin(alpha), 
									length * sin(beta)
								 };
			parent.base <- end;
		}
		else
		{
			base 	<- parent.end;
			length 	<- length > max_branch_length ? length :level_step ^ level * (length_max * (1 - min([1, exp(-energy / 1000)])));
			width 	<- width > max_width_branch ? width :length / 10 * (4 + max_level - level) / (4 + max_level);
			end 	<- base + {	length * cos(beta) * cos(alpha), 
								length * cos(beta) * sin(alpha), 
								length * sin(beta)
							  };	
		}
	}
	
	
	reflex split when: can_split and (level < max_level) and (min_energy < energy) {
		can_split <- false;
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
			
		}
			
			
	}
	
		
}

