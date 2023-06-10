enum Trabajador = {Trabajador1, Trabajador2, Trabajador3};
enum Tarea = {A, B, C, D, E, F, G, H, I, J};

array[Tarea, Trabajador] of int: duraciones = array2d(Tarea, Trabajador, [
    5, 7, 10,  % A
    3, 5, 7,  % B
    3, 2, 4,  % C
    2, 5, 8,  % D
    4, 3, 6,  % E
    3, 2, 1,  % F
    2, 2, 3,  % G
    1, 3, 5,  % H
    2, 3, 4,  % I
    3, 2, 1  % J
]);

% Se hacen A -> B,D,H  --> C --> E,G --> F --> I ---> J
array[Tarea] of set of Tarea: precedencias = [
    {},     % A
    {A},    % B
    {B},    % C
    {A},    % D
    {C, D}, % E
    {C, D, E}, % F
    {C, D}, % G
    {A},    % H
    {F, H}, % I
    {G, I}  % J
];

array[Tarea, Trabajador] of var 0..99: inicio;
array[Tarea, Trabajador] of var 1..3: inicio_tr;

%Rellenamos un tabla a la cual a cada tarea le vamos asignando el tiempo minimo de las tareas que tiene como precedencia que acabo antes
%ya que ese trabajador quedo libre y ya puede iniciar la nueva tarea
constraint forall(t in Tarea,  p in precedencias[t], t2 in Tarea where t2 in precedencias[t])(
    forall(trab in Trabajador)(
        if duraciones[p,trab] >= 2 then
        inicio[t, trab] >= min(inicio[p, Trabajador]) + duraciones[p,trab] - 1 
        else
        inicio[t, trab] >= min(inicio[p, Trabajador]) + duraciones[p,trab]
        endif
    )
);

%Rellenamos el vector que nos dirá el dia de comienzo de cada tarea
array [Tarea] of var 0..99: dias_inicio_tarea;
constraint forall(t in Tarea)(
  dias_inicio_tarea[t] = min(inicio[t, Trabajador])
);

var int: tiempo_finalizacion = min([inicio[J, trab] + duraciones[J, trab2] | trab,trab2 in Trabajador]);
solve minimize tiempo_finalizacion;

output ["Inicio de cada una de las tareas: \(dias_inicio_tarea)\n"];
output ["Duración total: \(tiempo_finalizacion)\n"];

