#input

set Beadandok;
param Stressz{Beadandok};
param IdoB{Beadandok};	#�ra


set Jatek;
param StresszCsokkenes{Jatek};
param IdoJ{Jatek};	#�ra
param SzemGyilok{Jatek};


param IdegOsszeroppanasHatar;



set Napok;
param AlapStressz{Napok} ;
param Hossz{Napok};
#s

#variables


var kesz{Beadandok,Napok} binary; # k�sz-e a beadand�
var jatszott{Jatek,Napok} binary; # j�tszottunk-e a j�t�kkal






#constraints


#minden nap egy beadand�

s.t. MindenNapEgyBeadando{n in Napok}:
  sum{b in Beadandok} kesz[b,n] = 1;
  
# mminden beadand� egyszer
s.t. MindenBeadandoEgyszer{b in Beadandok}:
  sum{n in Napok} kesz[b,n] = 1;


#nem l�phetj�k �t az ideg�sszeroppan�s hat�r�t
s.t. NemDoglokMeg {n in Napok} :
	AlapStressz[n] + (sum{n2 in 1..n,b in Beadandok, j in Jatek} Stressz[b] * kesz[b,n2] - (sum{n2 in 1..n,b in Beadandok, j in Jatek} StresszCsokkenes[j] * jatszott[j,n2]))/6 <= IdegOsszeroppanasHatar ;
	
#a stresszszint nem lehet negat�v
s.t. NincsNegativStressz {n in Napok} :
	AlapStressz[n] + (sum{n2 in 1..n,b in Beadandok, j in Jatek} Stressz[b] * kesz[b,n2] - (sum{n2 in 1..n,b in Beadandok, j in Jatek} StresszCsokkenes[j] * jatszott[j,n2]))/6 >= 0;


#egy nap csak 16 �r�nyi szabadid�nk van

s.t. CannotGoOverTime {n in Napok,b in Beadandok} : 
	sum{j in Jatek} (IdoJ[j] * jatszott[j,n]) + IdoB[b] <= Hossz[n];



#obj function

minimize SzemRomlas:
	sum{n in Napok,j in Jatek } SzemGyilok[j] * jatszott[j,n];



#display
solve;
for{n in Napok}
{
	printf " Nap : %s\n", n ;
	for {b in Beadandok: kesz[b,n] > 0}
		printf " Beadand�: %s\n",b;
	for {j in Jatek: jatszott[j,n] > 0}
		printf " J�t�k: %s\n",j;
}


#data
data;

set Beadandok:= DTR ONLAB WEB1 TERMINFO SZOFTVER IRB;

param: 		Stressz		IdoB:=
DTR			50			5
ONLAB		120			10
WEB1		55			3
TERMINFO	40			4
SZOFTVER	10			2
IRB			20			4

;

set Jatek:= AssassinsCreed CallofDuty GodOfWar Gta RogueCompany AoE2;
	
param:			StresszCsokkenes		IdoJ	SzemGyilok:=
AssassinsCreed	20						4		25
CallofDuty		35						4		20
GodOfWar		50						6		80
Gta				25						3		30
RogueCompany	10						1		30
AoE2			55						7		50
;

set Napok:= 1	2	3	4	5	6;

param:		AlapStressz Hossz:=
1	10			16
2		20			14
3		10			16
4		10			12
5	30			12
6		15			18
;


param IdegOsszeroppanasHatar:= 100;

end; 
