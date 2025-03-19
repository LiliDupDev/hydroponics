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
	
	
	float 	width 		<- shape.width;
	float 	height 		<- shape.height;
	point 	main_pos 	<- {width / 2, height / 2};
	
	image_file f_leaf <- image_file("../../includes/img/leaf.png");
	
	init
	{
		//convert the file into a matrix
		matrix tomato_structure_by_stage <- matrix(csv_strings);
		
		//loop on the matrix rows (skip the first header line)
		loop i from: 1 to: tomato_structure_by_stage.rows -1{
			add tomato_structure_by_stage[0,i]::tomato_structure_by_stage[1,i] to:structure_by_stage;
		}		
		
		create stem number:1 returns:stm
		{
			base  <- {main_pos.x,main_pos.y,0};
			end	  <- base;
			level <- 1.0;
		}
		
		do push(first(stm));
		
		do draw_plant(7);
		//write structure_by_stage;
		
		
	}
	
	action push(plant_part p)
	{
		add p to:stack;
	}
	
	plant_part pop
	{
		plant_part p <- last(stack);
		remove last(stack) from: stack;
		return p;
	}
	
	plant_part view
	{
		return last(stack);
	}
	
	action draw_plant(int stage)
	{
		string structure <- structure_by_stage[stage];
		
		list<string> stack_par <- [];
		
		float alpha_o			<- 0.0; //rnd(100) / 100 * 360;
		float beta_o 			<- 0.0; //30 + rnd(100) / 100 * 40;
		float gamma_o			<- 0.0; //rnd(1.0)*30;
		
		bool activate_push 	<- false;
		
		
		plant_part pointer <- view();
		
		loop i from: 0 to: length(structure) - 1 
		{
			string token <- structure at i;
			
			//pointer <- view();
			
			if pointer != nil
			{
				switch token {
					match "F" 										//	Create main stem
					{	
						
						create stem number: 1 returns:stm
						{
							self.alpha		<- alpha_o;
							self.beta		<- beta_o;
							parent			<- pointer;
							level			<- parent.level + 0.5;
							main_stem 		<- true;
							self.base 		<- pointer.end;
							self.end		<- self.base + {0.0,0.0,length};
						}	
						
						pointer <- first(stm);
					}
					match "E" 										//	Final branch
					{
						
						create stem number: 1 returns:stm
						{
						
							parent			<- pointer;
							self.alpha 		<- alpha_o;
							self.beta		<- beta_o;
							self.gamma 		<- gamma_o ;
							self.length		<- rnd(2.0,15.0);
							main_stem 		<- false;
							
							self.base		<- parent.end;
							self.width		<- 1.0;
							
							self.end 		<- self.base + {
															self.length * cos(self.beta) * cos(self.alpha + self.gamma), 
															self.length * cos(self.beta) * sin(self.alpha + self.gamma), 
															self.length * sin(self.beta)
															};
						}
						
						pointer <- first(stm);
						
						create leaf
						{
							self.alpha 		<- alpha_o;
							self.beta		<- beta_o;
							self.gamma 		<- gamma_o ;
							
							parent 		 <- pointer;
							self.base 	 <- parent.end;
							self.end 	 <- self.base + {1.5*cos(beta)*cos(alpha), 1.5 * cos(beta) * sin(alpha),  1.5*sin(beta)};
						}
						
					}
					match "X" 										// Branch and leaves to expand
					{
						
						create stem number: 1 returns:stm
						{
							self.alpha 		<- alpha_o;
							self.beta		<- beta_o;
							self.length		<- rnd(2.0,15.0);
							
							main_stem 		<- false;
							
							parent			<- pointer;
							self.level		<- parent.level + 0.3;
							self.base		<- parent.end;
							width			<- 1.0;
							self.gamma 		<- gamma_o ;
							self.end 		<- self.base + {
															self.length * cos(self.beta) * cos(self.alpha + self.gamma), 
															self.length * cos(self.beta) * sin(self.alpha + self.gamma), 
															self.length * sin(self.beta)
															};
						}
						
						pointer <- first(stm);
						
						
						create leaf
						{
							self.alpha 		<- alpha_o;
							self.beta		<- beta_o;
							self.gamma 		<- gamma_o ;
							
							parent		 <- pointer;//first(stm); //pointer;
							self.base 	 <- parent.base;
							self.end 	 <- self.base + {1.5*cos(beta)*cos(alpha), 1.5 * cos(beta) * sin(alpha),  1.5*sin(beta)};
						}
						
					}
					match "[" 										// Push in stack
					{
						do push(pointer);
						
					}
					match "]" 										// Pop in stack
					{
						pointer <- pop();
					}
					match "+" 										// Positive angle
					{
						alpha_o <- 70 + gauss(0, 45);  
						beta_o 	<- 15 + gauss(0, 5);  
						gamma_o	<- rnd(1.0)*30;
					}	
					match "-" 										// Negative angle
					{
						alpha_o <- -70 - gauss(0, 45);  
						beta_o 	<-  15 + gauss(0, 5);  
						gamma_o	<- rnd(1.0)*30;
					}
					match "f" 										// Flower
					{
						create flower number:1 returns:fl
						{
							parent		 <- pointer;
							
							self.alpha 		<- alpha_o * 0.6 + gauss(0,15);
							self.beta		<- beta_o * 0.8 + gauss(0,8);
							self.gamma 		<- gamma_o ;
							
							self.length	 <- 5.0;
							self.base 	 <- parent.end;
							self.end 	 <- self.base + {
															self.length * cos(self.beta) * cos(self.alpha), 
															self.length * cos(self.beta) * sin(self.alpha), 
															self.length * sin(self.beta)
															};
						}
						
					}
					match "x"										// branch 
					{
						
						create stem number:1 returns:stm
						{
							parent			<- pointer;
							
							self.alpha 		<- alpha_o;
							self.beta		<- beta_o;
							self.gamma 		<- gamma_o;
							
							self.level		<- parent.level + 0.3;
							self.length		<- rnd(2.0,15.0);
							main_stem 		<- false;
							self.base		<- parent.end;
							width			<- 1.0;
							self.end 		<- self.base + {
															self.length * cos(self.beta) * cos(self.alpha + self.gamma), 
															self.length * cos(self.beta) * sin(self.alpha + self.gamma), 
															self.length * sin(self.beta)
															};
							
						}
						
						pointer <- first(stm);
						
						create leaf
						{
							self.alpha 		<- alpha_o;
							self.beta		<- beta_o;
							self.gamma 		<- gamma_o ;
							
							parent		 <- pointer; // first(stm);
							self.base 	 <- parent.end;
							self.end 	 <- self.base + {1.5 * cos(beta) * cos(alpha), 1.5 * cos(beta) * sin(alpha),  1.5 * sin(beta)};
						}
						
					}
					match "e" 										// branch to expand
					{
						
						create stem number: 1 returns:stm
						{
							parent			<- pointer;
							
							self.alpha 		<- alpha_o;
							self.beta		<- beta_o;
							self.gamma 		<- gamma_o ;
							self.level		<- parent.level + 0.3;
							
							self.length		<- rnd(2.0,15.0);
							main_stem 		<- false;
							self.base		<- parent.end;
							width			<- 1.0;
							
							self.end 		<- self.base + {
															self.length * cos(self.beta) * cos(self.alpha + self.gamma), 
															self.length * cos(self.beta) * sin(self.alpha + self.gamma), 
															self.length * sin(self.beta)
															};
						}
						
						pointer <- first(stm);
						
						create leaf
						{
							self.alpha 		<- alpha_o;
							self.beta		<- beta_o;
							self.gamma 		<- gamma_o ;
							
							parent		 <- pointer; //first(stm);
							self.base 	 <- parent.end;
							self.end 	 <- self.base + {1.5*cos(beta)*cos(alpha), 1.5 * cos(beta) * sin(alpha),  1.5*sin(beta)};
						}
						
					}
					match "G"										// Fruit 	
					{
						create fruit number:1 returns: fr
						{
							parent		 <- pointer;
							
							self.alpha 		<- alpha_o + 10 + rnd(1.0) * 20.0;
							self.beta		<- beta_o*0.8+5.0+rnd(1.0) * 10.0;
							self.gamma 		<- gamma_o ;
							
							self.length	 <- 5.0;
							self.base 	 <- pointer.end;
							self.end 	 <- self.base + {
															self.length * cos(self.beta) * cos(self.alpha), 
															self.length * cos(self.beta) * sin(self.alpha), 
															self.length * sin(self.beta)
															};
						}
						
					}
					
				}		
				write stack;	
				
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
	float		gamma		<- 0.0;
	
	// visualization attributes
	float		length		<- 5.0;
	float 		width		<- 2.0;
	
	// animation attributes
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
		draw line([base, end], 1.0) color: #green; 
		draw sphere(1) color: #yellow at:end;//line([base, end], width) color: #green; 
	}
}


species leaf parent:plant_part
{
	float size 		<- 5.0;
	float width 	<- 3.0;
	
	pair<float, point> rota <- rotation_composition(float(rnd(180))::{1, 0, 0}, float(rnd(180))::{0, 1, 0}, float(rnd(180))::{0, 0, 1});
	
	aspect default
	{
		draw line([base, end], min([parent.width, 1])) color: #green;
		draw f_leaf size: size rotate: rota at: end ;
		//draw circle(3) color: #green at:base;//line([base, end], width) color: #green; 
	}
}

species fruit parent:plant_part
{
	float length <- 2.0;
	aspect default
	{
		draw line([base, end], 1) color: #green; 
		draw sphere(1) color: #red at:end;//line([base, end], width) color: #green; 
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



