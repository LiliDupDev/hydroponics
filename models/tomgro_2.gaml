/**II]
* Name: tomgro2
* Based on the internal empty template. 
* Author: lin_2
* Tags: 
*/


model tomgro2

global
{
	
	bool 			export 		<- true;
	matrix<float> 	day_changes;
	
	
	
	init
	{
		step <- 1#hour;
		day_changes 			<- matrix(csv_file("../includes/day_changes_2.csv", true));
		
		create tomato_plant number:1;
	}
	
	
	reflex daily when:every(24#hours)
	{
		ask tomato_plant
		{
			do main_cycle;
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
			do fast_cycle(temperature, CO2, PAR);//hourly_GROWTH(temperature,CO2,PAR,PPFD);
		}
	}
	
	
	
}


species tomato_plant
{
	// TABLES
	list<float> BOX 	<-[10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0];
	list<float> POL 	<-[0.0007,	0.0016,	0.0031,	0.0032,	0.0032,	0.0032,	0.0032,	0.0032,	0.0032,	0.0];
	list<float> POF 	<-[0.03, 0.07, 0.13, 0.3, 0.4, 0.4, 0.4, 0.4, 0.4, 0.0];
	list<float> ASLA 	<-[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0];
	list<float> FRPET 	<-[0.49, 0.49, 0.49, 0.49, 0.49, 0.49, 0.49, 0.49, 0.49, 0.49];
	list<float> FRSTEM 	<-[0.43, 0.43, 0.43, 0.43, 0.43, 0.43, 0.43, 0.43, 0.43, 0.43];
	list<float> DIS 	<-[1.0, 1.0, 1.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
	list<float> DISF 	<-[1.0, 1.0, 1.0, 1.0, 0.75, 0.0, 0.0, 0.0, 0.0, 0.0];
	list<float> PGRED 	<-[0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0];
	list<float> TMPG 	<-[-10.0, 0.0, 12.0, 20.0, 28.0, 35.0, 40.0, 80.0];
	list<float> FPN 	<-[0.01, 0.01, 0.01, 0.2, 0.25, 1.5, 3.1, 3.1, 3.1, 3.1];
	list<float> XFPN 	<-[0.0, 6.0, 7.0, 8.0, 9.0, 13.0, 20.0, 24.0, 50.0, 90.0];
	list<float> GENTEM 	<-[0.0, 0.5, 0.95, 1.0, 0.2, 0.0];
	list<float> XTEM 	<-[0.0, 6.0, 21.0, 28.0, 50.0, 80.0]; 								// 	DEG
	list<float> GENRAT 	<-[0.55, 0.55, 0.55, 0.55, 0.55, 0.05]; 							// 	NODES/DAY
	list<float> XGEN 	<-[0.0, 10.0, 20.0, 65.0, 70.0, 90.0];								// 	PLSTN OR NODES DEV
	list<float> RDVLVT 	<-[0.0, 0.0035, 0.006, 0.0095, 0.011, 0.012, 0.012, 0.001, 0.0];	// 	VEG DEV R
	list<float> XLV 	<-[0.0, 9.0, 12.0, 15.0, 20.0, 28.0, 35.0, 50.0, 80.0];				//  TEMP
	list<float> RDVFRT 	<-[0.0, 0.0065, 0.0095, 0.0120, 0.0165, 0.0165, 0.0150, 0.001, 0.0];
	list<float> XFRT 	<-[0.0, 9.0, 12.0, 15.0, 24.0, 28.0, 35.0, 50.0, 80.0];
	list<float> PROOT 	<-[0.2, 0.08, 0.08, 0.08, 0.08, 0.08];
	list<float> XROOT 	<-[1.0, 12.0, 20.0, 30.0, 50.0, 190.0];
	list<float> DMC84T 	<-[4.5, 4.5, 5.0, 7.0, 8.5, 9.0];
	list<float> XDMC 	<-[0.0, 100.0, 130.0, 150.0, 200.0, 250.0];
	list<float> PART 	<-[0.0, 0.025, 0.065, 0.15, 0.15];
	list<float> XPART 	<-[0.0, 15.0, 20.0, 30.0, 100.0];
	list<float> AEFT 	<-[1.0, 1.0, 1.0, 0.99, 0.8, 0.1];
	list<float> XAEFT 	<-[0.0, 20.0, 50.0, 55.0, 60.0, 200.0];
	
	list<float> CO2LT 	<-[350.0, 350.0, 350.0, 350.0, 350.0, 350.0];
	list<float> XCO2LT	<-[0.0, 39.0, 40.0, 175.0, 176.0, 250.0];
	list<float> DISDAT	<-[0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
	list<float> XDISDAT	<-[0.0, 20.0, 40.0, 160.0, 161.0, 162.0, 164.0, 300.0, 301.0, 302.0, 303.0, 304.0];
	
	map<int,float>  M_PLTM2V  <- [10::15.5, 17::11.0, 21::8.5, 36::7.0, 45::6.5, 57::6.0, 66::5.0, 84::4.0, 100::3.0];
	
	// PARAMS
	int   n_L 			<- 20 		;			// Leaf age classes 
	int   n_F 			<- 20 		; 			// Fruit age classes
	float TABK 			<- 0.3		;			// Factor accounting for the effect of low temperature on fruit abortion			
	float TLOWAB		<- 10.5		;			// Temperature threshold below which fruits are aborted
	float CO2M	        <- 0.21		;			// Factor to calculate effect of C02 On specific leaf area		
	float TPL	        <- 0.33		;			// Number of trusses per leaf after initiation of first truss
	float EPS	        <- 10^(-12)	;	 		// Auxiliary variable, very small number (10E-12), to avoid zero division
	float GREF	        <- 0.7		;			// Growth efficiency, accounting for growth respiration
	float SPTEL	        <- 1.0		;			// Auxiliary value for adaptation of units
	float GENFAC		<- 0.65		;			// Factor accounting for the effect of supply/demand ratio on initiation of new nodes	
	float XLAIM			<- 3.0		;			// LAI above which death of leaves due to shading starts
	float XMRDR			<- 0.1		;			// Fraction of leaves dying due to shading
	float ABORMX		<- 8.3		;			// Auxiliary variable for calculating fruit abortion rate as a function of supply/demand ratio for dry matter
	float Q10	        <- 1.4		;			// Effect of temperature on maintenance respiration
	float RMRL	        <- 0.015	;			// Relative maintenance requirements of vegetative material
	float RMRF	        <- 0.01		;			// Maintenance requirements of fruits
	float FTRUSN		<- 6.0		;			// Node number on the plant that bears the first truss	
	float WPLI			<- 1.0		;			// Initial weight per initiated leaf
	float WPFI			<- 0.0		;			// Initial weight per initiated fruit
	float SLAMX			<- 0.075	;			// Maximum value of SLA per leaf age class
	float SLAMN			<- 0.024	;			// Minimum value of SLA per leaf age class
	float STDSLA		<- 0.075	;			// Standard' value of SLA at 24 C, 350 J..lmol mol-1 C02. and low PAR
	float FRLG			<- 10.0		;			// Lag period between the time that a no (nodes) truss appears and a fruit appears on plant that truss
	float AVFM			<- 2.5		;			// Average weight per mature fruit	
	float SCO2			<- 0.00095	;			// Relative increase in development rate as a function of C02 level
	float THIGH			<- 29.5		;			// Temperature threshold above which fruit set decreases
	float TLOW			<- 10.0		;			// Temperature threshold below which splitting of trusses occurs and more fruits are initiated per new leaf
	float TTMX			<- 0.15		;			// Cumulative thermal time above THIGH °C necessary for complete inhibition of fruit set
	float TTMN			<- 0.1		;			// Cumulative thermal time below TLOW °C necessary for complete truss splitting
	float ZBENG			<- 0.75		;			// Factor accounting for the effect of supply/demand ratio on root growth
	float TU1			<- 2.2		;			// Auxiliary variable used for adaptation of Gainesville TAU1 to conditions in Israel
	float TU2			<- 3.5		;			// Auxiliary variable used for adaptation of Gainesville TAU2 to conditions in Israel
	int   NSTART		<- 282		;			// Starting day (number of Julian calendar day)
	int   NDAYS			<- 230		;			// Number of days to be simulated
	int   DELT			<- 1		;			// Time step of simulation within the main loop
	int   NFAST			<- 24		;			// Number of time steps within the fast loop during one day
	int   INTOUT		<- 7		;			// lntervaI for output
	float TRGH			<- 1.0		;			// Transmissivity of the greenhouse cover
	float PLM2			<- 3.0		;			// Plant density
	float ROWSPC		<- 1.0		;			// Row spacing
	float PLSTNI		<- 6.0		;			// Initial plastochron index
	float LVSNI			<- 5.0		;			// Initial number of leaves per plant
	float WLVSI			<- 0.5		;			// Initial weight of leaves
	float LFARI			<- 0.002	;			// Initial leaf area per plant
	float QE			<- 0.056	;	
	float XK			<- 0.58		;
	float XM			<- 0.1		;
	
		                        
	
	/* ******************************  GENERAL  ******************************** */
	float PLTM2V		<- 22.0		;
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
	list<float> LFAR	;							// Leaf are index per age class	
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
		
		PLSTN	<- PLSTNI;
		CPOOL	<- 0.0;
		LVSN[0]	<- LVSNI*PLM2;
		BTOTNLV	<- LVSNI*PLM2;
		STMS[0]	<- LVSN[0];
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
		//write "[INIT - 1] ----> WLVS --->"+WLVS;
		//write "[INIT - 1] ----> WSTOTL ->"+WSTOTL;
		do save_array("PNLVS",0);
		do save_array("RCLFA",0);
		do save_array("RCWLV",0);
		do save_array("LVSN",0);
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
	
	
	action main_cycle
	{
		write "Main ----------------------> Cycle: "+cycle;
		float PAR <- 20.1;
		TIME <- int(cycle / 24);
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
		//write "[fast_cycle - "+DTFAS;//T+"] ---> [GENR] ---> "+GENR;
		//write "[main_cycle] ---> [GENR] ---> "+GENR;
	
			
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
		] to:"ACCUM.csv" type:csv rewrite:false;
		
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
		] to:"ACCUM_F.csv" type:csv rewrite:false;
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
		}
		
		TEMFCF 	<- TABEX(GENTEM,XTEM,TMPA,6);										// Compute plastochron development rate, GENRF
		GENRF	<- min(max(EPS,CLSDML)/GENFAC,1)*TEMFCF*TABEX(GENRAT,XGEN,PLSTN,6);	
		RDVLVF	<- TABEX(RDVLVT,XLV,TMPA,9)*SPTEL*FCO2;								// Compute leaf aging
		//write "[DEVFAST - 2] ---> [GENRF] ---> "+GENRF;
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
		float TAU1 <- 0.06638*TU1;
		float TAU2 <- 0.06638*TU2;
		
		PMAX <- TAU1 *CO2AVG;	
		
		if CO2AVG > 350
		{
			PMAX <- TAU1*350.0+TAU2*(CO2AVG-350.0);
		}
		
		AEF	<- TABEX(AEFT,XAEFT,PLSTN,6);
		PMAX<- PMAX * TABEX(PGRED,TMPG,TMPA,8)*AEF;
		if PPFD >= 0.001
		{
			
			float TOP <- (1.0-XM)*PMAX + QE*XK*PPFD;
			float BOT <- (1.0-XM)*PMAX + QE*XK*PPFD*exp(-XK*ASTOTL*PLTM2V); 

			GPF	<- (PMAX/XK);//*ln(TOP/BOT);
			GPF <- GPF * 0.682;
			GPF <- GPF * 3.8016;
		}
		
	}
	
	// Calculation of maintenance respiratioon from leaf weights, stem weights, Q10 values and temperature
	action RESP(float TMPA)
	{
		float TEFF <- Q10^(0.1*TMPA-2.0);
		//write "[RESP]---> TOTWST ----> "+TOTWST;
		//write "[RESP]---> WSTOTL ----> "+WSTOTL;
		
		MAINTF <- TEFF*(RMRL*(TOTWST+WSTOTL)+RMRF*WTOTF);
	}
	
	// Calculation of dry matter partitioning and accumulation in each age class of each component
	action DMRATE(float PAR)
	{
		float PARSLA <- 1-TABEX(PART,XPART,PAR,5); //COMPUTE SPECIFIC LEAF AREA GROWTH FACTOR BASED ON DAILY PAR
		ESLA <- STDSLA*PARSLA/(TSLA*CSLA);
		ESLA <- max([0.018,ESLA]);
		ESLA <- min([SLAMX,ESLA]);
		
		//write "ESLA: "+ESLA;
		
		float TRCDRW <- (GP/PLTM2V-MAINT)*GREF;
		TRCDRW <- max([TRCDRW,0.0]);
		RCDRW  <- TRCDRW*(1.0-TABEX(PROOT,XROOT,PLSTN,6))*min([max([EPS,CLSDML])/ZBENG,1.0])*TEMFAC;
		PTNLVS <- 0.0 ;
		PTNSTM <- 0.0 ;
		float XBOX <- 0.0;
		
		do save_array("PNLVS",1);
		do save_array("RCLFA",1);
		// COMPUTE SINK STRENGTH OF LEAVES, FRUIT WLVS(I) INCLUDES WT OF PETIOLES AND STEM, LFAR(I) INCLUDES AREA ONLY
		loop i from:0 to:n_L-1 step:1
		{
			XBOX 	<- i*100.0/n_L;
			RCLFA[i]<- LVSN[i]*TABEX(POL,BOX,XBOX,10)*TEMFAC*FCO2D;
			FRPT 	<- TABEX(FRPET,BOX,XBOX,10);
			FRST 	<- TABEX(FRSTEM,BOX,XBOX,10);
			PNLVS[i]<- (RCLFA[i]/TABEX(ASLA,BOX,XBOX,10)*ESLA)*(1.0+FRPT);
			PTNLVS  <- PTNLVS+PNLVS[i];
			PNTSM[i]<- PNLVS[i]/(LVSN[i]+EPS)*FRST*STMS[i];
			PTNSTM 	<- PTNSTM+PNTSM[i];
		}
		do save_array("PNLVS",2);
		do save_array("RCLFA",2);
		
		float ZZX <- 0.0;
		loop i from:0 to:n_F-1 step:1
		{
			ZZX 	<- min([1.0,max([EPS,2.0-AVWF[i]/AVFM])]);
			XBOX	<- i*100.0/n_F;
			PNFRT[i]<-FRTN[i]+TABEX(POF,BOX,XBOX,10)*TEMFAC*FCO2D*ZZX;
			PTNFRT 	<- PTNFRT+PNFRT[i];
		}
		
		float PNGP	<- PTNLVS+PTNFRT+PTNSTM;
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
		
		// COMPUTE COHORT GROWTH RATES
		do save_array("RCLFA",3);
		do save_array("RCWLV",1);
		loop i from:0 to:n_L-1 step:1
		{
			RCWLV[i]	<- TOTDML*PNLVS[i]/(PTNLVS+EPS);
			RCWST[i]	<- TOTDMS*PNTSM[i]/(PTNSTM+EPS);
			
			// NOW ADJUST LEAF AREA EXPANSION TO AVAILABLE CH20
			XBOX		<- i*100.0/n_L;
			FRPT		<- TABEX(FRPET,BOX,XBOX,10);
			RCLFA[i]	<- RCWLV[i]*TABEX(ASLA,BOX,XBOX,10)*ESLA/(1+FRPT);
		}
		do save_array("RCLFA",4);
		do save_array("RCWLV",2);
		
		loop i from:0 to:n_F-1 step:1
		{
			RCWFR[i] <- TOTDMF*PNFRT[i]/(PTNFRT+EPS);
		}
		
		// TODO: Save totals in CSV
		save data:[   cycle
					, cycle mod 24
					, TRCDRW    
					, RCDRW 	
					, PTNLVS
					, PTNFRT
					, TOTDML
					, TOTDMF
					, CLSDMF
					, CLSDML  
		] to:"TOTALS.csv" type:csv rewrite:false;
		
		
	}
	
	// Calculation of rates of appearance of nodes, leaves and fruits and rates of material flow between age classes
	action DEVRAT
	{
		TPLA <- 0.0 ;
		if PLSTN >= FTRUSN
		{
			TPLA <- TPL;
		}
		//write "[DEVRAT] ---> [PLM2] --> "+PLM2;
		//write "[DEVRAT] ---> [GENR] --> "+GENR;
		//write "[DEVRAT] ---> [TPLA] --> "+TPLA;
		//write "[DEVRAT] ---> [RCNL - 1] --> "+RCNL;
		RCNL <- PLM2*GENR/(1+TPLA);
		//write "[DEVRAT] ---> [RCNL - 2] --> "+RCNL;
		RCST <- PLM2*GENR;
		RCNF <- GENR*TABEX(FPN,XFPN,PLSTN-FRLG,10)*PLM2;
		RCNF <- RCNF*max(1.0-TTH/TTMX,0.0)*max([1.0+TTL/TTMN,0.0]);
		PUSHL<- RDVLV;//*n_L;
		PUSHM<- RDVFR*n_F;
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
		DATEZ	  <- TABEX(DISDAT,XDISDAT,TIME,12);
		
		loop i from:0 to:n_L-2 step:1
		{
			XBOX   <- i*100/n_L;
			DEAR[i]<- TABEX(DIS,BOX,XBOX,10)*DATEZ;
		}
		
		
		do save_array("DEWLR",1);
		do save_array("DENLR",1);
		do save_array("DELAR",1);
		loop i from:0 to:n_L-1 step:1
		{
			DENLR[i] <- LVSN[i]	* DEAR[i];
			DEWLR[i] <- DENLR[i]* AVWL[i];
			DELAR[i] <- DEAR[i]	* LFAR[i];
		}
		do save_array("DEWLR",2);
		do save_array("DENLR",2);
		do save_array("DELAR",2);
		
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
		do save_array("LVSN",1);
		//write "[INGRAT - 1] ---> WLVS ---> "+WLVS;
		float XBOX <- 0.0;
		CPOOL <- CPOOL+(GP-RCDRW/GREF-MAINT)*DELT;
		PLSTN <- PLSTN+GENR*DELT;
		LVSN[n_L-1] <- LVSN[n_L-1] +(PUSHL*LVSN[n_L-2]) - DENLR[n_L-1]*DELT;
		WLVS[n_L-1] <- WLVS[n_L-1] +(PUSHL*WLVS[n_L-2]) - DEWLR[n_L-1]*DELT;
		//write "[INGRAT - 2] ---> WLVS ---> "+WLVS;
		LFAR[n_L-1] <- LFAR[n_L-1] +(PUSHL*LFAR[n_L-2]) - DELAR[n_L-1]*DELT;
		STMS[n_L-1] <- STMS[n_L-1] + PUSHL*STMS[n_L-2] * DELT;
		WSTM[n_L-1] <- WSTM[n_L-1] + PUSHL*WSTM[n_L-2] * DELT;
		do save_array("LVSN",2);
		int II <- 0;
		loop i from:1 to:n_L-2 step:1
		{
			II <- n_L-i;
			//write "II --> "+II;
			LVSN[II]<-LVSN[II] + PUSHL*(LVSN[II-1]-LVSN[II])*DELT-DENLR[II]*DELT;
			STMS[II]<-STMS[II] + PUSHL*(STMS[II-1]-STMS[II])*DELT;
			WLVS[II]<-WLVS[II] +(PUSHL*(WLVS[II-1]-WLVS[II])+RCWLV[II])*DELT-DEWLR[II]*DELT;
			WSTM[II]<-WSTM[II] +(PUSHL*(WSTM[II-1]-WSTM[II])+RCWST[II])*DELT;
			LFAR[II]<-LFAR[II] +(PUSHL*(LFAR[II-1]-LFAR[II])+RCLFA[II])*DELT-DELAR[II]*DELT;
		}
		do save_array("LVSN",3);
		LVSN[0] <- (RCNL-PUSHL*LVSN[0]*DELT)+LVSN[0]-DENLR[0]*DELT;
		do save_array("LVSN",4);
		STMS[0] <- STMS[0]+(RCST-PUSHL*STMS[0])*DELT;
		WLVS[0] <- (RCNL*WPLI-PUSHL*WLVS[0]+RCWLV[0])*DELT+WLVS[0]-DEWLR[0]*DELT;
		WSTM[0] <- WSTM[0]+(RCST*WPLI*FRSTEM[0]-PUSHL*WSTM[0]+RCWST[0])*DELT;
		FRPT	<- 1+FRPET[0];
		LFAR[0] <- (RCNL*WPLI*ESLA*ASLA[0]/FRPT-PUSHL*LFAR[0]+RCLFA[0])*DELT+LFAR[0]-DELAR[0]*DELT;
		FRTN[n_F-1] <- FRTN[n_F-1]+(PUSHM*FRTN[n_F-2]-DENFR[n_F-1])*DELT;
		WFRT[n_F-1] <- WFRT[n_F-1]+(PUSHM*WFRT[n_F-2]-DEWFR[n_F-1])*DELT;
		

		loop i from:1 to:n_F-2 step:1
		{
			II <- n_F-i;
			FRTN[II] <- FRTN[II]+ PUSHM*(FRTN[II-2]-FRTN[II])*DELT-DENFR[II]*DELT;
			WFRT[II] <- WFRT[II]+(PUSHM*(WFRT[II-2]-WFRT[II])+RCWFR[II])*DELT-DEWFR[II]*DELT;
		}
	
		
		FRTN[0] <- (RCNF-ABNF-PUSHM*FRTN[0])*DELT+FRTN[0]-DENFR[0]*DELT;
		WFRT[0] <- ((RCNF-ABNF)*WPFI-PUSHM*WFRT[0]+RCWFR[0])*DELT+WFRT[0]-DEWFR[0]*DELT;
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
		//write "[INGRAT - 2] --> [TOTWML] --> "+TOTWML;
		//write "[INGRAT - 5] ----> WLVS --->  " +WLVS;
		
		XSLA <- XLAI * (TWTLAI + EPS)*10000.0;
		TOTWMF <- 0.0 ;
		TOTNF  <- 0.0 ;
		
		loop i from:0 to:n_F-1 step:1
		{
			AVWF[i] <- WFRT[i]/(FRTN[i]+EPS);
			TOTWMF 	<- TOTWMF+WFRT[i];
			TOTNF 	<- TOTNF+FRTN[i];
		}
		
		WTOTF 	<-  TOTWMF - WFRT[n_F-1];
		TOTGF 	<-  TOTNF  - FRTN[n_F-1];
		BTOTNLV	<-  BTOTNLV+ RCNL * DELT;
		DLN		<- (BTOTNLV-TOTNLV) / PLM2;
		TOTGL	<- 0.0;
		ASTOTL	<- 0.0;
		WSTOTL 	<- TOTWML - WLVS[n_L-1];
		TOTGL 	<- TOTNLV - LVSN[n_L-1];
		ASTOTL 	<- XLAI   - LFAR[n_L-1];
		TOTST 	<- TOTNST - STMS[n_L-1];
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
		FWFR10 	<- FWFR10+(PUSHM*WFRT[n_F-2]*DELT)*100.0/DMCF84;
		APFFW	<- ((PUSHM*(max([WFRT[n_F-2],0.0]))*DELT)*100.0/DMCF84) / ((PUSHM * FRTN[n_F-2] * DELT)+EPS);
	}
	
	
	float TABEX(list<float> VAL, list<float> ARG, float DUMMY, int K)
	{
		float result <- 0.0;
		
		if length(VAL)!=length(ARG)
		{
			K <- min([length(VAL),length(ARG)]);
		}
		
		loop j from: 2 to: K-1
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
		switch array
		{
			match "RCWLV"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, RCWLV
				] to:"RCWLV_G.csv" type:csv rewrite:false;
			}
			match "WLVS"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, WLVS
				] to:"WLVS_G.csv" type:csv rewrite:false;
			}
			match "RCLFA"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, RCLFA
				] to:"RCLFA_G.csv" type:csv rewrite:false;
			}
			match "LFAR"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, LFAR
				] to:"LFAR_G.csv" type:csv rewrite:false;
			}
			match "RCWFR"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, RCWFR
				] to:"RCWFR_G.csv" type:csv rewrite:false;
			}
			match "PNLVS"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, PNLVS
				] to:"PNLVS_G.csv" type:csv rewrite:false;
			}
			match "LVSN"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, LVSN
				] to:"LVSN_G.csv" type:csv rewrite:false;
			}
			match "PNTSM"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, PNTSM
				] to:"PNTSM_G.csv" type:csv rewrite:false;
			}
			match "STMS"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, STMS
				] to:"STMS_G.csv" type:csv rewrite:false;
			}
			match "RCWST"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, RCWST
				] to:"RCWST_G.csv" type:csv rewrite:false;
			}
			match "WSTM"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, WSTM
				] to:"WSTM_G.csv" type:csv rewrite:false;
			}
			match "DEAR"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, DEAR
				] to:"DEAR_G.csv" type:csv rewrite:false;
			}
			match "AVWL"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, AVWL
				] to:"AVWL_G.csv" type:csv rewrite:false;
			}
			match "DEWLR"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, DEWLR
				] to:"DEWLR_G.csv" type:csv rewrite:false;
			}
			match "DELAR"
			{
				save data:[   cycle
					, cycle mod 24
					, step
					, DELAR
				] to:"DELAR_G.csv" type:csv rewrite:false;
			}
			match "DENLR"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, DENLR
				] to:"DENLR_G.csv" type:csv rewrite:false;
			}
			match "FRTN"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, FRTN
				] to:"FRTN_G.csv" type:csv rewrite:false;
			}
			match "WFRT"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, WFRT
				] to:"WFRT_G.csv" type:csv rewrite:false;
			}
			match "AVWF"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, AVWF
				] to:"AVWF_G.csv" type:csv rewrite:false;
			}
			match "DENFR"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, DENFR
				] to:"DENFR_G.csv" type:csv rewrite:false;
			}
			match "DEWFR"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, DEWFR
				] to:"DEWFR_G.csv" type:csv rewrite:false;
			}
			match "PNFRT"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, PNFRT
				] to:"PNFRT_G.csv" type:csv rewrite:false;
			}
			match "DEAF"
			{
				save data:[   cycle
					, cycle mod 24
					, stp
					, DEAF
				] to:"DEAF_G.csv" type:csv rewrite:false;
			}
		}// switch
		
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





