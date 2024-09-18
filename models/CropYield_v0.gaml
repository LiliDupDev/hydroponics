/**
* Name: CropYieldv0
* Based on the internal empty template. 
* Author: Lili
* Tags: 
*/


model CropYieldv0


global {
	
	map<string,rgb> color_input <- ["co2":: #turquoise, "ppfd":: #gold, "temp":: #tomato];
	
	int axis_x 	<- 6;
	int axis_y  <- 2;
	int PLM2	<- 3;
	
	bool distribute <- true;
	
	int 	total_plants 			<- axis_x*axis_y*PLM2;
	int 	distribution_by_width 	<- axis_y*PLM2;
	int 	distribution_by_length 	<- axis_x*PLM2;
	int 	separation;
	float 	distance_per_plant;
	
	matrix<float> distribution;
	
	image_file seedling <- image_file("../includes/img/plantula_2.png");
	
	
    init 
    {
    	// ---------------------------- START: Computations to distribute plants in escenario
    	distribution <- {distribution_by_width, distribution_by_length} matrix_with 0;
    	
    	int count <- 0;
    	loop col from: 1 to: distribution_by_width-1 step: 1 {
			loop row from: 0 to: distribution_by_length-1 step: 1 {
				if count mod PLM2 = 0
				{
					count <- 0;
					distribution[{col,row}] <- 1.0;
				}
				
			}
			count <- count+1;
		}
    	// ---------------------------- END:Computations to distribute plants in escenario
		
		ask crop_distribution 
		{				
	        grid_value <- float(distribution[{grid_x,grid_y}]);
	        color <- (grid_value = 1.0) ? #palegoldenrod : #white;
	        if grid_value=1.0
	        {
	        	create tomato number:1 
		        {
		        	location <- myself.location;
		        }
	        }
	        
	    }     
	    
	    
	    
    }
}



grid crop_distribution width:distribution_by_width height:distribution_by_length 
{
	bool taken <- false;
	/*
    reflex update_color {
        write grid_value;
        color <- (grid_value = 1) ? #blue : #white;
    }
    
    */ 
}

species tomato
{
	crop_distribution my_cell <- one_of (crop_distribution);
	
	aspect default
	{		
	  draw seedling size: 5 at:location;	
	}
}



experiment main type: gui{
	category "YIELD" expanded: false color: #green; 
	
	parameter "Length" 			category:"YIELD" var: axis_x;
	parameter "Width" 			category:"YIELD" var: axis_y ;
	parameter "Plant density" 	category:"YIELD" var: PLM2 	;
	
	
    output {
        display display_grid {
        	
        	
        	// Creating chart with inputs
			overlay position: { 5, 5 } size: { 90#px, 100 #px } background: # white transparency: 0.5 border: #black rounded: true
            {
            	//for each possible type, we draw a square with the corresponding color and we write the values
                float y <- 30#px;
	            loop type over: color_input.keys
	            {
	            	draw square(5#px) at: { 10#px, y } color: color_input[type] border: #black;
	            	draw type at: { 20#px, y + 2#px } color: #black font: font("Helvetica", 12, #bold);
	                y <- y + 25#px;
	            }
            }
			
			
            grid crop_distribution border:#black;
            species tomato aspect:default;
        }
    }
}