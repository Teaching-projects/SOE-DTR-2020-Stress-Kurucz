# SOE-DTR-2020-Stress-Kurucz

## Bevezetés
Emberünk( legyek mondjuk én) készül a tantárgyaiból és mivel szeret halasztgatni minden egy hétre maradt. Mivel nagyon kemény ezért bármilyen stresszes is legyen megcsinálja egy hét alatt mindet. Vasárnap kezdi az egészet és Péntek az utolsó nap( 6 napon keresztül dolgozik) Hogy a stresszt levezesse, közben videójátékokat játszik.

## Beviteli adatok

Adatok táblázatos módon:

|Beadandó tantárgya| Stressz |Idő|
|--|--|
|DTR|50|6|
|Önlab|120|12|
|Web1|55|5|
|TermInfo|40|6|
|Szoftver|10|3|
|IRB|20|5|

|Játék neve| StresszCsökkenés |Idő|
|--|--|
|AssassinsCreed|20|4|
|CallofDuty|35|5|
|GodOfWar|50|6|
|Gta|25|3|
|RogueCompany|10|1|
|AoE2|55|7|

Három halmazzal(set) dolgozok.

Az egyik a beadandók halmaza. Minden beadandónak van egy Stressz mennyisége és egy időtartama.

```ampl
set Beadandok;
param Stressz{Beadandok};
param IdoB{Beadandok};
```
A második a játékok halmaza. A játékoknak úgyszintén a stressz és időtartam paraméterei lesznek, kivéve hogy a stresszt majd csökkenteni fogják.

```ampl
set Jatek;
param StresszCsokkenes{Jatek};
param IdoJ{Jatek};
```
A harmadik pedig a napok halmaza. A Napok számát egy paraméterrel adjuk meg ezáltal lehet változtatni a beadandókra való hosszát napokban mérve ha akarjuk.

```ampl
param napokszama;
set Napok:= 1..napokszama ;
```
A nem halmazokra vonatkozó paraméterekből három van.

```ampl
param maxIdo;
param IdegOsszeroppanasHatar;
param AlapStressz;
```
A maxIdo megadja hogy egy nap mennyi időt tölthetünk el beadandózással és játékkal hiszen szeretnénk aludni is. Mint minden embernek, van egy Idegösszeroppanás határunk ami megadja azta stressz szintet amit nem lenne szabad elérnünk. Ezen kívűl van még egy AlapStressz paraméter ami a mindennapi élet stresszét adja meg ami minden Nap beleszámít a szereplőnk stresszszintjébe.
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
A modellünk célfüggvényének feladata hogy mire végzünk a beadandókkal minimális stressz szintet érjünk el.
```ampl
minimize StresszSzint:
	AlapStressz + (sum{b in Beadandok, j in Jatek, n in Napok} Stressz[b] * kesz[b,n] - (sum{b in Beadandok, j in Jatek,n in Napok} StresszCsokkenes[j] * jatszott[j,n]))/6;
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

```
