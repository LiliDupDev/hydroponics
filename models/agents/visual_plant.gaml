/**
* Name: visualplant
* Based on the internal empty template. 
* Author: Lili
* Tags: 
*/


model visualplant

species plant
{
	float 	length_max 	<- 25.0;//100.0;
	float 	width_ini 	<- 0.05; // 1.0
	float 	max_width_stem		<- 0.15;
	float 	max_width_branch	<- 0.1;
	float 	max_branch_length	<- 30.0;
	float 	max_stem_length		<- 25.0;//7.0;
	float 	level_step 	<- 0.7; // 0.8
	float 	env_size 	<- 0.5 * length_max / (1 - level_step);
	
	map<string,int> stem_type <- ["MAIN"::1,"BURGEON"::2];
	
	int 	max_level 	<- 7;//8;
	float 	min_energy 	<- 100.0;//300.0
	float 	main_split_angle_alpha 		<- 30.0;
	float 	secondary_split_angle_alpha <- 90.0;
	float 	main_split_angle_beta 		<- 20.0;
	float 	secondary_split_angle_beta 	<- 90.0;
	
	
	
	
	image_file f_leaf <- image_file("../includes/img/leaf.png");
	
	
	
	
	point 		base 		<- {0, 0, 0};
	point 		end 		<- {0, 0, 0};
	float 		alpha 		<- 0.0;
	float 		beta 		<- 0.0;
	float 		level 		<- 1.0;
	list 		children	<- nil;
	float 		energy 		<- 0.0;
	
	
	int			truss		<- 0;
	
	// ATRIBUTES for TOMGRO
	float FTRUSN	;			// Node number on the plant that bears the first truss	
	float WPLI		;			// Initial weight per initiated leaf   
	float WPFI		;			// Initial weight per initiated fruit
	float FRLG		;			// Lag period between the time that a no (nodes) truss appears and a fruit appears on plant that truss
	float PLSTNI	;			// Initial plastochron index
	float LVSNI		;			// Initial number of leaves per plant
	float WLVSI		;			// Initial weight of leaves  // For testing purpose the value was 0.005
	float LFARI		;			// Initial leaf area per plant
	
	species seed
	{
		
		
		aspect default
		{
			draw cone3D(6.0, 6.0) at: location color: #olive;//rgb(110, 170, 124);
		}
	}
	
	species stem
	{
		float 	width;
		float 	length;
		bool 	is_main_stem <- false;
		bool 	can_split	 <- true;
		bool 	is_branch	 <- false;
		
		aspect default
		{
			draw line([base, end], width) color: #green; 
		}
		
	}
	
	species leaf
	{
		// Visual variables
		int   creation_cycle<- -1;
		float level 		<- 1.0;
		float alpha 		<- 0.0;
		float beta 			<- 0.0;
		
		stem 		parent;
		point 		base;
		point 		end;
		
		float size 		<- 3.0;//0.5;
		float max_size 	<- 3.0;
			
	}
	
	species burgeon // truss
	{}
	
	species fruit
	{}
	
	
	
}
