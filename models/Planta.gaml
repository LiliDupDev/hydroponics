/**
* Name: Planta
* Based on the internal empty template. 
* Author: lin_2
* Tags: 
*/



model Planta



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
	float beta 		<- 0.0;
	float omega 	<- 14.6;	// Leaf area ratio
	float alpha		<- 3.5*10^(-9);
	
	
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
	float delta_s			<- 0.0;
	

	
	
	//bool  light   			<- true; 	// True -> Light period is active / False -> Dark period active
	int   t_l     			<- 0  ;		// Ligth period, value represent cycle number
	float t_la				<- 0.0;   	//
	int   t_d     			<- 0  ;		// Dark period, value represent cycle number
	float t_da				<- 0.0;
	float light				<- 0.0;
	float dark  			<- 0.0;
	//int  t_count 			<- 23;		// Period count, will reset every 24 hours
	
	float delta		<-0.0;
	
	
	float photosinthesis(float respiration_temp)
	{
		return U_L*respiration_temp;
	}

	
	float r_growth(float maintenance_r)
	{
		return theta/(a*omega*maintenance_r);
	}
	
	float r_maintenace(float respiration_temp)
	{
		return respiration_temp*s;
	}
	
	// Esponential respiration
	float respiration_f(float temperature)
	{
		return alpha*exp(beta*temperature);
	}


	float u_crop(float intercepted_radiation)
	{
		return s+(gamma+1)*theta*intercepted_radiation;
	}

	
	reflex biomass_change
	{
		//L <- omega/s;
		beta  <- 0.0693/K;
		c_max <- epsilon*a*L;
		
		/* 
		if cycle != 0
		{
			theta <- r_growth_la/(a*omega*r_maintenance);
		}
		*/
		
		
		float intercepted_radiation <- 1-exp(-a*L);
		U_L 	<- u_crop(intercepted_radiation);
		
		float respiration_temperature_l <- respiration_f(20.0);
		float respiration_temperature_d <- respiration_f(15.0);
		
		v_photosinthesis <- photosinthesis(respiration_temperature_l);
		
		r_maintenance <- r_maintenace(respiration_temperature_l);
		r_growth_la   <- r_growth(r_maintenance);
		
		delta_s <- gamma *r_growth_la ;
		s <- s+delta_s;
		
	
		
		if export 
		{
			save data:[   cycle
						, L
						, pi
						, a
						, K
						, alpha
						, gamma
						, theta
						, epsilon
						, beta
						, mu
						, v
						, intercepted_radiation
						, respiration_temperature_l
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


