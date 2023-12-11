/**
* Name: PrimerModelo
* Based on the internal empty template. 
* Author: lin_2
* Tags: 
*/


model PrimerModelo



global
{
	
	bool export <- true;
	
	
	
	init
	{
	
		step <- 24#hours;
		create plant number:1
		{
			t_l   <- 12;
			t_d   <- 24-t_l;
			s     <- 0.8; 
		}
	}
	
}


// Environment species

// Asumimos que cada ciclo dura 1 hora y solo definiremos la duración del periodo de luz (T_D). El periodo de oscuridad se deduce restando 24-T_L
species plant{
	rgb color_i <- #purple;//rgb(rnd(0,255),rnd(0,255),rnd(0,255));
	
	// Constants
	float L 		<- 0.15;//rnd(0.0,0.002);
	float pi 		<- 1.8*10^(-6);
	float a 		<- 0.8;
	float K 		<- 0.58;
	float gamma 	<- 3.0;
	float theta 	<- 0.3;
	float epsilon 	<- 0.008;
	float mu		<- 0.0;
	float v			<- 7*10^(-9);
	
	// Variables
	float I 				<- 100.0;  	// Light flux, 0 in dark periods
	float r_growth_la 		<- 0.0;		// Grow respiration by light period value
	float r_growth_da 		<- 0.0;		// Grow respiration by dark period value
	float r_maintenance 	<- 0.0;		// Maintenance respiration value
	float v_photosinthesis  <- 0.0;		// Photosinthesis value
	float c_max 			<- 0.0; 	// Max carbon storage
	float c_x				<- 0.0;		// Current carbon storage
	float U_L 				<- 0.0;		// Crop property
	float s   				<- 0.0; 	// Biomass
	float dseta				<- 0.0;		// Change in carbon storage during light period
	float eta				<- 0.0;		// Change in carbon storage during dark period
	float omega 			<- 14.6;	// Leaf area ratio

	
	
	//bool  light   			<- true; 	// True -> Light period is active / False -> Dark period active
	int   t_l     			<- 0  ;		// Ligth period, value represent cycle number
	float t_la				<- 0.0;   	//
	int   t_d     			<- 0  ;		// Dark period, value represent cycle number
	float t_da				<- 0.0;
	float light				<- 0.0;
	float dark  			<- 0.0;
	//int  t_count 			<- 23;		// Period count, will reset every 24 hours
	
	float delta		<-0.0;
	
	init
	{
		//t_d <- 24-t_l;
	}
	
	
	float photosinthesis(float intercepted_radiation) 
	{
		return pi*(I/(I+K))*intercepted_radiation;
	}
	
	float growth_respiration(float respiration_temperature, float intercepted_radiation)
	{
		return theta*respiration_temperature*intercepted_radiation;//a*L;//*intercepted_radiation;
	}
	
	float maintenance_respiration(float respiration_temperature)
	{
		return respiration_temperature*s;
	}
	
	float crop_property(float intercepted_radiation)
	{
		return s+(gamma+1)*theta*intercepted_radiation;
	}
	
	float compute_container(float intercepted_radiation)
	{
		return epsilon*intercepted_radiation;
	}
	
	// This represents function F in model ecuations
	action respiration(float c_m, float v_photo, float u_crop)
	{
		t_la <- (v_photo-(c_m/t_l))/u_crop;
		t_da <- (c_m/t_d)/u_crop;
	}
	
	float respiration_f_l(float temperature)
	{
		return mu+v*temperature;
	}
	
	action carbon_change(float v_photo, float u_crop){
		dseta <-  v_photo-u_crop*t_la;
		eta   <-  u_crop*t_da;
	}
	
	reflex biomass_change
	{
		L 		<- omega*s;
		c_max <- epsilon*a*L;//epsilon*(1-exp(-a*L));
		
		
		if export 
		{
			save data:[   cycle
						, L
						, pi
						, a
						, K
						, gamma
						, theta
						,epsilon
						, mu
						, v
						, I
						, r_growth_la
						, r_growth_da
						, r_maintenance
						, v_photosinthesis
						, c_max
						, c_x
						, U_L
						, s
						, delta
						, dseta
						, eta
						, t_l
						, t_la
						, t_d
						, t_da
			] to:"overall.csv" type:csv rewrite:false;
		
		}
		
		
		float intercepted_radiation 	<- 1-exp(-a*L);
		float respiration_temperature 	<- 0.0;
		float delta_s 					<- 0.0;
		
		float temperature_l <- 20.0;
		float temperature_d <- 10.0;
		
		
		U_L						<- crop_property(intercepted_radiation);
		v_photosinthesis	 	<- photosinthesis(intercepted_radiation);
		
		
		//do respiration(c_max,v_photosinthesis,U_L);
		t_la <- respiration_f_l(temperature_l);
		t_da <- respiration_f_l(temperature_d);
		
		r_growth_la 			<- growth_respiration(t_la,intercepted_radiation);
		r_growth_da 			<- growth_respiration(t_da,intercepted_radiation);
		
		r_maintenance 			<- maintenance_respiration(t_da);
		
		
		// Carbon change
		do carbon_change(v_photosinthesis,U_L);
		c_x <- c_max + dseta - eta;
		
		
		// Biomass
		light <- ((gamma*r_growth_la*c_max)/dseta) + (gamma*r_growth_la-(t_l-c_max/dseta));
		dark <- ((gamma*r_growth_da*c_max)/eta) -(gamma*r_growth_da*(t_d-c_max/eta)/(gamma+1)) ;
		
		
		//write "light:"+ light;
		//write "dark:"+ dark;
		
		
		delta_s <- light + dark;
		//delta_s <- (gamma*r_growth_la*t_l)+(gamma*r_growth_da*t_d);
		
		delta <- delta_s;
		
		s <- s+delta_s;
		
		omega   <- L/s;
		
		
		//omega <- L/s;
	}
	
	
}





experiment mi_experimento type:gui{

	
	output{
		display GUI type:opengl 
		{
			
			
		}
		
		display Statistics
		{
   			chart "Biomass" type:series y_label:"Biomass"  size: {0.5,0.5} position: {0.0, 0.0}
			{
				datalist plant value:(plant collect each.s) legend:(plant collect each.name) color:(plant collect each.color_i) marker:false;
				
			}
			
			chart "Photosinthesis" type:series y_label:"Photosinthesis"  size: {0.5,0.5} position: {0.5, 0.0}
			{
				datalist plant value:(plant collect each.v_photosinthesis) legend:(plant collect each.name) color:(plant collect each.color_i) marker:false;
				
			}
			
			chart "L" type:series y_label:"L"  size: {0.5,0.5} position: {0.0, 0.5}
			{
				datalist plant value:(plant collect each.L) legend:(plant collect each.name) color:(plant collect each.color_i) marker:false;
				
			}
			
			chart "Maintenance" type:series y_label:"Maintenace"  size: {0.5,0.5} position: {0.5, 0.5}
			{
				datalist plant value:(plant collect each.r_maintenance) legend:(plant collect each.name) color:(plant collect each.color_i) marker:false;
				
			}
			
			
		}
		
	}
}


