/**
* Name: CropYieldv0
* Based on the internal empty template. 
* Author: Lili
* Tags: 
*/


model CropYieldv0


import "agents/TOMGRO_unit.gaml"

global {
	
	image_file terrain <- image_file("../includes/img/top-view-dark-soil-background.jpg");
	
	map<string,rgb> color_input <- ["co2":: #turquoise, "ppfd":: #gold, "temp":: #tomato];
	map<string,float> environment_val <- ["co2":: 0.0, "ppfd":: 0.0, "temp":: 0.0];
	
	int axis_x 	<- 6;
	int axis_y  <- 2;
	//int PLM2	<- 3;
	
	bool distribute <- true;
	
	int 	separation 				<- PLM2=1.0 ? 2 : int(PLM2);
	
	int 	total_plants 			<- axis_x * axis_y * int(PLM2);
	int 	distribution_by_width 	<- axis_y * separation;
	int 	distribution_by_length 	<- axis_x * int(PLM2);
	float 	total_area				<- float(axis_x)*float(axis_y);
	float 	distance_per_plant;
	

	// Variables for monitor
	map<string,float> growing_vals <- [	  "leaves-weight"	:: 0.0
										, "leaves-no"		:: 0.0
										, "stem-weight"		:: 0.0
										, "stem-no"			:: 0.0
										, "fruit-weight"	:: 0.0
										, "fruit-no"		:: 0.0
										, "lai"				:: 0.0
									 ];
	
	matrix<float> distribution;
	
	
	
	bool	export 			<- true;
	int		simulation_days	<- 150;
	int 	simulation_duration ;
	
	
    init 
    {
    	step <- 1#hour;
		//day_changes 			<- matrix(csv_file("../includes/day_changes.csv", true));
		simulation_duration <- 1376;//simulation_days * 24;
		
		
		
    	// ---------------------------- START: Computations to distribute plants in escenario
    	
    	distribution <- {distribution_by_width, distribution_by_length} matrix_with 0;
    	
    	int count <- 0;
    	loop col from: 1 to: distribution_by_width step: 1 {
			loop row from: 0 to: distribution_by_length step: 1 {
				if count mod separation = 0
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
	        //color <- (grid_value = 1.0) ? #palegoldenrod : #white;
	        
	        if grid_value=1.0
	        {
	        	create tomato number:1 
		        {
		        	location <- myself.location;
		        }
	        }
	    }    
	    create TOMGROW number:1;
	    
    }
    
    
    
    	reflex daily when:every(24#hours)
	{
		int day <- cycle/24;
		
		ask TOMGROW
		{
			do main_cycle;
			
			growing_vals["leaves-weight"] 	<- total_area*TOTWML;
			growing_vals["leaves-no"]		<- total_area*TOTNLV;
			growing_vals["stem-weight"]		<- total_area*TOTWMF;
			growing_vals["stem-no"]			<- total_area*TOTNF;
			growing_vals["fruit-weight"]	<- total_area*TOTWST;
			growing_vals["fruit-no"]		<- total_area*TOTNST;
			growing_vals["lai"]				<- total_area*XLAI;
									 
		}
		ask tomato
		{
			do growth(day);
		}
	}
	
	
	
	reflex hourly
	{
		int hour <- cycle mod 24;
		
		environment_val["temp"] <- day_changes[{1,hour}];			//float temperature 	<-day_changes[{1,hour}];
		environment_val["co2"] 	<- day_changes[{2,hour}];			//float CO2 			<-day_changes[{2,hour}];
		environment_val["ppfd"] <- day_changes[{3,hour}];			//float PAR				<-day_changes[{3,hour}];	
		//environment_val[] <- day_changes[{,}];//float PPFD			<-day_changes[{4,hour}];
		
		ask TOMGROW
		{
			do fast_cycle(
						  environment_val["temp"]
						, environment_val["co2"] 
						, environment_val["ppfd"]
						);//hourly_GROWTH(temperature,CO2,PAR,PPFD);
		}
	}



	reflex stop when:cycle=simulation_duration // 80 days
	{
		int day <- cycle/24;

		do pause;
	}
	
    
    
}



grid crop_distribution width:distribution_by_width height:distribution_by_length 
{

}


species tomato
{
	image_file plantula		<- 	file("../includes/img/hojas_tomate_s1.png");
	image_file plantula_2	<-	file("../includes/img/hojas_tomate_s2.png");
	image_file pza_1		<-  file("../includes/img/plantula_2.png");
	image_file pza_2		<-  file("../includes/img/plantula_3.png");
	image_file pza_3		<-  file("../includes/img/plantula_4.png");
	image_file pza_4		<-  file("../includes/img/plantula_5.png");
	image_file graphics		<-  flip(0.5) ? plantula : plantula_2;
	
	map<string,bool> fruit 	<-[   "T1"::false
								, "T2"::false
								, "T3"::false
								, "T4"::false
								, "T5"::false
								, "T6"::false
								, "T7"::false
								];
								
	map<string,int> fruit_age 	<-["T1"::0
								,  "T2"::0
								,  "T3"::0
								,  "T4"::0
								,  "T5"::0
								,  "T6"::0
								,  "T7"::0
								];
								
	
	
	action growth(int age)
	{
		// Leaves
		switch(age)
		{
			match_between [0,5]
			{
				
			}
			match_between [5, 10]
			{
				graphics <- pza_1;
			}
			match_between [11, 25]
			{
				graphics <- pza_2;
			}
			match_between [26, 30]
			{
				graphics <- pza_3;
			}
			match_between [31, 50]
			{
				graphics <- pza_4;
				if(!fruit["T7"]){fruit["T7"]<-flip(0.5);}
				if(!fruit["T6"]){fruit["T6"]<-flip(0.5);}
			}
			match_between [51, 70]
			{
				graphics <- pza_4;
				if(!fruit["T7"]){fruit["T7"]<-flip(0.5);}
				if(!fruit["T6"]){fruit["T6"]<-flip(0.5);}
				if(!fruit["T5"]){fruit["T5"]<-flip(0.5);}
				if(!fruit["T4"]){fruit["T4"]<-flip(0.5);}
				if(!fruit["T3"]){fruit["T3"]<-flip(0.5);}
				
			}
			match_between [70, 100]
			{
				graphics <- pza_4;
				if(!fruit["T7"]){fruit["T7"]<-flip(0.5);}
				if(!fruit["T6"]){fruit["T6"]<-flip(0.5);}
				if(!fruit["T5"]){fruit["T5"]<-flip(0.5);}
				if(!fruit["T4"]){fruit["T4"]<-flip(0.5);}
				if(!fruit["T3"]){fruit["T3"]<-flip(0.5);}
				if(!fruit["T2"]){fruit["T2"]<-flip(0.5);}
				if(!fruit["T1"]){fruit["T1"]<-flip(0.5);}
			}
			default
			{
				if(!fruit["T7"]){fruit["T7"]<-flip(0.5);}
				if(!fruit["T6"]){fruit["T6"]<-flip(0.5);}
				if(!fruit["T5"]){fruit["T5"]<-flip(0.5);}
				if(!fruit["T4"]){fruit["T4"]<-flip(0.5);}
				if(!fruit["T3"]){fruit["T3"]<-flip(0.5);}
				if(!fruit["T2"]){fruit["T2"]<-flip(0.5);}
				if(!fruit["T1"]){fruit["T1"]<-flip(0.5);}
			}
		}
	}
	
	
	reflex age_fruit when:every(24#hours)
	{
		loop s over: fruit_age.keys{
			if fruit[s]
			{
				if fruit_age[s] =30
				{
					fruit_age[s] <-0;
					fruit[s] <-false;
				}
				fruit_age[s] <- fruit_age[s]+1;
			}
		}
	}
	
	
	
	aspect default
	{		
	  	draw graphics size: 10 at:location;	
	  	
	  	draw circle(0.5) color:fruit["T1"] ? #red : rgb(255,0,0,0.0)  at: location + {-2,0.5} 	; 			// OK
		draw circle(0.5) color:fruit["T2"] ? #red : rgb(255,0,0,0.0)  at: location + {1,-1}; 	// OK
		draw circle(0.5) color:fruit["T3"] ? #red : rgb(255,0,0,0.0)  at: location + {2,-2}; 	// OK
		draw circle(0.5) color:fruit["T4"] ? #red : rgb(255,0,0,0.0)  at: location + {-2,1.5}  ; 	// OK
		draw circle(0.5) color:fruit["T5"] ? #red : rgb(255,0,0,0.0)  at: location + {-2,0}   	; 	// OK
		draw circle(0.5) color:fruit["T6"] ? #red : rgb(255,0,0,0.0)  at: location + {2,3}    	;  	// OK
		draw circle(0.5) color:fruit["T7"] ? #red : rgb(255,0,0,0.0)  at: location + {0,2}    	;  	// OK
	}

	
}



experiment main type: gui{
	category "YIELD" expanded: false color: #green; 
	
	parameter "Length" 			category:"YIELD" var: axis_x;
	parameter "Width" 			category:"YIELD" var: axis_y ;
	parameter "Plant density" 	category:"YIELD" var: PLM2 	;
	
	
    output {
    	monitor "Leaves - Dry weight" 	value: growing_vals["leaves-weight"] ;
    	monitor "Leaves - Number" 		value: growing_vals["leaves-no"]	 ;
    	monitor "Stem - Dry weight" 	value: growing_vals["stem-weight"]	 ;
    	monitor "Stem - Number" 		value: growing_vals["stem-no"]		 ;
    	monitor "Fruit - Dry Weight" 	value: growing_vals["fruit-weight"]	 ;
    	monitor "Fruit - Number" 		value: growing_vals["fruit-no"]		 ;
    	monitor "LAI" 					value: growing_vals["lai"]			 ;
    	
        display display_grid type: 3d axes:false 
        {
        	
        	// Creating chart with inputs
			overlay position: { 5, 5 } size: { 170 #px, 160 #px } background: # white transparency: 0.5 border: #black rounded: true
            {
            	//for each possible type, we draw a square with the corresponding color and we write the values
                float y <- 30#px;
                draw "Enviroment changes" at: { 20#px, y + 2#px } color: #black font: font("Helvetica", 14, #bold);
	            y <- y + 25#px;
	            
	            loop type over: color_input.keys
	            {
	            	draw square(5#px) at: { 10#px, y } color: color_input[type] border: #black;
	            	draw type+": "+string(environment_val[type]) at: { 20#px, y + 2#px } color: #black font: font("Helvetica", 12, #bold);
	                y <- y + 25#px;
	            }
	            
	            draw "Day: "+ int(cycle / 24) + " - Hour: "+cycle mod 24 at: { 20#px, y + 2#px } color: #midnightblue font: font("Helvetica", 14, #bold);
	            y <- y + 25#px;
	            
            }
            
            image terrain position: {0.05, 0.05} size: {1.0, 1.0} refresh: false;
        	
			
            //grid crop_distribution border:#black;
            species tomato aspect:default refresh:true;
        }
    }
}