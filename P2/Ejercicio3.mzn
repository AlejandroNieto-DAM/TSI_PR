set of int: XPOS = 1..6;
set of int: YPOS = 1..5;
array [XPOS,YPOS] of var 1..10: grid;

%Ajustamos el valor del recreo para la franja de la 4ta hora
constraint forall(j in YPOS)(grid[4,j] = 10);

%Asignaturas que se pueden impartir el lunes
constraint forall(i in XPOS)(grid[i,1] = 10 \/ grid[i,1] = 2 \/ grid[i,1] = 1 \/ grid[i,1] = 4 \/ grid[i,1] = 9);
%Asignaturas que se pueden impartir el martes
constraint forall(i in XPOS)(grid[i,2] = 10 \/ grid[i,2] = 2 \/ grid[i,2] = 1 \/ grid[i,2] = 4 \/ grid[i,2] = 7);
%Asignaturas que se pueden impartir el miercoles
constraint forall(i in XPOS)(grid[i,3] = 10 \/ grid[i,3] = 2 \/ grid[i,3] = 3 \/ grid[i,3] = 6 \/ grid[i,3] = 8);
%Asignaturas que se pueden impartir el jueves
constraint forall(i in XPOS)(grid[i,4] = 10 \/ grid[i,4] = 2 \/ grid[i,4] = 3 \/ grid[i,4] = 5);
%Asignaturas que se pueden impartir el viernes
constraint forall(i in XPOS)(grid[i,5] = 10 \/ grid[i,5] = 2 \/ grid[i,5] = 6 \/ grid[i,5] = 7 \/ grid[i,5] = 5);

%Asignaturas que se pueden dar las 3 primeras horas de la mañana
constraint forall(i in 1..3, j in YPOS)(grid[i,j] = 2 \/ grid[i,j] = 4 \/ grid[i,j] = 5 \/ grid[i,j] = 6 \/ grid[i,j] = 7 \/ grid[i,j] = 8 \/ grid[i,j] = 9);
%Asignaturas que se pueden dar las 2 ultimas horas de la mañana
constraint forall(i in 5..6, j in YPOS)(grid[i,j] = 1 \/ grid[i,j] = 3 \/ grid[i,j] = 2 \/ grid[i,j] = 7 \/ grid[i,j] = 8);
%Asignaturas se pueden dar solo a 3ra hora
constraint forall(i in 1..2, j in YPOS)(grid[i,j] != 6 /\ grid[i,j] != 9);

%Asignaturas que se deben dar en bloques de 2 horas seguidas
constraint forall(j in YPOS)(if grid[5,j] == 1 then grid[6,j] = 1 else (if grid[5,j] == 3 then grid[6,j] = 3 endif) endif);
constraint forall(j in YPOS)(if grid[1,j] == 4 then grid[2,j] = 4 /\ grid[3,j] != 4 else (if grid[2,j] == 4 then grid[3,j] = 4 /\ grid[1,j] != 4 endif) endif);
constraint forall(j in YPOS)(if grid[1,j] == 5 then grid[2,j] = 5 /\ grid[3,j] != 5 else (if grid[2,j] == 5 then grid[3,j] = 5 /\ grid[1,j] != 5 endif) endif);
constraint forall(j in YPOS)(if grid[1,j] == 8 then grid[2,j] = 8 /\ grid[3,j] != 8 else (if grid[2,j] == 8 then grid[3,j] = 8 /\ grid[1,j] != 8 endif) endif);

%Asignaturas que no se imparten en bloques de 2 horas por lo que no pueden tener dos horas seguidas
constraint forall(i in YPOS, j in YPOS)(if grid[i,j] == 7 then grid[i+1,j] != 7  endif);
constraint forall(i in YPOS, j in YPOS)(if grid[i,j] == 2 then grid[i+1,j] != 2  endif);
constraint forall(i in YPOS, j in YPOS)(if grid[i,j] == 6 then grid[i+1,j] != 6  endif);
constraint forall(i in YPOS, j in YPOS)(if grid[i,j] == 9 then grid[i+1,j] != 9  endif);


%Sumatorias para hacer que se impartan tantos bloques como los especificados de cada asignatura
var int : s1 = sum( [if grid[i,j]==1 then 1 else 0 endif  | i in XPOS, j in YPOS ]);
var int : s2 = sum( [if grid[i,j]==2 then 1 else 0 endif  | i in XPOS, j in YPOS ]);
var int : s3 = sum( [if grid[i,j]==3 then 1 else 0 endif  | i in XPOS, j in YPOS ]);
var int : s4 = sum( [if grid[i,j]==4 then 1 else 0 endif  | i in XPOS, j in YPOS ]);
var int : s5 = sum( [if grid[i,j]==5 then 1 else 0 endif  | i in XPOS, j in YPOS ]);
var int : s6 = sum( [if grid[i,j]==6 then 1 else 0 endif  | i in XPOS, j in YPOS ]);
var int : s7 = sum( [if grid[i,j]==7 then 1 else 0 endif  | i in XPOS, j in YPOS ]);
var int : s8 = sum( [if grid[i,j]==8 then 1 else 0 endif  | i in XPOS, j in YPOS ]);
var int : s9 = sum( [if grid[i,j]==9 then 1 else 0 endif  | i in XPOS, j in YPOS ]);

constraint s1 = 4;
constraint s2 = 2;
constraint s3 = 4;
constraint s4 = 4;
constraint s5 = 4;
constraint s6 = 2;
constraint s7 = 2;
constraint s8 = 2;
constraint s9 = 1;

solve satisfy;


output [ "DIA       \tL\tM\tX\tJ\tV "] ;
output [ "\n8.00-9.00: "] ++ [ "\tA\(grid[1,j]) " | j in YPOS ] ;
output [ "\n9.00-10.00: "] ++ [ "\tA\(grid[2,j]) " | j in YPOS ] ;
output [ "\n10.00-11.00: "] ++ [ "\tA\(grid[3,j]) " | j in YPOS ] ;
output [ "\n11.00-12.00: "] ++ [ "\tR " | j in YPOS ] ;
output [ "\n12.00-13.00: "] ++ [ "\tA\(grid[5,j]) " | j in YPOS ] ;
output [ "\n13.00-14.00: "] ++ [ "\tA\(grid[6,j]) " | j in YPOS ] ;
