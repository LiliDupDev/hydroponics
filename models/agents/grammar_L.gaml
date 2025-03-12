/**
* Name: grammarL
* Tomato growth with grammar L 
* Author: Liliana Durán-Polanco
* Tags: 3D_model
*/


model grammarL


global
{
	init
	{
		step <- 1#day;
		
		create tomato_plant number:1;
	}
	
	
}


species tomato_plant
{
	int counter_stage <- 0;
	
	list<string> alphabet_prod 		<- ["F","E","X"];
	list<string> alphabet_control 	<- ["+","-","[","]","f","x","e"];
	int age;
	string axiom <- "FE";
	string current_state ;
	map<int,int> age_day <- [1::6,2::6,3::6,4::8,5::31,6::9,7::200];
	map<string,map<int,string>> rules <- ["F"::[1::"F",
												2::"F",
												3::"F",
												4::"F",
												5::"F",
												6::"F",
												7::"FG"
										  ],
										  "E"::[1::"F[+X]F[-X]E",
										  	    2::"F[+X]F[-X]E",
										  	    3::"F[+X]F[-X]E",
										  	    4::"F[+X]F[-X]E",
										  	    5::"F[+X]F[-X]E",
										  	    6::"F[+X]F[-X]E"
										  ],
										  "X"::[1::"X",
										  		2::"X",
										  		3::"X",
										  		4::"X",
										  		5::"f[+X]f[-X]Fe",
										  		6::"f[+x]f[-x]fx"
										  ]
										 ];
	
	
	
	init
	{
		current_state 	<- axiom;
		age 	<- 0;
	}
	
	reflex stage_1
	{
		//write "AGE: " + age + " ------> " + current_state;
		
		if age_day[age] = counter_stage
		{
			age <- age + 1;
			counter_stage <- 0;
		}
		else
		{
			counter_stage <- counter_stage + 1;
		}
		
	
		
		loop element over:alphabet_prod
		{
			current_state <- replace(current_state, element, rules[element][age]);
		}
		
		
		
		/* *
		string new_state <- "";
		
		loop i from: 0 to: length(current_state) - 1 
		{
			string token <- current_state at i;
			 if token in alphabet_prod
			 {
			 	new_state <- new_state + rules[token][age];
			 	
			 }
			else if token in alphabet_control
			{
				new_state <- new_state + token;
			}
		}
		
		current_state <- new_state;
		*/
	}
	

	reflex stage_2 when: age = 5
	{
		//write "AGE: " + age + " ------> " + current_state;
		if counter_stage = 31
		{
			age <- age +1;
			counter_stage <- 0;
		} 
		else
		{
			counter_stage <- counter_stage + 1;
		}
		
		
	}
	
	reflex stage_3 when: age = 6
	{
		//write "AGE: " + age + " ------> " + current_state;
		if counter_stage = 9
		{
			age <- age +1;
		} 
		
		
	}
	
	reflex growth when: age = 7
	{
		
	}


}

experiment tomato_growth type: gui autorun: false 
{	
	float minimum_cycle_duration <- 0.05;
	
	float seed <- 0.05387546426306633;
	
	
	
	// Screen
	output {
		display 'Tomato' type: opengl {
			species tomato_plant;
		}
			
			
	}
		
}


