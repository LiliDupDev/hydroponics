/**
* Name: tomgrocomplete
* Based on the internal empty template. 
* Author: lin_2
* Tags: 
*/


model tomgrocomplete
import "tomato_generic.gaml"

global
{
	
}


species tomato_seed parent:plant_seed
{
	reflex germination
	{
		do create_main_stem;
	}
}

species tomato_leaf parent: leaf
{
	
}


species tomato_stem parent: stem
{
	
}


species tomato_fruit parent: fruit
{
	
}


species truss parent:burgeon
{
	
}


experiment tomato_growth type: gui autorun: false {
	float minimum_cycle_duration <- 0.0005;
	float seed <- 0.05387546426306633;
	output {
		display 'Tomato' type: opengl {//background: #lightskyblue axes: true toolbar: true {
			// light #ambient intensity: 150;
			// //rotation angle: cycle/1000000 dynamic: true;
			// //camera #default location: {50.0,450,250} target: {50.0,50.0,40+80*(1-exp(-cycle/50000))} dynamic: true;
			 species plant_seed 	aspect: default;
			 species tomato_stem 	aspect: default;
			// //species stem_branch aspect: default;
			species tomato_leaf 	aspect: default;
			species tomato_fruit 		aspect: default;
		}

	}
}



