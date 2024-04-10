/**
* Name: constants
* Based on the internal empty template. 
* Author: Liliana Durán Polanco
* Tags: 
*/


model constants

global
{
	// MEASUREMENT DATA FOR A DAY
	matrix<float> 	day_changes <- matrix(csv_file("../includes/day_changes.csv", true)) ;
	
	// VECTORS FOR EVAPOTRANSPIRATION
	matrix<float> 	daily_irrigation	<- matrix(csv_file("../includes/E1_daily_irrigation.csv", true));		// Actual irrigation to implement Minhas model
	matrix			stages_data			<- matrix(csv_file("../includes/E1_stages_file.csv", true));					// Data for Minhas model 
	
	// GROWING STAGES
	map<string,float>   stage_sensitivity 	;//<- ["stageI"::0.0552,"stageII"::0.6721,"stageIII"::0.8176]; // alphas in Minhas model
	map<string,float>	optimal_irrigation	;
	map<string,int>    	stage_duration 		;//<- ["stageI"::20,"stageII"::40,"stageIII"::60]; 			// the integers represent the number of days in that stage
	list<string>		stages				;//<- ["stageI","stageII","stageIII"];;

	// TABLES
	list<float> BOX 	<-[10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0];
	list<float> POL 	<-[0.0007,	0.0016,	0.0031,	0.0032,	0.0032,	0.0032,	0.0032,	0.0032,	0.0032,	0.0];
	list<float> POF 	<-[0.03, 0.07, 0.13, 0.3, 0.4, 0.4, 0.4, 0.4, 0.4, 0.0]; 			// Relative potential sink capacity per fruit age class
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
	float WPLI			<- 0.1		;			// Initial weight per initiated leaf   // In testing the value was 0.0001
	float WPFI			<- 0.000	;			// Initial weight per initiated fruit
	float SLAMX			<- 0.075	;			// Maximum value of SLA per leaf age class
	float SLAMN			<- 0.024	;			// Minimum value of SLA per leaf age class
	float STDSLA		<- 0.075	;			// Standard' value of SLA at 24 C, 350 J..lmol mol-1 C02. and low PAR
	float FRLG			<- 10.0		;			// Lag period between the time that a no (nodes) truss appears and a fruit appears on plant that truss
	float AVFM			<- 18.0		;			// Average weight per mature fruit	(g)
	float SCO2			<- 0.00095	;			// Relative increase in development rate as a function of C02 level
	float THIGH			<- 29.5		;			// Temperature threshold above which fruit set decreases
	float TLOW			<- 10.0		;			// Temperature threshold below which splitting of trusses occurs and more fruits are initiated per new leaf
	float TTMX			<- 0.15		;			// Cumulative thermal time above THIGH °C necessary for complete inhibition of fruit set
	float TTMN			<- 0.1		;			// Cumulative thermal time below TLOW °C necessary for complete truss splitting
	float ZBENG			<- 0.75		;			// Factor accounting for the effect of supply/demand ratio on root growth
	float TU1			<- 2.2		;			// Auxiliary variable used for adaptation of Gainesville TAU1 to conditions in Israel
	float TU2			<- 3.5		;			// Auxiliary variable used for adaptation of Gainesville TAU2 to conditions in Israel
	int   NSTART		<- 282		;			// Starting day (number of Julian calendar day)
	int   NDAYS			<- 80		;			// Number of days to be simulated
	int   DELT			<- 1		;			// Time step of simulation within the main loop
	int   NFAST			<- 24		;			// Number of time steps within the fast loop during one day
	int   INTOUT		<- 7		;			// lntervaI for output
	float TRGH			<- 1.0		;			// Transmissivity of the greenhouse cover
	float PLM2			<- 3.0		;			// Plant density // 3.0
	float PLSTNI		<- 6.0;//6.0		;	// Initial plastochron index
	float LVSNI			<- 5.0;//1.0		;	// Initial number of leaves per plant
	float WLVSI			<- 0.5		;			// Initial weight of leaves  // For testing purpose the value was 0.005
	float LFARI			<- 0.002	;			// Initial leaf area per plant
	float QE			<- 0.056	;	
	float XK			<- 0.58		;
	float XM			<- 0.1		;
	
		                        
}
