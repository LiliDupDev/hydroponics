/**
* Name: TurtleMethod
* Model to create a graphics from an L-system string
 
* Author: Liliana Durán Polanco
* Tags: 
*/


model TurtleMethod


global
{
	file csv_strings <- csv_file("tomato_system_L.csv",",");
	
	list<string> alphabet_prod 		<- ["F","E","X"];
	list<string> alphabet_control 	<- ["+","-","[","]","f","x","e"];
	
	map<int,string> structure_by_stage;
	
	list<plant_part> stack;
	int stack_pointer <- 0;
	
	init
	{
		//convert the file into a matrix
		matrix tomato_structure_by_stage <- matrix(csv_strings);
		//loop on the matrix rows (skip the first header line)
		loop i from: 1 to: tomato_structure_by_stage.rows -1{
			add tomato_structure_by_stage[0,i]::tomato_structure_by_stage[1,i] to:structure_by_stage;
		}		
		
		do draw_plant(1);
		//write structure_by_stage;
		
		
	}
	
	action draw_plant(int stage)
	{
		string structure <- structure_by_stage[stage];
		
		float alpha			<- rnd(100) / 100 * 360;
		float beta 			<- 30 + rnd(100) / 100 * 40;
		point last_position <- {0,0,0};
		
		bool activate_push 	<- false;
		
		loop i from: 0 to: length(structure) - 1 
		{
			string token <- structure at i;
			
			switch token {
				match "F" 										//	Create main stem
				{	 						
					write "STEM";
				}
				match "E" 										//	Final branch
				{
					
				}
				match "X" 										// Branch and leaves to expand
				{
					write "FINAL BRANCH";	
				}
				match "[" 										// Push in stack
				{
					write "ACTIVATE PUSH";
					activate_push <- true;
				}
				match "]" 										// Pop in stack
				{
					write "DE-ACTIVATE PUSH";
					activate_push <- false;
				}
				match "+" 										// Positive angle
				{
					write "POSITIVE ANGLE";
				}	
				match "-" 										// Negative angle
				{
					write "NEGATIVE ANGLE";
				}
				match "f" 										// Flower
				{
					write "FLOWER";
				}
				match "x"										// branch 
				{
					write "BRANCH";
				}
				match "e" 										// branch to expand
				{
					write "EXPAND";
				}
				match "G"										// Fruit 	
				{
					write "FRUIT";
				}
			}
			
			write token;
		}
		
	}
	
}


species turtle
{
	

	

}

species plant_part
{
	plant_part 	parent		<- nil;
	float 		level 		<- 1.0;
	list 		children	<- nil;

	// position
	point 		base 		<- {0, 0, 0};
	point 		end 		<- {0, 0, 0};
	float 		alpha 		<- 0.0;
	float 		beta 		<- 0.0;
	
	// visualization attributes
	float		length		<- 5.0;
	float 		width		<- 2.0;
	
	// animation attirbutes
	float 		energy <- 0.0;
	
}

species stem parent:plant_part
{ 
	bool main_stem;
	
	aspect default
	{
		draw line([base, end], width) color: #green; 
	}
}



species flower parent:plant_part
{
	aspect default
	{
		draw triangle(5) color: #yellow at:base;//line([base, end], width) color: #green; 
	}
}


species leaf parent:plant_part
{
	aspect default
	{
		draw circle(3) color: #green at:base;//line([base, end], width) color: #green; 
	}
}

species fruit parent:plant_part
{
	aspect default
	{
		draw circle(5) color: #red at:base;//line([base, end], width) color: #green; 
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
			species stem;
			species flower;
			species leaf;
			species fruit;
		}
			
			
	}
	
		
}



