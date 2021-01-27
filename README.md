# SOE-DTR-2020-Stress-Kurucz

## Bevezetés
Emberünk( legyek mondjuk én) készül a tantárgyaiból és mivel szeret halasztgatni minden egy hétre maradt. Mivel nagyon kemény(annyira nem mert csak egy beadandót képes megcsinálni egy nap) ezért bármilyen stresszes is legyen megcsinálja egy hét alatt mindet. Vasárnap kezdi az egészet és Péntek az utolsó nap( 6 napon keresztül dolgozik) Hogy a stresszt levezesse, közben videójátékokat játszik.

## Beviteli adatok

Adatok táblázatos módon:

|Beadandó tantárgya|Stressz|Idő|
|--|--|--|
|DTR|50|6|
|Önlab|120|12|
|Web1|55|5|
|TermInfo|40|6|
|Szoftver|10|3|
|IRB|20|5|

|Játék neve|Stresszcsökkenés|Idő|Szem romlás szintje|
|--|--|--|--|
|AssassinsCreed|20|4|25|
|CallofDuty|35|5|20|
|GodOfWar|50|6|80|
|Gta|25|3|30|
|RogueCompany|10|1|30|
|AoE2|55|7|50|

Három halmazzal(set) dolgozok.

Az egyik a beadandók halmaza. Minden beadandónak van egy Stressz mennyisége és egy időtartama.

```ampl
set Beadandok;
param Stressz{Beadandok};
param IdoB{Beadandok};
```
A második a játékok halmaza. A játékoknak úgyszintén a stressz és időtartam paraméterei lesznek, kivéve hogy a stresszt majd csökkenteni fogják. Van még egy "SzemGyilok" paraméter. Ez a játék által a szem romlásának szintjét adja meg eg nem létező mértékegysében.

```ampl
set Jatek;
param StresszCsokkenes{Jatek};
param IdoJ{Jatek};
param SzemGyilok{Jatek};

```
A harmadik pedig a napok halmaza. Minden napnak van egy hossza, ami megadja hogy mennyi időt foglalkozunk játékkal és beadandózással.Ezen kívűl van még egy AlapStressz paraméter ami a mindennapi élet stresszét adja meg ami minden Nap beleszámít a szereplőnk stresszszintjébe.

```ampl
set Napok;
param AlapStressz{Napok} ;
param Hossz{Napok};
#s
```
A nem halmazokra vonatkozó paraméterekből egy van.

```ampl
param IdegOsszeroppanasHatar;
```
Mint minden embernek, van egy Idegösszeroppanás határunk ami megadja azta stressz szintet amit nem lenne szabad elérnünk. 

A paramétereken kívűl van még 2 darab bináris változó amik megmutatják hogy egy-egy beadandó kész van-e illetve melyik játékkal játszottunk.0-ás érték a nem 1-es az igen.

```ampl
var kesz{Beadandok,Napok} binary; # kész-e a beadandó
var jatszott{Jatek,Napok} binary; # játszottunk-e a játékkal
```

## Korlátozások
Az első két korlátozás a beadandókkal kapcsolatos. Egyrészt korlátozni kell hogy minden nap elkészüljön egy beadandóval, illetve hogy minden beadandó csak egyszer készüljön el.

```ampl
#minden nap egy beadandó

s.t. MindenNapEgyBeadando{n in Napok}:
  sum{b in Beadandok} kesz[b,n] = 1;
  
# mminden beadandó egyszer
s.t. MindenBeadandoEgyszer{b in Beadandok}:
  sum{n in Napok} kesz[b,n] = 1;
```
A következő kettő korlátozás a Stressz számlálásához kapcsolódik. Az első beállítja hogy a stressz szint nem lépheti át az idegösszeroppanás határát a nap végén.
```ampl
#nem léphetjük át az idegösszeroppanás határát
s.t. NemDoglokMeg {n in Napok} :
	AlapStressz + (sum{n2 in 1..n,b in Beadandok, j in Jatek} Stressz[b] * kesz[b,n2] - (sum{n2 in 1..n,b in Beadandok, j in Jatek} StresszCsokkenes[j] * jatszott[j,n2]))/6 <= IdegOsszeroppanasHatar ;
```
A második pedig beállítja a stressz szint minimumát 0-ra hogy ne érhessünk el negatív stresszt.
```ampl
#a stresszszint nem lehet negatív
s.t. NincsNegativStressz {n in Napok} :
	AlapStressz + (sum{n2 in 1..n,b in Beadandok, j in Jatek} Stressz[b] * kesz[b,n2] - (sum{n2 in 1..n,b in Beadandok, j in Jatek} StresszCsokkenes[j] * jatszott[j,n2]))/6 >= 0;
```
Az utolsó korlátozásunk foglalkozik azzal hogy az emberünk aludjon is. Le kell korlátozni hogy egy nap csak annyi szabadidő legyen amennyit a paraméternek megadtunk
```ampl
#egy nap csak 16 órányi szabadidőnk van

s.t. CannotGoOverTime {n in Napok,b in Beadandok} : 
	sum{j in Jatek} (IdoJ[j] * jatszott[j,n]) + IdoB[b] <= maxIdo;
 ```
 
## Célfüggvény
A modellünk célfüggvényének feladata hogy mire végzünk a beadandókkal minél kevesebbet romoljon a szemünk.
```ampl

minimize SzemRomlas:
	sum{n in Napok,j in Jatek } SzemGyilok[j] * jatszott[j,n];
```

#Kiíratás
Az adatok kiíratásakor kiírásra kerül hogy melyik nap melyik beadandó készül el és melyik játékok voltak játszva.

```ampl
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
```

## Adatok
```ampl
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
```
