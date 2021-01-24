#input

set Beadandok;
param Stressz{Beadandok};
param IdoB{Beadandok};


set Jatek;
param StresszCsokkenes{Jatek};
param IdoJ{Jatek};


param IdegOsszeroppanasHatar;

param AlapStressz;

param napokszama;
set Napok:= 1..napokszama ;

#s

#variables


var kesz{Beadandok,Napok} binary;
var jatszott{Jatek,Napok} binary;





#constraints


#minden nap egy beadandó

s.t. MindenNapEgyBeadando{n in Napok}:
  sum{b in Beadandok} kesz[b,n] = 1;
  
s.t. MindenBeadandoEgyszer{b in Beadandok}:
  sum{n in Napok} kesz[b,n] = 1;
  
#egy játékot csak egyszer játszunk 

/*s.t. EgyJatekEgyszer{j in Jatek}:
	sum{n in Napok} jatszott[j,n] = 1;*/
	
/*s.t. MindenNapEgyJatek{n in Napok}:
  sum{j in Jatek} jatszott[j,n] = 1;
*/

#nem léphetjük át az idegösszeroppanás határát
s.t. NemDoglokMeg {n in Napok} :
	AlapStressz + sum{b in Beadandok, j in Jatek} Stressz[b] * kesz[b,n] - (sum{b in Beadandok, j in Jatek} StresszCsokkenes[j] * jatszott[j,n]) <= IdegOsszeroppanasHatar ;
	
#a stresszszint nem lehet negatív
s.t. NincsNegativStressz {n in Napok} :
	AlapStressz + sum{b in Beadandok, j in Jatek} Stressz[b] * kesz[b,n] - (sum{b in Beadandok, j in Jatek} StresszCsokkenes[j] * jatszott[j,n]) >= 0;

#obj function

minimize StresszSzint:
	AlapStressz + sum{b in Beadandok, j in Jatek, n in Napok} Stressz[b] * kesz[b,n] - (sum{b in Beadandok, j in Jatek,n in Napok} StresszCsokkenes[j] * jatszott[j,n]);



#display
solve;
for{n in Napok}
{
	printf " Nap : %s\n", n ;
	for {b in Beadandok: kesz[b,n] > 0}
		printf " Beadandó: %s\n",b;
	for {j in Jatek: jatszott[j,n] > 0}
		printf " Játék: %s\n",j;
}


#data
data;

set Beadandok:= DTR ONLAB WEB1 TERMINFO SZOFTVER IRB;

param: 		Stressz		IdoB:=
DTR			50			6
ONLAB		120			12
WEB1		40			7
TERMINFO	25			6
SZOFTVER	10			3
IRB			20			5

;

set Jatek:= AssassinsCreed Dishonored CallofDuty GodOfWar Gta RogueCompany;

param:			StresszCsokkenes		IdoJ:=
AssassinsCreed	20						5
Dishonored		25						2
CallofDuty		35						4
GodOfWar		50						3
Gta				25						5
RogueCompany	10						7
;

param napokszama:= 6;

param AlapStressz:= 0 ;
param IdegOsszeroppanasHatar:= 100;

end; 
