/**
* Name: TEST
* Based on the internal empty template. 
* Author: lin_2
* Tags: 
*/


model TEST


global {	

	list<float> RDVFRT 	<-[0.0, 0.0065, 0.0095, 0.0120, 0.0165, 0.0165, 0.0150, 0.001, 0.0];
	list<float> XFRT 	<-[0.0, 9.0, 12.0, 15.0, 24.0, 28.0, 35.0, 50.0, 80.0];    
		
	init 
	{
		create dummy_species number:1;
	}
	

}

species dummy_species 
{
	
	init
	{
		do TABEX(RDVFRT,XFRT,25.0,9);
	}
	
	float TABEX(list<float> VAL, list<float> ARG, float DUMMY, int K)
	{
		float result <- 0.0;
		
		if length(VAL)!=length(ARG)
		{
			K <- min([length(VAL),length(ARG)]);
		}
		
		write "K: "+K;
		
		loop j from: 1 to: K-1 // Mod-->    from:2 -a-> from:1 
		{
			write "j: "+j;
			write "DUMMY: "+DUMMY+" ---- ARG["+j+"]: "+ARG[j];
			
			if (DUMMY < ARG[j])
			{
				write "DUMMY:"+(DUMMY);
				write "ARG[j-1] = ARG["+(j-1)+"]:" + ARG[j-1];
				write "ARG[j] = ARG["+(j)+"]:" + ARG[j];
				write "VAL[j-1] = VAL["+(j-1)+"]:" + VAL[j-1];
				write "VAL[j] = VAL["+(j)+"]:" +VAL[j];
				
				
				result <- (DUMMY - ARG[j-1]) * (VAL[j]-VAL[j-1]) / (ARG[j]-ARG[j-1]) + VAL[j-1];
				
				write "result:" +result;
				break;
			}
			write "--------------------------------------------------------------------";
		}
		
		return result;
	}
	
	
}

experiment exp type: gui 
{
	
}