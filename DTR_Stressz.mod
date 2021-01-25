#input

set Beadandok;
param Stressz{Beadandok};
param IdoB{Beadandok};


set Jatek;
param StresszCsokkenes{Jatek};
param IdoJ{Jatek};

param maxIdo;

param IdegOsszeroppanasHatar;

param AlapStressz;

param napokszama;
set Napok:= 1..napokszama ;

#s

#variables


var kesz{Beadandok,Napok} binary;
var jatszott{Jatek,Napok} binary;

var elteltIdo{Napok,Jatek};





#constraints


#minden nap egy beadandó

s.t. MindenNapEgyBeadando{n in Napok}:
  sum{b in Beadandok} kesz[b,n] = 1;
  
# mminden beadandó egyszer
s.t. MindenBeadandoEgyszer{b in Beadandok}:
  sum{n in Napok} kesz[b,n] = 1;


#nem léphetjük át az idegösszeroppanás határát
s.t. NemDoglokMeg {n in Napok} :
	AlapStressz + (sum{n2 in 1..n,b in Beadandok, j in Jatek} Stressz[b] * kesz[b,n2] - (sum{n2 in 1..n,b in Beadandok, j in Jatek} StresszCsokkenes[j] * jatszott[j,n2]))/6 <= IdegOsszeroppanasHatar ;
	
#a stresszszint nem lehet negatív
s.t. NincsNegativStressz {n in Napok} :
	AlapStressz + (sum{n2 in 1..n,b in Beadandok, j in Jatek} Stressz[b] * kesz[b,n2] - (sum{n2 in 1..n,b in Beadandok, j in Jatek} StresszCsokkenes[j] * jatszott[j,n2]))/6 >= 0;


#egy nap csak 16 órányi szabadidõnk van

s.t. CannotGoOverTime {n in Napok,b in Beadandok} : 
	sum{j in Jatek} (IdoJ[j] * jatszott[j,n]) + IdoB[b] <= maxIdo;



#obj function

minimize StresszSzint:
	AlapStressz + (sum{b in Beadandok, j in Jatek, n in Napok} Stressz[b] * kesz[b,n] - (sum{b in Beadandok, j in Jatek,n in Napok} StresszCsokkenes[j] * jatszott[j,n]))/6;



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
WEB1		55			5
TERMINFO	40			6
SZOFTVER	10			3
IRB			20			5

;

set Jatek:= AssassinsCreed CallofDuty GodOfWar Gta RogueCompany AoE2;

param:			StresszCsokkenes		IdoJ:=
AssassinsCreed	20						4
CallofDuty		35						5
GodOfWar		50						6
Gta				25						3
RogueCompany	10						1
AoE2			55						7
;

param napokszama:= 6;

param maxIdo :=  16;
param AlapStressz:= 0 ;
param IdegOsszeroppanasHatar:= 100;

end; 
