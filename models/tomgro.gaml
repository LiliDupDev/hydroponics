/**
* Name: tomgrol
* Based on the internal empty template. 
* Author: lin_2
* Tags: 
*/


model tomgro

global
{
	
	bool 			export 		<- true;
	matrix<float> 	day_changes;
	
	
	
	init
	{
		step <- 1#hour;
		day_changes 			<- matrix(csv_file("../includes/day_changes.csv", true));
		
		create tomato_plant number:1;
	}
	
	
	reflex daily when:every(24#hours)
	{
		ask tomato_plant
		{
			do daily_GROWTH;
		}
	}
	
	reflex hourly
	{
		int hour <- cycle mod 24;
		
		float temperature 	<-day_changes[{1,hour}];
		float CO2 			<-day_changes[{2,hour}];
		float PAR			<-day_changes[{3,hour}];	
		float PPFD			<-day_changes[{4,hour}];
		
		
		ask tomato_plant
		{
			do hourly_GROWTH(temperature,CO2,PAR,PPFD);
		}
	}
	
	
	
}


species tomato_plant
{
	
	// State variables
	float N_L <- rnd(0.0,2.0) ; // Leaves number
	float N_s <- 1.0 ; // Stem number
	float N_f <- 0.0 ; // Fruit number
	
	float W_L <- 0.005 ; // Weight of leaves
	float W_s <- 0.2 ; // Weight of stem
	float W_f <- 0.0 ; // Weight of fruits
	
	float A_L <- 0.001 ; // Leaf area

	
	float LAI <- 0.001;
	float RC  <- 0.0;
	
	list<float> leaf_aging      <- [];
	list<float> leaf_proportion <- [];
	
	
	map<string,float> currentState 	<-["N_L"::0.0, "N_s"::0.0,"N_f"::0.0,"W_L"::0.0,"W_s"::0.0,"W_f"::0.0,"A_L"::0.0];
	map<string,float> prevState 	<-["N_L"::0.0, "N_s"::0.0,"N_f"::0.0,"W_L"::0.0,"W_s"::0.0,"W_f"::0.0,"A_L"::0.0];
	map<string,float> d_Int			<-["N_L"::0.0, "N_s"::0.0,"N_f"::0.0,"W_L"::0.0,"W_s"::0.0,"W_f"::0.0,"A_L"::0.0];
	
	
	float age_class 	<- 1.0;
	float shadow_loss 	<- 0.0;
	

	// Variables
	float SUPPLY <- 0.0;
	float DEMAND <- 0.0;
	
	float L_dem <- 0.0;
	float S_dem <- 0.0;
	float F_dem <- 0.0;
	
	
	// Coefficients
	float D 	<- 2.593;
	float E 	<- 0.7  ;
	float FRLG 	<- 6.0  ;
	float FRPET <- 0.49 ;
	float FRSTM <- 0.33 ;
	float FTRSN <- 12.0 ;
	float GENRAT<- 0.5  ;		//	Daily integrated rate per plant as a function of plastochron index 
	float K		<- 0.58 ;
	float m		<- 0.1  ;
	float Q_10 	<- 1.4  ;
	float Q_e	<- 0.0645 ;
	float R_L	<- 0.015  ;
	float R_F	<- 0.010  ;
 	float S_CO_2<- 0.0003 ;
	float S_mn	<- 0.024  ;
	float S_mx	<- 0.075  ;
	float TPL 	<- 0.33	  ;
	float XLAIM	<- 5.00	  ;
	float beta_c<- 0.00085;
	float beta_T<- 0.085  ;
	float tau	<- 0.0693 ;
	float n_F	<- 20.0   ;
	float n_L	<- 10.0; //1.0	  ;			// Number of age classes for leaves
	float PLM2	<- 3.0	  ;			// Plant density
	float PLSTN <- rnd(1.0,10.0) ; 	// No. de nodos - Plastochron index
	float DELT  <- 1.0 ;  			// Time step of simulation within the main loop
	
	
	init
	{
		currentState["N_L"] <- N_L;
		currentState["N_s"] <- N_s;
		currentState["N_f"] <- N_f;
		currentState["W_L"] <- W_L;
		currentState["W_s"] <- W_s;
		currentState["W_f"] <- W_f;
		currentState["A_L"] <- A_L;
		
		leaf_aging <+ N_L;
		
		SUPPLY 	<- 1.0;
		DEMAND	<- 2.0;
		//LAI <- currentState["A_L"]*LAI;
		LAI 	<- currentState["A_L"]*currentState["N_L"]*0.0146;//currentState["A_L"]*LAI;
		
	}
	
	
	// Auxiliar Functions
	map<int,float>    root 		<- [1::0.2, 12::0.08, 20::0.08, 30::0.08, 50::0.08, 190::0.08]; 
	map<float,float>  tab_r_l   <- [0.0::0.0, 9.0::0.0, 12.0::0.0048, 15.0::0.0063, 21.0::0.0095, 28.0::0.0130, 35.0::0.0130, 50.0::0.0]; 
	map<float,float>  tab_r_f   <- [0.0::0.0, 9.0::0.0, 12.0::0.0053, 15.0::0.0103, 21.0::0.0203, 28.0::0.032, 35.0::0.032, 50.0::0.0]; 
	map<float,float>  tab_f_n   <- [0.0::0.0, 9.0::0.0, 12.0::0.55, 15.0::0.55, 21.0::0.55, 28.0::1.0, 35.0::1.0, 50.0::0.0]; 
	map<float,float>  tab_pgred <- [0.0::0.0, 9.0::0.67, 12.0::1.0, 15.0::1.0, 21.0::1.0, 28.0::1.0, 35.0::0.0, 50.0::0.0]; 
	map<float,float>  tab_fpn	<- [0.0::0.01, 6.0::0.01, 7.0::0.01, 8.0::0.2, 9.0::0.25, 13.0::1.5, 20.0::3.1, 24.0::3.1, 50.0::3.1, 90.0::3.1]; 
	
	map<int, float>   POF  		<- [1::0.03  , 2::0.07, 3::0.13, 4::0.3, 5::0.4, 6::0.4, 7::0.4, 8::0.4, 9::0.4, 10::0.0];
	map<int, float>   POL  		<- [1::0.0007, 2::0.0016, 3::0.0031, 4::0.0032, 5::0.0032, 6::0.0032, 7::0.0032, 8::0.0032, 9::0.0032, 10::0.0];
	
	
	float P_L_total
	{
		float tot <- 0.0;
		loop i from:0 to:length(leaf_aging)-1 step:1
		{
			tot <- tot+P_L(i);
		}

		return tot;
		
	}
	
	
	float P_L(int i)
	{
		return leaf_aging[i]*0.002;
	}
	
	float P_F(float i)
	{
		return i*0.025;
	}
	
	float P_root(float XROOT)
	{
		float proot <- 0.0;
		int   prev 	<- 0;
		
		loop s over: root.keys{
			if s > XROOT
			{
				proot <- root[prev];
				break;
			}
			prev <- s;
		}
		return proot;	
	}
	
	float r_L_T(float temp)
	{
		float rl 	<- 0.0;
		float prev 	<- 0.0;
		
		loop s over: tab_r_l.keys{
			if s > temp
			{
				rl <- tab_r_l[prev];
				break;
			}
			prev <- s;
		}
		return rl;	
	}
	
	float r_F_T(float temp)
	{
		float rf 	<- 0.0;
		float prev 	<- 0.0;
		
		loop s over: tab_r_f.keys{
			if s > temp
			{
				rf <- tab_r_f[prev];
				break;
			}
			prev <- s;
		}
		return rf;	
	}	
	
	float F_n_T(float temp)
	{
		float fn 	<- 0.0;
		float prev 	<- 0.0;
		
		
		loop s over: tab_f_n.keys{
			if s > temp
			{
				fn <- tab_f_n[prev];
				break;
			}
			prev <- s;
		}
		return fn;	
	}		
	
	float PGRED(float temp)
	{
		float pg 	<- 0.0;
		float prev 	<- 0.0;
		
		loop s over: tab_pgred.keys{
			if s > temp
			{
				pg <- tab_pgred[prev];
				break;
			}
			prev <- s;
		}
		return pg;	
	}		
	
	float FPN(float plstn)
	{
		float value <- 0.0;
		float prev  <- 0.0;
		
		loop s over: tab_fpn.keys{
			if s > plstn
			{
				value <- tab_fpn[prev];
				break;
			}
			prev <- s;
		}
		return value;
	}

	action compute_leaf_aging
	{
		float in  <- 0.0;
		
		
		if length(leaf_aging)<n_L
		{
			leaf_aging <+ leaf_proportion[length(leaf_proportion)-1];
		}
		
		loop i from:0 to:length(leaf_proportion)-1 step:1
		{
			/*  
			if i = n_L-1  // length(leaf_aging) = n_L and
			{
				shadow_loss <- leaf_proportion[i];
			}
			*/
			
			if i=0
			{
				in <- 0.0;
			}
			else
			{
				in <- leaf_proportion[i-1];
			}
			
			leaf_aging[i] <- leaf_aging[i]-leaf_proportion[i]+in;
		}
			
	}


	action daily_GROWTH // when:every(24#cycle)
	{
		int day <- int(cycle / 24);
		
		if export 
		{
			save data:[   cycle
						, day 
						, currentState["N_f"]
						, currentState["N_s"]
						, currentState["N_L"]
						, currentState["W_f"]
						, currentState["W_s"]
						, currentState["W_L"]
						, currentState["A_L"]
						, prevState["N_f"]
						, prevState["N_s"]
						, prevState["N_L"]
						, prevState["W_f"]
						, prevState["W_s"]
						, prevState["W_L"]
						, prevState["A_L"]
						, d_Int["N_f"]
						, d_Int["N_s"]
						, d_Int["N_L"]
						, d_Int["W_f"]
						, d_Int["W_s"]
						, d_Int["W_L"]
						, d_Int["A_L"]
						, LAI
						, shadow_loss
						, length(leaf_aging)
						, leaf_aging
			] to:"Daily_tomgro.csv" type:csv rewrite:false;
		}
		
		
		/*
		if int(cycle/24) > n_L
		{
			currentState["N_L"] <- currentState["N_L"]-shadow_loss; 	// Se resta el no. de hojas muertas
		}
		
		
		leaf_aging[0] <- leaf_aging[0]-d_Int["N_L"]; 				// Se agregan las nuevas hojas a la clase 0 que es la más joven
		*/
		
		// Se actualizan los valores de estado
		loop key over: prevState.keys
		{
			prevState[key] 		<- currentState[key];
			currentState[key]	<- currentState[key]-d_Int[key];
			d_Int[key]			<- 0.0;
		}	
		
		/* 
		// Se cambian las hojas de clases
		if length(leaf_proportion) > 0
		{
			do compute_leaf_aging();	
		}
		*/
		
		//LAI <- currentState["A_L"]*0.0146;
		LAI 				<- currentState["A_L"]*currentState["N_L"]*0.0146;
		leaf_proportion 	<- list_with(length(leaf_aging), 0.0);
		
	}
	
	
	action hourly_GROWTH(float temp, float co2, float par, float ppfd)
	{
		RC <- SUPPLY/DEMAND;
		
		if RC < 0
		{
			RC <- 0.0;
		}
		
		float xroot	<- 1.0 ;
		
		float dALp 	<- 0.0 ;

		
		// Functions
		float FC   <- F_C(co2);
		float r_l  <- r_L_T(temp);
		float r_f  <- r_F_T(temp);
		float f_n_t<- F_n_T(temp);
		float genr <- GENR(f_n_t,FC);
		float sla  <- SLA(temp,par,co2);
		
		
		// SUPPLY
		do compute_SUPPLY(co2, temp, ppfd, xroot);
		bool cyc <- #cycle=0 ? true : false;
		
		d_Int["N_L"]  +<- change_N_L(cyc, FC, r_l, genr);
		d_Int["N_f"]  +<- change_N_f(cyc, FC, r_f, genr, RC, PLSTN);
		d_Int["N_s"]  +<- change_N_s(cyc, FC, r_l, genr);			
		
		dALp 		  <- change_A_lp(f_n_t, FC);
		d_Int["A_L"]  +<- (dALp*RC);		
		
		
		// DEMAND
		//do compute_DEMAND(f_n_t, dALp, FC,sla);		
		int   n 		<- int(currentState["N_L"]);
		float sum_nodes <- dALp*n;	
					
		L_dem <- (1+FRPET)*(sum_nodes/sla);
	    S_dem <- L_dem*FRSTM*(currentState["N_s"]/currentState["N_L"]);
		F_dem <- currentState["N_f"]*POF[int(age_class)]*f_n_t*FC;
		
		DEMAND <- L_dem+S_dem+F_dem;
									
		
		// GROWTH
		//do compute_GROWTH(r_f, FC);
		float g_f <- F_dem*RC;							// EQ 20
		float g_l <- L_dem*RC;							// EQ 21
		float g_s <- S_dem*RC;							// EQ 22
		
		
		d_Int["W_f"] +<- (g_f+(r_f*FC*n_F*prevState["W_f"])-(r_f*FC*n_F*currentState["W_f"]));					// EQ 24
		d_Int["W_s"] +<- (g_s+(FC*prevState["W_s"])-(FC*currentState["W_s"]));
		d_Int["W_L"] +<- (g_l+(r_l*FC*n_L*prevState["W_L"])-(r_l*FC*n_L*currentState["W_L"]));
		
		
		if export 
		{
			int hour <- cycle mod 24;
			save data:[   cycle
						, hour
						, SUPPLY
						, DEMAND
						, RC
						, xroot
						, dALp
						, FC
						, r_l
						, r_f
						, f_n_t
						, genr
						, sla
						, sum_nodes
						, L_dem
						, S_dem
						, F_dem
						, g_f
						, g_s
						, g_l
						, d_Int["N_f"]
						, d_Int["N_s"]
						, d_Int["N_L"]
						, d_Int["W_f"]
						, d_Int["W_s"]
						, d_Int["W_L"]
						, d_Int["A_L"]
						, length(leaf_proportion)
						, leaf_proportion
			] to:"Hourly_tomgro.csv" type:csv rewrite:false;
		
		}
	}
	

	// Methods 
	action compute_SUPPLY(float co, float temp, float ppfd, float xroot)
	{
		// Photosynthesis	P_g			
		float L_max 		<- 0.5;
		float r_maintenance <- 0.0;
		float photosynthesis<- 0.0;
		
		// 																	// Eq 17
		L_max  <- tau*ppfd; 												
		
		// M_resp															// Eq 18
		float q_exp  <- Q_10^(0.1*(temp-2.0));
		float qty_s_l<- R_L*(currentState["W_L"]+currentState["W_s"]);
		float qty_f	 <- R_F*currentState["W_f"];
		r_maintenance <- q_exp*(qty_s_l+qty_f); 							
		
		if ppfd != 0
		{
			float a_photynthesis <- (D*L_max*PGRED(temp))/K;
			float ar_photo		 <- (1-m)*L_max;
			float b_photynthesis <- ar_photo+(Q_e*K*ppfd);
			float c_photynthesis <- ar_photo+(Q_e*K*ppfd*exp(-K*LAI));
			photosynthesis <- a_photynthesis*ln(b_photynthesis/c_photynthesis); 
		}
		else
		{
			photosynthesis <- 0.0;
		}
											// Eq 16
		
		// Compute supply													// Eq 19
		SUPPLY <- E*(photosynthesis-r_maintenance)*(1-P_root(xroot));
	}
	
	
	float change_N_L(bool flgCycle, float FC, float r_l, float genr)									// EQ 2
	{
		float chg 		 <- 0.0;
		float prev_value <- flgCycle ? (genr*PLM2)/(1+TPL) : r_l*FC*n_L*prevState["N_L"] ;
		float value 	 <- r_l*FC*n_L*currentState["N_L"];
		float pl_total   <- P_L_total();
		
		chg 			<- prev_value-value-pl_total;
		
		// leaf_aging proportion
		loop i from:0 to:length(leaf_proportion)-1 step:1
		{
			leaf_proportion[i] <- leaf_proportion[i]+(r_l*FC*n_L);
		}
		
		shadow_loss <- max([r_l*FC*n_L,shadow_loss]);
		
		
		if export 
		{
			int hour <- cycle mod 24;
			save data:[   cycle
						, hour
						, int(cycle/24)
						, r_l
						, FC
						, n_L
						, shadow_loss
						, prevState["N_L"]
						, currentState["N_L"]
						, prev_value
						, value
						, pl_total
						, chg
						, length(leaf_proportion)
						, sum(leaf_proportion)
						, leaf_proportion
			] to:"dn_L_tomgro.csv" type:csv rewrite:false;
		}
		
		
		return chg;
	}
	
	
	float change_N_f(bool flgCycle, float FC, float r_f, float genr, float r_c, float plstn)			// EQ 3
	{
		float chg <- 0.0;
		
		if flgCycle // First computing
		{
			float a_chg <- genr*PLM2*FPN(plstn)*r_c;	
			float b_chg <- r_f*FC*n_F*currentState["N_f"]-P_F(0.0);
			chg <- a_chg-b_chg;
		}	
		else
		{
			float a_chg <- r_f*FC*n_F*prevState["N_f"];
			float b_chg <- r_f*FC*n_F*currentState["N_f"];
			chg <- a_chg-b_chg-P_F(age_class);
		}	
		return chg;	
	}
	
	
	float change_N_s(bool flgCycle, float FC, float r_l, float genr)													// EQ 1
	{
		float chg <- 0.0;
		
		if flgCycle // First computing
		{
			float a_chg <- (genr*PLM2)/(1+TPL);	
			float b_chg <- r_l*FC*n_L*currentState["N_s"];
			chg <- a_chg-b_chg;
		}	
		else
		{
			float a_chg <- r_l*FC*n_L*prevState["N_s"];
			float b_chg <- r_l*FC*n_L*currentState["N_f"];
			chg <- a_chg-b_chg;
		}	
		return chg;	
	}
	
	
	// Daily integrated rate of node initiation per plant
	float GENR(float fnt, float FC)																									// EQ 4
	{
		return GENRAT*fnt*FC;
	}
	
	
	float F_C(float co2)																											// EQ 5
	{
		return 1+S_CO_2*(co2-350);
	}
	
		
	float change_A_lp(float fnt, float FC)																			// EQ 7
	{
		return currentState["N_L"]*POL[int(age_class)]*fnt*FC;
	}
	
	
	
	// SLA
	float SLA(float temp, float par, float co2)																						// EQ 8.1
	{
		float S_p <- S_mn+((S_mx-S_mn)*exp(-0.471*par));																			// EQ 9
		float S_T <- 1+(beta_T*(24-temp));																							// EQ 10
		float S_c <- 1+beta_c*(co2-350);																							// EQ 11
		
		return S_p/(S_T*S_c);
	}



	float l_demand(float dALp, float sla)																						// EQ 8
	{
		int   n 		<- int(currentState["N_L"]);
		float sum_nodes <- dALp*n;
		
		return (1+FRPET)*(sum_nodes/sla);
	}

	
	float s_demand(float l_dem)
	{
		return l_dem*FRSTM*(currentState["N_s"]/currentState["N_L"]);
	}

	
	float f_demand(float fnt, float FC)
	{
		return currentState["N_f"]*POF[int(age_class)]*fnt*FC;
	}

	
	action compute_DEMAND(float f_n_t, float dALp, float FC, float sla)																			// EQ 5
	{
		L_dem <- l_demand(dALp,sla);
	    S_dem <- s_demand(L_dem);
		F_dem <- f_demand(f_n_t, FC);
		

		DEMAND <- L_dem+S_dem+F_dem;
	}
	
	
	action compute_GROWTH(float r_f, float FC)
	{
		float g_f <- F_dem*RC;							// EQ 20
		float g_l <- L_dem*RC;							// EQ 21
		float g_s <- S_dem*RC;							// EQ 22
		
		
		d_Int["W_f"] +<- g_f+(r_f*FC*n_F*prevState["W_f"])-(r_f*FC*n_F*currentState["W_f"]);					// EQ 24
		d_Int["W_s"] +<- g_f+(r_f*FC*n_F*prevState["W_s"])-(r_f*FC*n_F*currentState["W_s"]);
		d_Int["W_L"] +<- g_f+(r_f*FC*n_F*prevState["W_L"])-(r_f*FC*n_F*currentState["W_L "]);
	}
	
}


experiment mi_experimento type:gui{

	
	output{
		display GUI type:opengl 
		{
			
			
		}
		
		display Statistics
		{
   			chart "N_L" type:series y_label:"N_L"  size: {0.5,0.5} position: {0.0, 0.0}
			{
				datalist plant value:(tomato_plant collect each.currentState["N_L"]) legend:(tomato_plant collect each.name) color:(tomato_plant collect #blue) marker:false;
				
			}
			
			chart "N_S" type:series y_label:"N_s"  size: {0.5,0.5} position: {0.5, 0.0}
			{
				datalist plant value:(tomato_plant collect each.currentState["N_s"]) legend:(tomato_plant collect each.name) color:(tomato_plant collect #blue) marker:false;
				
			}
			
			chart "N_F" type:series y_label:"N_f"  size: {0.5,0.5} position: {0.0, 0.5}
			{
				datalist plant value:(tomato_plant collect each.currentState["N_f"]) legend:(tomato_plant collect each.name) color:(tomato_plant collect #blue) marker:false;
				
			}
			
			chart "LAI" type:series y_label:""  size: {0.5,0.5} position: {0.5, 0.5}
			{
				datalist plant value:(tomato_plant collect each.LAI) legend:(tomato_plant collect each.name) color:(tomato_plant collect #blue) marker:false;
				
			}
		}
	}
	
}



