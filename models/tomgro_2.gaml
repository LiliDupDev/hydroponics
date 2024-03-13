/**II]
* Name: tomgro2
* Based on the internal empty template. 
* Author: lin_2
* Tags: 
*/


model tomgro2

import "constants.gaml"


global
{
	
	bool export 		<- true;
	
	
	
	
	init
	{
		step <- 1#hour;
		//day_changes 			<- matrix(csv_file("../includes/day_changes.csv", true));
		
		
	//map<string,float>   stage_sensitivity 	;//<- ["stageI"::0.0552,"stageII"::0.6721,"stageIII"::0.8176]; // alphas in Minhas model
	//map<string,float>	optimal_irrigation	;
	//map<string,int>    	stage_duration 		;//<- ["stageI"::20,"stageII"::40,"stageIII"::60]; 			// the integers represent the number of days in that stage
	//list<string>		stages				;//<- ["stageI","stageII","stageIII"];
	//int					STAGE				;
	//map<string,float>	yield_water_by_stage;//<- ["stageI"::0.0,"stageII"::0.0,"stageIII"::0.0];
	
	
	loop i from: 1 to: stages_data.rows step:1 {
		write "row ("+i+") ---> "+stages_data[0,i];
		}
	
		
		create tomato_plant number:1;
	}
	
	
	reflex daily when:every(24#hours)
	{
		int day <- cycle/24;
		
		ask tomato_plant
		{
			//do main_cycle(ET_ai, ET_cki);
		}
		
		// TODO: Variables to use in Minhas model
		/* 
		
		query et_ai --> et_a[{1,day}]
		query et_ai --> et_ck[{1,day}]
		*/
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
			do fast_cycle(temperature, CO2, PAR);//hourly_GROWTH(temperature,CO2,PAR,PPFD);
		}
	}
	
	reflex stop when:cycle=1920 // 80 days
	{
		int day <- cycle/24;
		ask tomato_plant
		{
			//do minhas_computation(ET_cki);
		}
		do pause;
	}
	
}


species tomato_plant
{
	
	
	/* ******************************  GENERAL  ******************************** */
	float PLTM2V		<- 5.0;//22.0		;   // Plant density in Gainesville experiment 1985
	// Setting variable accumulates through a day
	int   TIME			<- 0	;				// Days
	float GP 		    <- 0.0 	;				// Gross photosynthesis
	float MAINT 	    <- 0.0 	;				// Maintenance respiration
	float GENR		    <- 0.0 	;				// Daily integrated rate of node initiation per plant
	float TEMFAC	    <- 0.0 	;				// Correction factor for apex initiation rate, potential leaf expansion rate and potential fruit growth rate as a function of temperature
	float RDVLV		    <- 0.0 	;               // Integrated effect of temperature and C02 level on leaf development rate
	float RDVFR		    <- 0.0 	;               // Instantaneous effect of temperature and C02 level on leaf development rate
	float FCO2D		    <- 0.0 	;               // Daily relative increase in development rate at CO2 levels exceeding 350
	float PMAX			<- 0.0  ;				// Light-saturated leaf photosynthetic rate
	float TPLA 			<- 0.0  ; 				// Number of trusses per node Initially zero, after initiation of the first truss equal to TPL
	float ESLA			<- 0.0  ;				// SLA as determined by environmental conditions (C02, PAR and temperature)
	float TRCDWR		<- 0.0  ;				// Total rate of dry matter accumulation, including roots and shoots
	float RCDRW			<- 0.0  ;				// Rate of change in aboveground dry matter
	float FRPT			<- 0.0  ;				// Actual fraction of petiole weight
	float FRST			<- 0.0  ;				// Fraction stem in total dry matter demand, defined in FRSTEM as function of leaf age class
	float PUSHL			<- 0.0	;				// Auxiliary variable, governing transition between leaf age classes
	float PUSHM			<- 0.0	;				// Auxiliary variable, governing transition between fruit age classes
	float CPOOL			<- 0.0  ;				// Pool of carbohydrates for daily growth (gross assimilation minus total respiration)
	float TOTDW         <- 0.0  ;				// Total aboveground dry weight
	float TOTVW         <- 0.0  ;               // Total dry weight of aboveground vegetative plant parts
	float ATT           <- 0.0  ;               // Total number of leaf and fruit growing points
	float TOTNU         <- 0.0  ;               // Total number of growing points including leaves, fruit and stems
	float NGP			<- 0.0  ;
	
	float GPF 			<- 0.0	;				// Instantaneous rate of gross photosynthesis
	float MAINTF 		<- 0.0	;				// Instantaneous maintenance respiration rate
	float GENRF 		<- 0.0 	;				// Instantaneous rate of node initiation per plant, function of temperature, C02 level and genetic properties
	float TEMFCF 		<- 0.0	;				// Factor accounting for the instantaneous effect of temperature on apex initiation rate, potential leaf expansion rate and potential fruit growth rate
	float RDVLVF 		<- 0.0	;				// Instantaneous effect of temperature and C02 level on leaf development rate
	float RDVFRF 		<- 0.0	;				// Instantaneous effect of temperature and C02 level on fruit development rate
	float TTHF 			<- 0.0  ; 				// Positive deviation of average temperature from upper threshold for unrestricted fruit set
	float TTLF 			<- 0.0  ; 				// Negative deviation of average temperature from lower threshold (TLOW) for truss splitting
	float TTABF 		<- 0.0 	;				// Negative deviation of average temperature from lower threshold for fruit abortion
	float FCO2			<- 0.0	;	
	float TSLAF 		<- 0.0	;				// Factor accounting for instantaneous effect of temperature on SLA
	float CSLAF 		<- 0.0  ;				// Partial instantaneous effect of C02 level on SLA
	float PLSTN			<- 0.0	;				// Plastochron index
	float AEF			<- 0.0	;				// Age effect on PMAX
	
	
	
	
	// Setting variables for SLA
	float NCSLA		    <- 0.0 	;               // Counter for number of periods with radiation level (PAR) above 0.1, used in calculation of effect of C02 on SLA
	float TSLA		    <- 0.0	;               // Factor accounting for instantaneous effect of temperature on SLA
	float CSLA		    <- 0.0	;               // Integrated daily effect of C02 level on SLA
			
	// Setting variables for temperature effect on fruit
	float TTH 		   <- 0.0	;               // Daily integrated thermal time above threshold temperature (THIGH) for fruit abortion
	float TTL		   <- 0.0	;               // Daily integrated thermal time below threshold temperature (TLOW) for truss splitting
	float TTAB		   <- 0.0	;               // Integrated thermal time below threshold temperature (TLOWAB) for fruit abortion
	
	
	/* *******************************  LEAVES  ******************************* */ 
	float 		CLSDML	<- 0.0;						// Proportion of leaf sink demand that is satisfied		
	float 		XLAI	<- 0.0;						// 	Total LAI, summation of all LFAR age classes		
	float 		PTNLVS	<- 0.0;						// Total potential sink capacity of all leaf age classes	
	float		XSLA	<- 0.0;			 			// Average specific leaf area		
	float		ASTOTL	<- 0.0;						// LAI of 'growing leaves' (XLAI), excluding leaves in the last age class / Area of stil growing leaves / LAI growing leaves	
	list<float> LFAR	;							// Leaf area index per age class	
	list<float>	PNLVS	;							// Potential sink capacity per leaf age class		
	//list<float> POL_L	;							// Potential leaf area expansion rate [1,NL]	
	
	// rates
	float 		RCNL 	<- 0.0;						// Rate of leaf appearance
	
	list<float>	DENLR	;							// Rate of loss of leaf number per age class due to prunning			
	list<float>	RCLFA	;							// Potential rate of leaf area expansion per leaf age class					
	list<float>	DEWLR	;							// Total death rate of leaf weight per age class			
	list<float> DELAR	;							// Death rate of leaf area per age class				
	list<float>	RCWLV	;							// Rate of leaf growth per age class	
		
			
	// 	weight
	float 		ATV		<- 0.0;						// Total dry matter production of g m-2 aboveground vegetative plant parts (including dead leaves)			
	float		ATL		<- 0.0;						// Accumulated weight of dead leaves			
			
	float		TOTDML	<- 0.0;						// Total rate of dry matter accumulation in leaves	
	float 		TWTLAI	<- 0.0;						// Total dry weight of leaf blades plus petioles	
	float 		TOTWML	<- 0.0;						// Total dry weight of leaves in the field	
	float		WSTOTL	<- 0.0;						// Total dry weight of growing leaves			

	list<float>	AVWL 	;							// Average weight per leaf in leaf class			
	list<float> WLVS	;							// Dry weight of leaves per age class	
	
	//  number
	list<float>	LVSN	;							// Number of leaves per age class		
	list<float> DEAR	;							// Fraction of leaf loss per age class due to disease or pruning			
	//list<float> DIS_L	;							// Fraction of leaf death per age class due to disease or pruning (1-NL)			
	
	float		TOTGL	<- 0.0;						// Total number of growing leaves		
	float		TOTNLV	<- 0.0;						// Total number of leaves in the field (summation of LVSN(1-NL))	
	float		BTOTNLV	<- 0.0;						// Total number of leaves initiated		
	float		DLN		<- 0.0;						// Cumulative number of dead leaves					
	
	
	
	/* *******************************  FRUIT  ******************************* */ 
	float 		PTNFRT	<- 0.0;						// Total potential sink capacity of all fruit age classes		
	float		CLSDMF	<- 0.0;						// Proportion of fruit sink demand that is satisfied		
	float		FABOR	<- 0.0;						// Fraction of fruit aborted in first fruit age class			
	list<float>	PNFRT	;							// Potential sink capacity per fruit age class			
	//list<float>	POF_F	;							// Relative potential sink capacity per fruit age class			
	
	//  ratios
	float 		RVRW 	<- 0.0;						// Ratio of total fruit weight to total leaf weight			
	float 		RTRW 	<- 0.0;						// Ratio of fruit dry weight to total plant dry weight			
	float 		RVRN 	<- 0.0;						// Ratio of total fruit number to total leaf number			
	float 		RTRN 	<- 0.0;						// Ratio of total number of fruits to total number of apices			
	
	//	rates
	float 		RCNF	<- 0.0;						// Rate of fruit appearance	
	float		ABNF 	<- 0.0;						// Fruit abortion rate			
	list<float>	RCWFR	;							// Rate of fruit growth per age class			
	list<float> DENFR	;							// Rate of loss of fruit number per age class due to pruning
	list<float> DEWFR	; 							// Total death rate of fruit weight per age class			
	list<float> DEAF	;

	//	weight
	float 		TOTDMF	<- 0.0;						// Total rate of dry matter accumulation in fruits			
	float		WTOTF	<- 0.0;						// Total dry weight of growing fruits			
	float		FWFR10	<- 0.0;						// Fresh weight of harvested fruits			
	float		APFFW	<- 0.0;						// Average fresh weight of picked fruits	
 	float		TOTWMF	<- 0.0; 					// Total dry weight of fruits in the field			
	float		AVWMF	<- 0.0;						// Average weight per fruit in fruit class NF			
	float		AVWML	<- 0.0;						// Average weight per leaf in leaf class NL			
	float		DMCF84	<- 0.0;						// Fraction dry matter in fruits picked on a given day, obtained from DMC84T				
	list<float>	AVWF	;							// Average weight per fruit in fruit class		
	list<float>	WFRT	;							// Dry weight of fruits per age class	
		
			
	//	number
	float		TOTNF	<- 0.0;						// Total number of fruits in the field (summation of FRTN(1-NF))	
	float		TOTGF	<- 0.0;						// Total number or growing fruits			
	
	list<float> FRTN	;							// Number of fruits per fruit age class			
	
	
	// Fresh weight variables
	list<float> 		FWFRT	;				    // Fresh weigth per age class
	list<float> 		FAVWF	;				    // Average fresh weight per fruit in fruit class
	list<float>			FAVFM	;				    // Average fresh weight per mature fruit
	list<float> 		FAVWMF	;				    // Average fresh weight per fruit in fruit class NF			
	float				FWTOTF		<- 0.0 ;	    // Total fresh weight of growing fruits			
	float 				FTOTWMF		<- 0.0 ;	    // Total fresh weight of fruits in the field			
	float 				FWPFI		<- 0.0 ;	    // Initial weight per initiated fruit			
	float				FRESHCONV	<- 0.06;	    // Fresh weight conversion factor. The dry weight divided by this quantity results in the fresh weight.
	float				alpha_Minhas<- 0.0 ;	    // Sensitivity coefficient Minhas model
	map<string,float>	yield_water_stage; 		    // Save the value by each stage
	float				ET_a_acc	<-	0.0	;	    // This variable accumulates the daily measure of ET_a to compute an average at the end of the stage
	float 				YIELD_WATER	<-  1.0 ;	    // Yield Water proportion
	float				FWHVST		<-  0.0	;		// Harvest fresh weight
	
	/* *******************************  STEM  ******************************* */ 
	// rates
	float 		RCST 	<- 0.0;						// Rate of stem node appearance
	float 		TOTDMS	<- 0.0;						// Total rate of dry matter accumulation in stems
	float 		PTNSTM	<- 0.0;						// Total potential sink capacity of stem			
	list<float> RCWST	;							// Rate of stem growth per age class
	list<float> PNTSM	;							// Potential sink capacity of stem per age class			
	
	// 	weight
	list<float> WSTM	;							// Dry weight of stems per age class
	float		TOTWST	<- 0.0;						// Total dry weight of main stems in the field		
	float 		WSTOTS 	<- 0.0; 					// Total dry weight of growing stems			

	//  number
	list<float> STMS	;							// stem internode
	float		TOTNST	<- 0.0;						// Total number of main stems in the field (summation of STMS (1-NL))	
	float 		TOTST 	<- 0.0;						// Total number of growing main stems			
			
	
	init
	{
		STMS	 <- list_with(n_L,0.0);
		RCWST    <- list_with(n_L,0.0);
		PNTSM    <- list_with(n_L,0.0);
		WSTM     <- list_with(n_L,0.0);
		
		LVSN     <- list_with(n_L,0.0);
		DEAR     <- list_with(n_L,0.0);
		AVWL     <- list_with(n_L,0.0);
		WLVS     <- list_with(n_L,0.0);
		LFAR     <- list_with(n_L,0.0);
		RCLFA    <- list_with(n_L,0.0);
		DEWLR    <- list_with(n_L,0.0);
		DELAR    <- list_with(n_L,0.0);
		RCWLV    <- list_with(n_L,0.0);
		PNLVS	 <- list_with(n_L,0.0);
		DENLR	 <- list_with(n_L,0.0);
		
		FRTN     <- list_with(n_F,0.0);
		WFRT     <- list_with(n_F,0.0);
		AVWF     <- list_with(n_F,0.0);
		RCWFR    <- list_with(n_F,0.0);
		DENFR    <- list_with(n_F,0.0);
		DEWFR    <- list_with(n_F,0.0);
		PNFRT    <- list_with(n_F,0.0);
		DEAF	 <- list_with(n_F,0.0);
		
		FWFRT 	<-  list_with(n_F,0.0);
		FAVWF 	<-  list_with(n_F,0.0);
		FAVFM 	<-  list_with(n_F,0.0);
		FAVWMF 	<-  list_with(n_F,0.0);
		FWTOTF	<- 	0.0;
		FTOTWMF	<- 	0.0;
		FWPFI	<- 	0.0;
		
		
		PLSTN	<- PLSTNI;
		CPOOL	<- 0.0;
		LVSN[0]	<- LVSNI*PLM2;
		//LVSN[1] <- LVSNI*PLM2;
		BTOTNLV	<- LVSNI*PLM2;
		STMS[0]	<- 1;
		WLVS[0]	<- WLVSI*PLM2;
		LFAR[0]	<- LFARI*PLM2;
		XLAI	<- LFAR[0];
		TOTWML	<- 0.0;
		ATL		<- 0.0;
		ATV		<- 0.0;
		TOTWST	<- WLVS[0];
		WTOTF	<- 0.0;
		ASTOTL	<- XLAI;
		WSTOTL	<- LVSN[0];
		FWFR10	<- 0.0;
		APFFW	<- 0.0;
		ATT		<- WLVS[0]+LVSN[0];
		TIME 	<- int(cycle / 24);
		
		yield_water_stage	<- copy(yield_water_by_stage);
		STAGE	<- 0;
		alpha_Minhas<- stage_sensitivity[stages[STAGE]];
		
		
		
		
		CLSDML <-  1.0;
		TEMFAC <- 20.0;
		TEMFCF <- 0.86;
		PTNLVS <- 0.0005;
		GP 	   <- 34.0;
		MAINT  <- 0.005;
		
		
		
		//do save_var("TOTWST",0,TOTWST);
		//do save_var("ASTOTL",0,ASTOTL);
		//do save_var("XLAI",0,XLAI);
		//do save_array("LFAR",0);
		//do save_array("LVSN",0);
		//do save_array("DENLR",0);
		//do save_array("PNLVS",0);
		//do save_array("RCLFA",0);
		//do save_array("RCWLV",0);
		//do save_array("WLVS",0);
		//do save_array("STMS",0);
		//do save_array("WSTM",0);
		//do save_array("WFRT",0);
	}
	
	
	// Update variables PLTM2V
	action update_density
	{
		loop index over: M_PLTM2V.keys
		{
			if TIME > index
			{
				PLTM2V <- M_PLTM2V[index];
				break;
			}
		}
	}

	action restart_vars
	{
		// Setting variable accumulates through a day
		GP 		<- 0.0 	;
		MAINT 	<- 0.0 	;
		GENR	<- 0.0 	;
		TEMFAC	<- 0.0 	;
		RDVLV	<- 0.0 	;
		RDVFR	<- 0.0 	;
		FCO2D	<- 0.0 	;
		
		// Setting variables for SLA
		NCSLA	<- 0.0 	;
		TSLA	<- 0.0	;
		CSLA	<- 0.0	;
		
		// Setting variables for temperature effect on fruit
		TTH 	<- 0.0	; 
		TTL		<- 0.0	;
		TTAB	<- 0.0	;
	}
	
	
	action main_cycle(float ET_a, float ET_ck)
	{
		TIME <- int(cycle / 24);
		write "Main ----------------------> Day: "+TIME+" Cycle: "+cycle;

		
		//if (TIME > stage_duration[stages[STAGE]]) and (STAGE < length(stages)-1) // This condition controls the duration of the stage
		//{
		//	STAGE <- STAGE+1;
		//}
		
		do accumulate_minhas_model(ET_a, ET_ck);
		
		alpha_Minhas	<- stage_sensitivity[stages[STAGE]];
		

		
		
		float PAR <- 20.1;
		
		if NCSLA = 0
		{
			CSLA <- 1.0 ;
		}
		else
		{
			CSLA <- CSLA/NCSLA;
		}
		
		TSLA <- max([TSLA,0.1]);
		
		//if cycle != 0
		//{
			// DMRATE	--> Calculation of dry matter partitioning and accumulation in each age class of each component
			do DMRATE(PAR);
			// DEVRAT	--> Calculation of rates of appearence of nodes, leaves and fruits and rates of material flow between age classes
			do DEVRAT;
			// LOSRATE	--> Calculation of death rates of leaves from each age class
			do LOSRATE;
			// INGRAT	--> Integration routine for LAI, dry matter content and numbers for each component of the plant (leaves, fruits and stem) 
			do INGRAT;
		//}
		/* Re - star */
		do update_density;
		
		if cycle != 0 
		{
			do restart_vars;
		}
	}
	
	
	action fast_cycle(float temp, float co2, float ppfd)
	{
		// We don´t have an equivalent to GHOUSE, we gave the parameters
		// DEVFAST 	--> Calculation of daily development rates of leaves, fruits and stems
		do DEVFAST(temp,ppfd,co2);
		// PHOTO 	--> Calculation of photosynthesis rates, using Acock's equation at each time interval of the fast time loop
		do PHOTO(temp,ppfd,co2);
		// RESP		--> Calculation of maintenance respiratioon from leaf weights, stem weights, Q10 values and temperature
		do RESP(temp);
		
		
		float GPFN	<- (GPF-MAINTF)*GREF;
		
		// INTEGRATION
		int DTFAST 	<- (cycle mod 24)+1;
		GENR		<- GENR  + GENRF  ;//* DTFAST ;
		TEMFAC 		<- TEMFAC+ TEMFCF ;//* DTFAST ;
		RDVLV		<- RDVLV + RDVLVF ;//* DTFAST ;
		RDVFR		<- RDVFR + RDVFRF ;//* DTFAST ;
		TTH 		<- TTH   + TTHF   ;//* DTFAST ;
		TTL			<- TTL   + TTLF   ;//* DTFAST ;
		TTAB		<- TTAB  + TTABF  ;//* DTFAST ;
		FCO2D 		<- FCO2D + FCO2   ;//* DTFAST ;
		TSLA 		<- TSLA  + TSLAF  ;//* DTFAST ;
		CSLA 		<- CSLA  + CSLAF  ;//         ;
		GP			<- GP    + GPF    ;//* DTFAST ;
		MAINT		<- MAINT + MAINTF ;//* DTFAST ;
	
			
		save data:[   cycle
					, DTFAST
					, GENR	   
					, TEMFAC 	
					, RDVLV	  
					, RDVFR	  
					, TTH 	   
					, TTL		   
					, TTAB	   
					, FCO2D 	 
					, TSLA 	  
				    , CSLA 	  
				    , GP		    
				    , MAINT	  
				    , GPFN
		] to:"output/ACCUM.csv" type:csv rewrite:false;
		
		save data:[   cycle
					, DTFAST
					, GENRF    
					, TEMFCF 	
					, RDVLVF  
					, RDVFRF  
					, TTHF     
					, TTLF  	   
					, TTABF    
					, FCO2  	 
					, TSLAF   
				    , CSLAF   
				    , GPF   	    
				    , MAINTF  
		] to:"output/ACCUM_F.csv" type:csv rewrite:false;
	}
	
	// Computing Minhas water-yield model
	action accumulate_minhas_model(float ET_ai,float ET_cki)
	{
		if (TIME > stage_duration[stages[STAGE]]) and (STAGE < length(stages)-1)
		{
			float avg_ET_a <- ET_a_acc/stage_duration[stages[STAGE]];  // Average for grow stage
			
			// Computing yield water for this stage
			float ratio 		<- avg_ET_a/ET_cki;
			float yield_water 	<- (1-ratio)^2;
			float yield_water_s <- (1-yield_water)^alpha_Minhas;
			
			yield_water_stage[stages[STAGE]] <- yield_water_s;
			
			save data:[ cycle
					,	0
					,	ET_a_acc
					,	stages[STAGE]
					, 	stage_duration[stages[STAGE]]
					,	avg_ET_a
					, 	ratio
					,	yield_water
					,	yield_water_s
					,	yield_water_stage[stages[0]]
					,	yield_water_stage[stages[1]]
					,	yield_water_stage[stages[2]]
			] to:"STAGE_COMP.csv" type:csv rewrite:false;
			
			STAGE 	 <- STAGE+1;
			ET_a_acc <- 0.0;
			
		}
		else
		{
			// Accumulate
			ET_a_acc <- ET_a_acc+ET_ai;
			do save_var("ET_a_acc",1,ET_a_acc);
		}
		
	}
	
	
	// Minhas computation
	action minhas_computation(float ET_cki)
	{
		int days_on_stage	<- TIME-stage_duration[stages[STAGE-1]];
		float avg_ET_a <- ET_a_acc/days_on_stage;  // Average for grow stage
			
		// Computing yield water for this stage
		float ratio 		<- avg_ET_a/ET_cki;
		float yield_water 	<- (1-ratio)^2;
		float yield_water_s <- (1-yield_water)^alpha_Minhas;
			
		yield_water_stage[stages[STAGE]] <- yield_water_s;
			
		save data:[ 	cycle
					,	days_on_stage
					,	ET_a_acc
					,	stages[STAGE]
					, 	stage_duration[stages[STAGE]]
					,	avg_ET_a
					, 	ratio
					,	yield_water
					,	yield_water_s
					,	yield_water_stage[stages[0]]
					,	yield_water_stage[stages[1]]
					,	yield_water_stage[stages[2]]
		] to:"STAGE_COMP.csv" type:csv rewrite:false;
		
		
		// Computing Minhas model definitive:
		// TODO: Add loop to compute the product 
		loop val over:yield_water_stage{
			YIELD_WATER <- YIELD_WATER * val;
		} 
		
		do save_var("YIELD_WATER",1,YIELD_WATER);
	}
	
	
	// Calculation of daily development rates of leaves, fruits and stems
	action DEVFAST(float TMPA, float PPFD, float CO2AVG)
	{
		TSLAF 	<- 1.0 + 0.045 * (24.0 - TMPA) ;
		CSLAF 	<- 0.0 ;
		FCO2	<- 1.0 ;
		
		if PPFD >= 0.1
		{
			NCSLA <- NCSLA + 1.0;
			CSLAF <- 1.5 + CO2M * (CO2AVG-350.0)/(950.0-350.0);
			FCO2  <- 1.0 + SCO2 * (CO2AVG-350.0)*min([1.0,20.0/PLSTN]);
			//do save_var("PLSTN",1,PLSTN);
			//do save_var("CO2AVG",1,CO2AVG);
			//do save_var("SCO2",1,SCO2);
			//do save_var("FCO2",1,FCO2);
		}
		
		//do save_var("FCO2",2,FCO2);
		TEMFCF 	<- TABEX(GENTEM,XTEM,TMPA,6);										// Compute plastochron development rate, GENRF
		//do save_var("TEMFCF",1,TEMFCF);
		float tabex_genrf <- TABEX(GENRAT,XGEN,PLSTN,6);
		
		GENRF	<- min(max(EPS,CLSDML)/GENFAC,1)*TEMFCF*tabex_genrf;	
		//GENRF <- TEMFCF*GENFAC*CLSDML*tabex_genrf;
		
		//do save_var("CLSDML_2",1,CLSDML);
		//do save_var("GENFAC",1,GENFAC);
		//do save_var("GENRF",2,GENRF);
		
		float age_leaf <- TABEX(RDVLVT,XLV,TMPA,9);
		RDVLVF	<- age_leaf*SPTEL*FCO2;								// Compute leaf aging
		//do save_var("RDVLVF",1,RDVLVF);
		
		RDVFRF	<- TABEX(RDVFRT,XFRT,TMPA,9)*SPTEL*FCO2;							// Compute fruit aging

		// Compute instantaneous eefect of temperature fruit set
		TTHF <- 0.0 ;
		TTLF <- 0.0 ;
		TTABF<- 0.0 ;
		
		if TMPA > THIGH { TTHF <- TMPA-THIGH; }
		if TMPA < TLOW	{ TTLF <- TLOW-TMPA; }
		if TMPA < TLOWAB{ TTABF <- TLOWAB-TMPA; }
	}
	
	// Calculation of photosynthesis rates, using Acock's equation at each time interval of the fast time loop
	action PHOTO(float TMPA, float PPFD, float CO2AVG)
	{
		float TAU1 <- 0.06638*TU1; //  1.46036
		float TAU2 <- 0.06638*TU2; //  2.3233
		
		PMAX <- TAU1 * CO2AVG;
		
		if CO2AVG > 350
		{
			PMAX <- TAU1*350.0+TAU2*(CO2AVG-350.0);
			//do save_var("PMAX",2,PMAX);
		}
		
		AEF	<- TABEX(AEFT,XAEFT,PLSTN,6);
		
		// PMAX no cambia porque no cambia el nivel de co2 --> PMAX no es problema		
		PMAX<- PMAX *  TABEX(PGRED,TMPG,TMPA,8) *AEF;
		
		//do save_var("PMAX",3,PMAX);
		
		if PPFD >= 0.001
		{
			
			float TOP <- (1.0-XM)*PMAX + QE*XK*PPFD;
			float BOT <- (1.0-XM)*PMAX + QE*XK*PPFD*exp(-XK*ASTOTL*PLTM2V); 

			GPF	<- (PMAX/XK)*ln(TOP/BOT);
			//GPF <- GPF * 0.682;
			//GPF <- GPF * 3.8016;
			float GPF_1 <- GPF * 0.682;
			float GPF_2 <- GPF_1 * 3.8016;
			
			
			//save data:[ cycle
			//		,	XM
			//		, 	PMAX
			//		, 	QE
			//		,	XK
			//		, 	PPFD
			//		,	TMPA
			//		,	CO2AVG
			//		,	ASTOTL
			//		,	PLTM2V
			//		,	TOP
			//		,	BOT 
			//		,	GPF
			//		,	GPF_1
			//		,	GPF_2
			//] to:"output/PHOTO.csv" type:csv rewrite:false;
			
			GPF <- GPF_2;
			
		}
		
	}
	
	// Calculation of maintenance respiratioon from leaf weights, stem weights, Q10 values and temperature
	action RESP(float TMPA)
	{
		float TEFF <- Q10^(0.1*TMPA-2.0);
		
		MAINTF <- TEFF*(RMRL*(TOTWST+WSTOTL)+RMRF*WTOTF);
	}
	
	// Calculation of dry matter partitioning and accumulation in each age class of each component
	action DMRATE(float PAR)
	{
		float PARSLA <- 1-TABEX(PART,XPART,PAR,5); //COMPUTE SPECIFIC LEAF AREA GROWTH FACTOR BASED ON DAILY PAR
		//do save_var("PARSLA",1,PARSLA);
		
		ESLA <- STDSLA*PARSLA/(TSLA*CSLA);
		//do save_var("STDSLA",1,ESLA);
		//do save_var("TSLA",1,TSLA);
		//do save_var("CSLA",1,CSLA);
		//do save_var("ESLA",1,ESLA);
		ESLA <- max([0.018,ESLA]);
		//do save_var("ESLA",2,ESLA);
		ESLA <- min([SLAMX,ESLA]);
		//do save_var("ESLA",3,ESLA);
		
		//write "ESLA: "+ESLA;
		float TRCDRW <- (GP/PLTM2V-MAINT)*GREF;
		TRCDRW <- max([TRCDRW,0.0]);
		
		//do save_var("GP",1,GP);
		//do save_var("GREF",1,GREF);
		//do save_var("MAINT",1,MAINT);
		//do save_var("PLTM2V",1,PLTM2V);
		//do save_var("TRCDRW",1,TRCDRW);
		
		float T_trcdrm <- TABEX(PROOT,XROOT,PLSTN,6); 
		RCDRW  <- TRCDRW*(1.0-T_trcdrm)*min([max([EPS,CLSDML])/ZBENG,1.0])*TEMFAC; 
		//do save_var("T_trcdrm",1,T_trcdrm);
		//do save_var("PLSTN",2,PLSTN);
		//do save_var("RCDRW",1,RCDRW);

		PTNLVS <- 0.0 ;
		PTNSTM <- 0.0 ;
		float XBOX <- 0.0;
		
		
		// COMPUTE SINK STRENGTH OF LEAVES, FRUIT WLVS(I) INCLUDES WT OF PETIOLES AND STEM, LFAR(I) INCLUDES AREA ONLY
		loop i from:0 to:n_L-1 step:1
		{
			XBOX 	<- i*100.0/n_L;
			float tab <- TABEX(POL,BOX,XBOX,10);
			RCLFA[i]<- LVSN[i]*tab*TEMFAC*FCO2D;
			
			save data:[ cycle
					, 	i
					,	LVSN[i]
					,	tab
					,	TEMFAC
					,	FCO2D
					,	RCLFA[i]
			] to:"output/RCLFA_CH.csv" type:csv rewrite:false;
			
			
			FRPT 	<- TABEX(FRPET,BOX,XBOX,10);
			FRST 	<- TABEX(FRSTEM,BOX,XBOX,10);
			PNLVS[i]<- (RCLFA[i]/TABEX(ASLA,BOX,XBOX,10)*ESLA)*(1.0+FRPT);
			PTNLVS  <- PTNLVS+PNLVS[i];
			PNTSM[i]<- PNLVS[i]/(LVSN[i]+EPS)*FRST*STMS[i];
			PTNSTM 	<- PTNSTM+PNTSM[i];
		}
		
		//do save_array("PNLVS",1);
		//do save_array("RCLFA",1);
		
		
		float ZZX <- 0.0;
		loop i from:0 to:n_F-1 step:1
		{
			ZZX 	<- min([1.0,max([EPS,2.0-AVWF[i]/AVFM])]);
			XBOX	<- i*100.0/n_F;
			PNFRT[i]<- FRTN[i]+TABEX(POF,BOX,XBOX,10)*TEMFAC*FCO2D*ZZX;
			PTNFRT 	<- PTNFRT+PNFRT[i];
		}
		float PNGP	<- PTNLVS+PTNFRT+PTNSTM;
		//do save_var("PNGP",1,PNGP);
		TOTDML		<- min([RCDRW*PTNLVS/(PNGP+EPS),PTNLVS]);//min([RCDRW*PTNLVS/(PNGP+EPS),PTNLVS]);
		TOTDMS		<- min([RCDRW*PTNSTM/(PNGP+EPS),PTNSTM]);
		TOTDMF		<- min([RCDRW*PTNFRT/(PNGP+EPS),PTNFRT]);
		float TOPGR	<- TOTDMF+TOTDML+TOTDMS;
		float EXCESS<- RCDRW-TOPGR;
		
		CLSDMF		<- 1.0;
		if PTNFRT > 0.0
		{
			CLSDMF <- TOTDMF/(PTNFRT+EPS);
		}
		CLSDML <- TOTDML/(PTNLVS+EPS);
		//do save_var("CLSDML",1,CLSDML);
		//do save_var("TOTDML",1,TOTDML);
		//do save_var("PTNLVS",1,PTNLVS);
		
		// COMPUTE COHORT GROWTH RATES
		
		loop i from:0 to:n_L-1 step:1
		{
			RCWLV[i]	<- TOTDML*PNLVS[i]/(PTNLVS+EPS);
			RCWST[i]	<- TOTDMS*PNTSM[i]/(PTNSTM+EPS);
			
			// NOW ADJUST LEAF AREA EXPANSION TO AVAILABLE CH20
			XBOX		<- i*100.0/n_L;
			FRPT		<- TABEX(FRPET,BOX,XBOX,10);
			RCLFA[i]	<- RCWLV[i]*TABEX(ASLA,BOX,XBOX,10)*ESLA/(1+FRPT);
		}
		
		//do save_array("RCLFA",2);
		//do save_array("RCWLV",1);
		
		loop i from:0 to:n_F-1 step:1
		{
			RCWFR[i] <- TOTDMF*PNFRT[i]/(PTNFRT+EPS);
		}
		//// Save totals in CSV
		//save data:[   cycle
		//			, cycle mod 24
		//			, TRCDRW    
		//			, RCDRW 	
		//			, PTNLVS
		//			, PTNFRT
		//			, TOTDML
		//			, TOTDMF
		//			, CLSDMF
		//			, CLSDML  
		//			, TOPGR
		//			, PNGP
		//			, EXCESS
		//] to:"TOTALS.csv" type:csv rewrite:false;
		
		
	}
	
	// Calculation of rates of appearance of nodes, leaves and fruits and rates of material flow between age classes
	action DEVRAT
	{
		TPLA <- 0.0 ;
		if PLSTN >= FTRUSN
		{
			TPLA <- TPL;
			//do save_var("TPLA",1,TPLA);
		}
		RCNL <- PLM2*GENR/(1+TPLA);
		
		//do save_var("TPLA",2,TPLA);
		//do save_var("GENR",1,GENR);
		//do save_var("PLM2",1,PLM2);
		//do save_var("RCNL",1,RCNL);
		
		RCST <- PLM2*GENR;
		RCNF <- GENR*TABEX(FPN,XFPN,PLSTN-FRLG,10)*PLM2;
		RCNF <- RCNF*max(1.0-TTH/TTMX,0.0)*max([1.0+TTL/TTMN,0.0]);
		PUSHL<- RDVLV;//*n_L;
		//do save_var("PUSHL",1,PUSHL);
		PUSHM<- RDVFR;//*n_F;
	}
	
	// Calculation of death rates of leaves and the associated loss of dry matter, LAI, and numbers of leaves from each age class
	action LOSRATE
	{
		float XBOX <- 0.0;
		ABNF <- 0.0;
		float TABOR <- 0.0;
		float DATEZ <- 0.0;
		if TOTDMF >= EPS
		{
			FABOR <- min([1.0, (2.0-ABORMX*CLSDML)]);
			FABOR <- max([0.0,FABOR]);
			TABOR <- min([1.0,max([0.0,TTAB/TABK])]);
			ABNF  <- FABOR*RCNF/PLTM2V+TABOR*RCNF/PLTM2V;
		}
		
		DEAR[n_L-1] <- 0.0;
		DEAR[n_L-1] <- XMRDR*min([LFAR[n_L-1] ,(XLAI*PLTM2V-XLAIM)/PLTM2V]);
		DEAR[n_L-1] <- max([0.0,DEAR[n_L-1]]);
		DATEZ	  	<- TABEX(DISDAT,XDISDAT,TIME,12);
		
		loop i from:0 to:n_L-2 step:1
		{
			XBOX   <- i*100/n_L;
			float f_tab <- TABEX(DIS,BOX,XBOX,10);
			DEAR[i]<- f_tab*DATEZ;
		}
		
		loop i from:0 to:n_L-1 step:1
		{
			DENLR[i] <- LVSN[i]	* DEAR[i];
			DEWLR[i] <- DENLR[i]* AVWL[i];
			DELAR[i] <- DEAR[i]	* LFAR[i];
		}
		
		//do save_array("DENLR",1);
		
		loop i from:0 to:n_F-2 step:1
		{
			XBOX   <- i*100/n_F;
			DEAF[i]<- TABEX(DISF,BOX,XBOX,10)*DATEZ;
		}
		
		loop i from:0 to:n_F-1 step:1
		{
			DENFR[i] <- FRTN[i] * DEAF[i];
			DEWFR[i] <- DENFR[i]* AVWF[i];
		}
	}
	
	// Integration routine for LAI, dry matter content and numbers for each component of the plant, i.e. leaves, fruits and stems
	// Technically implying integration of each state variable of each age class of each state variable
	action INGRAT
	{
		float XBOX <- 0.0;
		CPOOL <- CPOOL+(GP-RCDRW/GREF-MAINT)*DELT;
		PLSTN <- PLSTN+GENR*DELT;
		LVSN[n_L-1] <- LVSN[n_L-1] +(PUSHL*LVSN[n_L-2]) - DENLR[n_L-1]*DELT;
		WLVS[n_L-1] <- WLVS[n_L-1] +(PUSHL*WLVS[n_L-2]) - DEWLR[n_L-1]*DELT;
		LFAR[n_L-1] <- LFAR[n_L-1] +(PUSHL*LFAR[n_L-2]) - DELAR[n_L-1]*DELT;
		STMS[n_L-1] <- STMS[n_L-1] + PUSHL*STMS[n_L-2] * DELT;
		WSTM[n_L-1] <- WSTM[n_L-1] + PUSHL*WSTM[n_L-2] * DELT;

		int II <- 0;
		loop i from:1 to:n_L-2 step:1
		{
			II <- n_L-(i+1);
			LVSN[II]<-LVSN[II] + PUSHL*(LVSN[II-1]-LVSN[II])*DELT-DENLR[II]*DELT;
			STMS[II]<-STMS[II] + PUSHL*(STMS[II-1]-STMS[II])*DELT;
			WLVS[II]<-WLVS[II] +(PUSHL*(WLVS[II-1]-WLVS[II])+RCWLV[II])*DELT-DEWLR[II]*DELT;
			WSTM[II]<-WSTM[II] +(PUSHL*(WSTM[II-1]-WSTM[II])+RCWST[II])*DELT;
			LFAR[II]<-LFAR[II] +(PUSHL*(LFAR[II-1]-LFAR[II])+RCLFA[II])*DELT-DELAR[II]*DELT;
		}
		LVSN[0] <- (RCNL-PUSHL*LVSN[0]*DELT)+LVSN[0]-DENLR[0]*DELT;
		
		
	
		STMS[0] <- STMS[0]+(RCST-PUSHL*STMS[0])*DELT;
		WLVS[0] <- (RCNL*WPLI-PUSHL*WLVS[0]+RCWLV[0])*DELT+WLVS[0]-DEWLR[0]*DELT;
		WSTM[0] <- WSTM[0]+(RCST*WPLI*FRSTEM[0]-PUSHL*WSTM[0]+RCWST[0])*DELT;
		FRPT	<- 1+FRPET[0];
		
		//do save_array("STMS",1);
		//do save_array("LVSN",1);
		//do save_array("WLVS",1);
		//do save_array("DENLR",1);
		//do save_array("DEWLR",1);
		//do save_array("RCWLV",1);
		//do save_array("DELAR",1);
		
		//do save_array("WSTM",1);
		//do save_var("FRPT",1,FRPT);
		
		
		LFAR[0] <- (RCNL*WPLI*ESLA*ASLA[0]/FRPT-PUSHL*LFAR[0]+RCLFA[0])*DELT+LFAR[0]-DELAR[0]*DELT;
		
		//do save_array("LFAR",1);
		
		FRTN[n_F-1] <- FRTN[n_F-1]+(PUSHM*FRTN[n_F-2]-DENFR[n_F-1])*DELT;	
		WFRT[n_F-1] <- WFRT[n_F-1]+(PUSHM*WFRT[n_F-2]-DEWFR[n_F-1])*DELT;
		
		FWFRT[n_F-1] <- WFRT[n_F-1]/FRESHCONV;
		
		loop i from:1 to:n_F-2 step:1
		{
			II <- n_F-(i+1);
			FRTN[II] <- FRTN[II]+ PUSHM*(FRTN[II-1]-FRTN[II])*DELT-(DENFR[II]*DELT);
			WFRT[II] <- WFRT[II]+(PUSHM*(WFRT[II-1]-WFRT[II])+RCWFR[II])*DELT-(DEWFR[II]*DELT);
			FWFRT[II] <- WFRT[II]/FRESHCONV;
		}
		
		FRTN[0] <- (RCNF-ABNF-PUSHM*FRTN[0])*DELT+FRTN[0]-DENFR[0]*DELT;
		WFRT[0] <- ((RCNF-ABNF)*WPFI-PUSHM*WFRT[0]+RCWFR[0])*DELT+WFRT[0]-DEWFR[0]*DELT;
		FWFRT[0] <- WFRT[0]/FRESHCONV;
		
		do save_array("FRTN",1);
		do save_array("WFRT",1);
		do save_array("FWFRT",1);
		
		XLAI	<- 0.0;
		TWTLAI	<- 0.0;
		TOTNLV	<- 0.0;
		TOTWML	<- 0.0;
		TOTNST	<- 0.0;
		TOTWST	<- 0.0;
		ATV		<- 0.0;
		
		loop i from:0 to:n_L-1 step:1
		{
			AVWL[i] <- WLVS[i]/(LVSN[i]+EPS);
			XLAI	<- XLAI+LFAR[i];
			TOTNLV	<- TOTNLV+LVSN[i];
			TOTWML	<- TOTWML+WLVS[i];
			ATL		<- ATL+DEWLR[i]*DELT;
			XBOX 	<- i*100.0/n_L;
			FRPT 	<- TABEX(FRPET,BOX,XBOX,10);
			TWTLAI 	<- TWTLAI + WLVS[0]/(1.0+FRPT);
			TOTNST	<- TOTNST+STMS[i];
			TOTWST	<- TOTWST+WSTM[i];
		}		
		
		//do save_var("TOTWST",1,TOTWST);
		//do save_var("TOTWML",1,TOTWML);
		//do save_var("TOTNST",1,TOTNST);
		//do save_var("TOTNLV",1,TOTNLV);
		//do save_var("XLAI",1,XLAI);
		
		XSLA <- XLAI * (TWTLAI + EPS)*10000.0;
		TOTWMF <- 0.0 ;
		TOTNF  <- 0.0 ;
		
		loop i from:0 to:n_F-1 step:1
		{
			AVWF[i] <- WFRT[i]/(FRTN[i]+EPS);
			TOTWMF 	<- TOTWMF+WFRT[i];
			TOTNF 	<- TOTNF+FRTN[i];
		}
		
		//do save_var("TOTNF",1,TOTNF);
		//do save_var("TOTWMF",1,TOTWMF);
		
		
		WTOTF 	<-  TOTWMF - WFRT[n_F-1];
		TOTGF 	<-  TOTNF  - FRTN[n_F-1];
		
		FWTOTF	<- 	WTOTF/FRESHCONV;
		FTOTWMF <-  TOTWMF/FRESHCONV;
		
		do save_var("WTOTF",1,WTOTF);
		do save_var("FWTOTF",1,FWTOTF);
		do save_var("TOTWMF",1,TOTWMF);
		do save_var("FTOTWMF",1,FTOTWMF);
		
		BTOTNLV	<-  BTOTNLV+ RCNL * DELT;
		DLN		<- (BTOTNLV-TOTNLV) / PLM2;
		TOTGL	<- 0.0;
		ASTOTL	<- 0.0;
		WSTOTL 	<- TOTWML - WLVS[n_L-1];
		TOTGL 	<- TOTNLV - LVSN[n_L-1];
		ASTOTL 	<- XLAI   - LFAR[n_L-1];
		//do save_var("ASTOTL",1,ASTOTL);
		TOTST 	<- TOTNST - STMS[n_L-1];
		//do save_var("TOTST",1,TOTST);
		WSTOTS 	<- TOTWST - WSTM[n_L-1];	
		TOTDW 	<- TOTWMF + TOTWML + TOTWST;
		TOTVW	<- TOTWML + TOTWST;
		ATV		<- TOTWML + TOTWST + ATL;
		ATT		<- ATV    + TOTWMF; 
		TOTNU	<- TOTNF  + TOTNLV;
		NGP		<- TOTGL  + TOTGF+TOTST;
		RVRW 	<- TOTWMF/(TOTWML+EPS);
		RTRW 	<- TOTWMF/(TOTDW+EPS);
		RVRN 	<- TOTNF/(TOTNLV+EPS);
		RTRN 	<- TOTNF/(TOTNU+EPS);
		AVWMF 	<- TOTWMF/(TOTNF+EPS);
		AVWML 	<- TOTWML/(TOTNLV+EPS);
		DMCF84 	<- TABEX(DMC84T,XDMC,TIME,6);
		DMCF84  <- DMCF84=0?EPS:DMCF84;
		FWFR10 	<- FWFR10+(PUSHM*WFRT[n_F-2]*DELT)*100.0/DMCF84;
		// Aqui calcular peso fresco de lo que se recolecta
		FWHVST	<- FWHVST+(PUSHM*WFRT[n_F-2]*DELT);
		APFFW	<- ((PUSHM*(max([WFRT[n_F-2],0.0]))*DELT)*100.0/DMCF84) / ((PUSHM * FRTN[n_F-2] * DELT)+EPS);
		do save_var("FWFR10",1,FWFR10);
		do save_var("FWHVST",1,FWHVST);
	}
	
	
	float TABEX(list<float> VAL, list<float> ARG, float DUMMY, int K)
	{
		float result <- 0.0;
		
		if length(VAL)!=length(ARG)
		{
			K <- min([length(VAL),length(ARG)]);
		}
		loop j from: 1 to: K-1 // Mod-->    from:2 -a-> from:1 
		{
			if !(DUMMY > ARG[j])
			{
				result <- (DUMMY - ARG[j-1]) * (VAL[j]-VAL[j-1]) / (ARG[j]-ARG[j-1]) + VAL[j-1];
				break;
			}
		}
		
		return result;
	}
	
	
	action save_array(string array, int stp)
	{
		string folder <- "output/";
		int hour_cyc <- cycle mod 24; 
		switch array
		{
			match "RCWLV"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, RCWLV
				] to:folder+"leaves/RCWLV_G.csv" type:csv rewrite:false;
			}
			match "WLVS"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, WLVS
				] to:folder+"leaves/WLVS_G.csv" type:csv rewrite:false;
			}
			match "RCLFA"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, RCLFA
				] to:folder+"leaves/RCLFA_G.csv" type:csv rewrite:false;
			}
			match "LFAR"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, LFAR
				] to:folder+"leaves/LFAR_G.csv" type:csv rewrite:false;
			}
			match "RCWFR"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, RCWFR
				] to:folder+"fruit/RCWFR_G.csv" type:csv rewrite:false;
			}
			match "PNLVS"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, PNLVS
				] to:folder+"leaves/PNLVS_G.csv" type:csv rewrite:false;
			}
			match "LVSN"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, LVSN
				] to:folder+"leaves/LVSN_G.csv" type:csv rewrite:false;
			}
			match "PNTSM"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, PNTSM
				] to:folder+"stem/PNTSM_G.csv" type:csv rewrite:false;
			}
			match "STMS"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, STMS
				] to:folder+"stem/STMS_G.csv" type:csv rewrite:false;
			}
			match "RCWST"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, RCWST
				] to:folder+"stem/RCWST_G.csv" type:csv rewrite:false;
			}
			match "WSTM"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, WSTM
				] to:folder+"stem/WSTM_G.csv" type:csv rewrite:false;
			}
			match "DEAR"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, DEAR
				] to:folder+"leaves/DEAR_G.csv" type:csv rewrite:false;
			}
			match "AVWL"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, AVWL
				] to:folder+"leaves/AVWL_G.csv" type:csv rewrite:false;
			}
			match "DEWLR"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, DEWLR
				] to:folder+"leaves/DEWLR_G.csv" type:csv rewrite:false;
			}
			match "DELAR"
			{
				save data:[   cycle
					, hour_cyc
					, step
					, DELAR
				] to:folder+"leaves/DELAR_G.csv" type:csv rewrite:false;
			}
			match "DENLR"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, DENLR
				] to:folder+"leaves/DENLR_G.csv" type:csv rewrite:false;
			}
			match "FRTN"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, FRTN
				] to:folder+"fruit/FRTN_G.csv" type:csv rewrite:false;
			}
			match "WFRT"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, WFRT
				] to:folder+"fruit/WFRT_G.csv" type:csv rewrite:false;
			}
			match "AVWF"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, AVWF
				] to:folder+"fruit/AVWF_G.csv" type:csv rewrite:false;
			}
			match "DENFR"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, DENFR
				] to:folder+"fruit/DENFR_G.csv" type:csv rewrite:false;
			}
			match "DEWFR"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, DEWFR
				] to:folder+"fruit/DEWFR_G.csv" type:csv rewrite:false;
			}
			match "PNFRT"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, PNFRT
				] to:folder+"fruit/PNFRT_G.csv" type:csv rewrite:false;
			}
			match "DEAF"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, DEAF
				] to:folder+"fruit/DEAF_G.csv" type:csv rewrite:false;
			}
			match "FWFRT"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, FWFRT
				] to:folder+"fruit/FWFRT_G.csv" type:csv rewrite:false;
			}
			match "FAVWF"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, FAVWF
				] to:folder+"fruit/FAVWF_G.csv" type:csv rewrite:false;
			}
			match "FAVFM"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, FAVFM
				] to:folder+"fruit/FAVFM_G.csv" type:csv rewrite:false;
			}
			match "FAVWMF"
			{
				save data:[   cycle
					, hour_cyc
					, stp
					, FAVWMF
				] to:folder+"fruit/FAVWMF_G.csv" type:csv rewrite:false;
			}
		}// switch
		
	}
	
	
	action save_var(string var_name, int stp, float value)
	{
		int hour_cyc  <- cycle mod 24; 
		string folder <- "output/"; 
		
		switch var_name
		{
			match_one["CLSDML", "XLAI", "PTNLVS","XSLA", "ASTOTL","RCNL", "ATV", "ATL", "TOTDML", "TWTLAI", "TOTWML", "WSTOTL", "TOTGL", "TOTNLV", "BTOTNLV", "DLN"]
			{
				folder <- "output/leaves/";
			}
			match_one["PTNFRT","CLSDMF","FABOR","RVRW","RTRW","RVRN","RTRN","RCNF","ABNF","TOTDMF","WTOTF","FWFR10","APFFW","TOTWMF","AVWMF","AVWML","DMCF84","TOTNF","TOTGF","FWTOTF","FTOTWMF","FWPFI"]
			{
				folder <- "output/fruit/";
			}
			match_one["RCST","TOTST","TOTDMS","PTNSTM","TOTWST","WSTOTS","TOTNST"]
			{
				folder <- "output/stem/";
			}
			default
			{
				folder <- "output/vars/";
			}
		}
		
		save data:[   cycle
					, hour_cyc
					, stp
					, value
				] to:folder+var_name+".csv" type:csv rewrite:false;
	}
}


experiment mi_experimento type:gui{

	
	output{
		display GUI type:opengl 
		{
			
			
		}
		
		display Statistics
		{
   			chart "GPF" type:series y_label:"GPF"  size: {0.5,0.5} position: {0.0, 0.0}
			{
				datalist plant value:(tomato_plant collect each.GPF) legend:(tomato_plant collect each.name) color:(tomato_plant collect #blue) marker:false;
				
			}
			
			chart "MAINTF" type:series y_label:"MAINTF"  size: {0.5,0.5} position: {0.5, 0.0}
			{
				datalist plant value:(tomato_plant collect each.MAINTF) legend:(tomato_plant collect each.name) color:(tomato_plant collect #blue) marker:false;
				
			}
			
			chart "GP" type:series y_label:"GP"  size: {0.5,0.5} position: {0.0, 0.5}
			{
				datalist plant value:(tomato_plant collect each.GP) legend:(tomato_plant collect each.name) color:(tomato_plant collect #blue) marker:false;
				
			}
			
			chart "MAINT" type:series y_label:""  size: {0.5,0.5} position: {0.5, 0.5}
			{
				datalist plant value:(tomato_plant collect each.MAINT) legend:(tomato_plant collect each.name) color:(tomato_plant collect #blue) marker:false;	
			}
		}
		/* 
	float GP 		    <- 0.0 	;				// Gross photosynthesis
	float MAINT 	    <- 0.0 	;				// Maintenance respiration
	float GENR		    <- 0.0 	;				// Daily integrated rate of node initiation per plant
		 */
		
	}
	
}





