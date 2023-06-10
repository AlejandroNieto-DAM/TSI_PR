int : N = 20;

%array[1..N] of var 1..99 : myarray =  [99,14,82,47,82,50,77,45,23,92,52,90,46,57,29,25,74,25,30,70];
%array[1..N] of var 1..99 : myarray = [60,8,11,2,49,69,87,15,62,72,89,14,76,63,45,92,74,80,11,2];
array[1..N] of var 1..99 : myarray = [35,82,97,30,38,78,18,39,35,93,49,47,30,57,43,21,92,51,89,80];


array[1..N] of var -1..1: myarrayshape;


%La idea es tener un vector con tantos valores como el array original y lo que haremos sera
%asignar un valor 1 a los que forman parte del primer conjunto y un valor -1 a los que son del conjunto 2
%por lo que al hacer la sumatoria de los valores del vector por el valor del conjunto al que pertenecen
%este debe ser minimo.
constraint forall(i in 1..N)( myarrayshape[i] != 0);
constraint sum(i in 1..N)(myarray[i] * myarrayshape[i]) >= 0;

var int : s1 = sum( [if myarrayshape[i]==1 then myarray[i] else 0 endif  | i in 1..N ]);
var int : s2 = sum( [if myarrayshape[i]==-1 then myarray[i] else 0 endif | i in 1..N ]);

solve minimize sum(i in 1..N)(myarray[i] * myarrayshape[i]);

output [ "S1: "] ++ [ if fix(myarrayshape[i])==1 then "\(myarray[i]) " endif | i in 1..N ] ;
output [ "\nS2: "] ++ [ if fix(myarrayshape[i])==-1 then "\(myarray[i]) " endif | i in 1..N ] ;

output ["\nSUM S1: "] ++ ["\(s1) "];
output ["\nSUM S2: "] ++ ["\(s2) "];
output ["\nDIFF: "] ++ ["\(s1-s2) "];