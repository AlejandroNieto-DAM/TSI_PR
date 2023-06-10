include "globals.mzn";

int : N = 12;
array[1..N] of var 0..10000: arr_marcas;

%La primera marca la ponemos a 0
constraint arr_marcas[1] = 0;
%Las marcas en adelante deben ser mayores que las de atras
constraint forall(i in 2..N)( arr_marcas[i] > arr_marcas[i-1]);
%Queremos que todas las diferencias entre marcas sean diferentes
constraint all_different( [ (arr_marcas[i] - arr_marcas[j]) | i,j in 1..N where i != j] );

solve minimize arr_marcas[N];


output [ "Posicion marcas: "] ++ [  "\(arr_marcas[i]) " | i in 1..N ] ;
