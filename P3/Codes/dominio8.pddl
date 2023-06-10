(define (domain Ej8)
    (:requirements :strips :typing :adl :fluents)
    (:types 
        objetoGenerico localizacion TipoUnidad TipoEdificio TipoRecurso - object   
        unidad edificio - objetoGenerico
    )
    (:constants
        VCE Marine Soldado - TipoUnidad
        CentroDeMando Barracones Extractor - TipoEdificio
        Mineral Gas - TipoRecurso
    )
    (:predicates

        ;Edificio o unidad esta en ?l localizacion
        (en ?u - objetoGenerico ?l - localizacion)
        ;Dos localizaciones estan conectadas
        (conectado ?l - localizacion ?l2 - localizacion)

        ;En una localizacion hay un recurso
        (tieneRecurso ?l - localizacion ?r - TipoRecurso)

        ;Esta unidad esta extrayendo un recurso
        (extraerRecurso ?u - unidad)

        ;Si un edificio esta construido
        (edificioConstruido ?e - edificio)

        ;Asignamos tipo a unidad
        (tipoUnidad ?u - unidad ?t - TipoUnidad)

        ;Asignamos tipo a edificio
        (typeEdificio ?e - edificio ?t - TipoEdificio)

        (edificioNecesita ?te - TipoEdificio ?tr - TipoRecurso)

        (obteniendoRecurso ?tr - TipoRecurso)

        ;Que necesitan las unidades como marine o soldado
        (unidadNecesita ?tu - TipoUnidad ?r - TipoRecurso)
        
        ;Tipo de edificio donde se recluta un tipo de unidad
        (sitioRecluta ?tu - TipoUnidad ?te - TipoEdificio)

        ;Si esa unidad esta reclutada
        (unidadReclutada ?u - Unidad)

        ; Muestra si tiene un coste mayor al normal el camino
        ; entre estas dos localizaciones (lo usaremos para los caminos
        ; que tenga un coste de 20)
        (tieneCosteMayor1 ?l1 - localizacion ?l2 - localizacion)

        ; Muestra si tiene un coste mayor al normal el camino
        ; entre estas dos localizaciones (lo usaremos para los caminos
        ; que tenga un coste de 40)
        (tieneCosteMayor2 ?l1 - localizacion ?l2 - localizacion)


  
    )
    (:functions
        ;Coste del plan
        (coste)
        ;Cantidad que se tiene de un tipo de recurso
        (cantidadRecurso ?r - TipoRecurso)
        ;Cantidad necesaria para un tipo de unidad de un tipo de recurso
        (cantidadParaUnidad ?tu - TipoUnidad ?r - TipoRecurso)
        ;Cantidad necesaria para un tipo de edificio de un tipo de recurso
        (cantidadParaEdificio ?te - TipoEdificio ?r - TipoRecurso)
        ;Incremento del recurso cuando se recolecta
        (incrementoRecurso ?tr - TipoRecurso) 
        ;Limite de cantidad de un tipo de recurso
        (maximoRecurso ?tr - TipoRecurso)
        ;Unidades trabajando en una misma localizacion
        (unidadesEnNodo ?l - localizacion)

        ; Coste del tiempo
        (costeTiempo)
        ; Coste en tiempo para reclutar a una unidad de un tipo
        (costeTiempoReclutarUnidad ?tu - TipoUnidad)
        ; Coste en tiempo para construir un edificio de un tipo
        (costeTiempoEdificio ?te - TipoEdificio)
        ; Coste en tiempo de mover un tipo de unidad
        (costeTiempoMover ?tu - TipoUnidad)
        ; Coste en tiempo de recolectar un mineral
        (costeTiempoRecolectar ?tu - TipoRecurso)

    )

    (:action Navegar
        :parameters (?v - unidad ?l1 ?l2 - localizacion )
        :precondition 
            (and 
                ; Si esta en la localización l1 y l1 esta conectado con l2 
                (en ?v ?l1)
                (conectado ?l1 ?l2)
                ; Que la unidad que vamos a mover este reclutada
                (unidadReclutada ?v)
                ; redundante para acotar espacio que la unidad no este en la otra localizacion
                (not (en ?v ?l2))
                ; Que la unidad no esté extrayendo un recurso (estas no se mueven)
                (not (extraerRecurso ?v))
            )
        :effect 
            (and
                ; Hacemos negativo que la unidad este en l1
                (not (en ?v ?l1))
                ; Hacemos que la unidad este en l2
                (en ?v ?l2)
                
                ; Incrementamos el coste
                (increase (coste) 1)

                ; Comprobamos si el camino por el que nos hemos movido pertenece a
                ; uno de los caminos con coste 20 si es asi sumamos al coste tiempo
                ; el coste de dividir 20 / coste del tiempo de mover al VCE
                (when (and(tieneCosteMayor1 ?l1 ?l2)  (tipoUnidad ?v VCE))
                    (increase (costeTiempo) (/ 20 (costeTiempoMover VCE)))
                )

                ; Comprobamos si el camino por el que nos hemos movido pertenece a
                ; uno de los caminos con coste 40 si es asi sumamos al coste tiempo
                ; el coste de dividir 40 / coste del tiempo de mover al VCE
                (when (and(tieneCosteMayor2 ?l1 ?l2) (tipoUnidad ?v VCE))
                    (and
                        (increase (costeTiempo) (/ 40 (costeTiempoMover VCE)))
                    )
                )

                ; Comprobamos si el camino por el que nos hemos movido no pertenece a
                ; uno de los caminos con coste 20 y 40, si es asi sumamos al coste tiempo
                ; el coste de dividir 10 / coste del tiempo de mover al VCE
                (when (and (tipoUnidad ?v VCE) (not(tieneCosteMayor1 ?l1 ?l2)) (not (tieneCosteMayor2 ?l1 ?l2)))
                    (and
                        (increase (costeTiempo) (/ 10 (costeTiempoMover VCE)))
                    )
                )

                ; Comprobamos si el camino por el que nos hemos movido pertenece a
                ; uno de los caminos con coste 20 si es asi sumamos al coste tiempo
                ; el coste de dividir 20 / coste del tiempo de mover al Soldado
                (when (and(tieneCosteMayor1 ?l1 ?l2)  (tipoUnidad ?v Soldado))
                    (increase (costeTiempo) (/ 20 (costeTiempoMover Soldado)))
                )

                ; Comprobamos si el camino por el que nos hemos movido pertenece a
                ; uno de los caminos con coste 40 si es asi sumamos al coste tiempo
                ; el coste de dividir 40 / coste del tiempo de mover al Soldado
                (when (and(tieneCosteMayor2 ?l1 ?l2) (tipoUnidad ?v Soldado))
                    (and
                        (increase (costeTiempo) (/ 40 (costeTiempoMover Soldado)))
                    )
                )

                ; Comprobamos si el camino por el que nos hemos movido no pertenece a
                ; uno de los caminos con coste 20 y 40, si es asi sumamos al coste tiempo
                ; el coste de dividir 10 / coste del tiempo de mover al Soldado
                (when (and (tipoUnidad ?v Soldado) (not(tieneCosteMayor1 ?l1 ?l2)) (not (tieneCosteMayor2 ?l1 ?l2)))
                    (and
                        (increase (costeTiempo) (/ 10 (costeTiempoMover Soldado)))
                    )
                )

                ; Comprobamos si el camino por el que nos hemos movido pertenece a
                ; uno de los caminos con coste 20 si es asi sumamos al coste tiempo
                ; el coste de dividir 20 / coste del tiempo de mover al Marine
                (when (and(tieneCosteMayor1 ?l1 ?l2)  (tipoUnidad ?v Marine))
                    (increase (costeTiempo) (/ 20 (costeTiempoMover Marine)))
                )

                ; Comprobamos si el camino por el que nos hemos movido pertenece a
                ; uno de los caminos con coste 40 si es asi sumamos al coste tiempo
                ; el coste de dividir 40 / coste del tiempo de mover al Marine
                (when (and(tieneCosteMayor2 ?l1 ?l2) (tipoUnidad ?v Marine))
                    (and
                        (increase (costeTiempo) (/ 40 (costeTiempoMover Marine)))
                    )
                )

                ; Comprobamos si el camino por el que nos hemos movido no pertenece a
                ; uno de los caminos con coste 20 y 40, si es asi sumamos al coste tiempo
                ; el coste de dividir 10 / coste del tiempo de mover al Marine
                (when (and (tipoUnidad ?v Marine) (not(tieneCosteMayor1 ?l1 ?l2)) (not (tieneCosteMayor2 ?l1 ?l2)))
                    (and
                        (increase (costeTiempo) (/ 10 (costeTiempoMover Marine)))
                    )
                )
   
            )
    )

    (:action Asignar
        :parameters (?v - unidad ?l1 - localizacion)
        :precondition 
            (and 

                ; Si la unidad esta en la localización l1
                (en ?v ?l1)
                ; Si la unidad v no está ya asignada extrayendo un recurso
                (not (extraerRecurso ?v)) 
                ; Miramos que la unidad que vamos a asignar sea de tipo VCE
                (tipoUnidad ?v VCE)

                ; Comprobamos si existe un recurso
                (exists (?tr - TipoRecurso)(and
                    ; Que la localizacion l1 tenga ese recurso
                    (tieneRecurso ?l1 ?tr)

                    ; Si el recurso que tiene la localizacion es GAS
                    ; debemos ver si existe un edificio construido
                    ; en la localización l1 y que sea de tipo
                    ; EXTRACTOR
                    (imply (tieneRecurso ?l1 Gas)
                        (and
                            (exists (?e - edificio) 
                                (and
                                    (edificioConstruido ?e)
                                    (typeEdificio ?e Extractor)
                                    (en ?e ?l1)
                                )
                            )
                        )
                    ))
                
                )      
            )
        :effect 
          (and

            ; Si el recurso es de tipo Gas el que
            ; esta en la localización l1
            ; decimos que la unidad v está extrayendo recursos
            ; y que uno de los recursos que obtenemos es de tipo Gas  
            (when (and(tieneRecurso ?l1 Gas))
                (and
                    (extraerRecurso ?v)
                    (obteniendoRecurso Gas)
                )
            )

            ; Si el recurso es de tipo Mineral el que
            ; esta en la localización l1
            ; decimos que la unidad v está extrayendo recursos
            ; y que uno de los recursos que obtenemos es de tipo Mineral
            (when (and(tieneRecurso ?l1 Mineral))
                (and
                    (extraerRecurso ?v)
                    (obteniendoRecurso Mineral)
                )
            )

            ; Incrementamos el coste del plan
            (increase (coste) 1)
            ; Incrementamos el número de unidades trabajando en l1
            (increase (unidadesEnNodo ?l1) 1)

        ) 
            
    )

    (:action Construir
        :parameters (?v - unidad ?e - edificio ?l1 - localizacion )
        :precondition 
            (and 

                ; Comprobamos que la unidad este en l1
                (en ?v ?l1)
                ; Que la unidad no este ocupada extrayendo recursos
                (not (extraerRecurso ?v))

                ; Que el edificio que vamos a construir no este construido
                (not (en ?e ?l1))
                ; Que el edificio no este en la localización l1 (redundante para acotar espacio de busqueda)   
                (not (edificioConstruido ?e)) 

                ; Comprobamos que no haya ya un edificio construido en
                ; esta localización
                (not 
                    (exists (?ed - edificio)
                        (en ?ed ?l1)
                    )
                ) 

                ; Comprobamos que la unidad que va a construir sea de tipo VCE
                (tipoUnidad ?v VCE)          

                ; Comprobamos si existe un tipo de edificio que sea el que vamos a construir                                                
                (exists (?tp - TipoEdificio)
                    (and                 
                       (typeEdificio ?e ?tp)
                        
                        ; Comprobamos para todos los recursos   
                        (forall (?r - TipoRecurso)
                         (or
                            ; Si no lo necesitamos para nuestro tipo de edificio
                            (not(edificioNecesita ?tp ?r))
                            ; Si lo necesitamos, lo estamos obteniendo y tenemos una cantidad
                            ; mayor o igual de la necesaria para construir el edificio
                            (and
                                   (edificioNecesita ?tp ?r)
                                   (obteniendoRecurso ?r)
                                   (>= (cantidadRecurso ?r) (cantidadParaEdificio ?tp ?r))
                               )
                               
                           )
                        )

                    )
                )
 
            )
        :effect 
            (and
                ; Construimos el edificio
                (edificioConstruido ?e)
                ; Decimos que el edificio esta en la localizacion l1
                (en ?e ?l1)

                ; Si el tipo de edificio es Barracones decrementamos las cantidades
                ; de recursos que tenemos en las necesarias para contruir un edificio de ese tipo
                ; incrementamos el coste de tiempo en el timepo que cueste construir los barracones
                (when (and (typeEdificio ?e Barracones)) 
                    (and
                        (decrease (cantidadRecurso Gas) 10)
                        (decrease (cantidadRecurso Mineral) 40)
                        (increase (costeTiempo) (costeTiempoEdificio Barracones))
                    )
                )

                ; Si el tipo de edificio es Extractor decrementamos las cantidades
                ; de recursos que tenemos en las necesarias para contruir un edificio de ese tipo    
                ; incrementamos el coste de tiempo en el tiempo que cueste construir el Extractor            
                (when (and (typeEdificio ?e Extractor)) 
                    (and
                        (decrease (cantidadRecurso Mineral) (cantidadParaEdificio Extractor Mineral))
                        (decrease (cantidadRecurso Gas) 0)
                        (increase (costeTiempo) (costeTiempoEdificio Extractor))
                    )
                )

                ; Incrementamos el coste del plan
                (increase (coste) 1)          
                
            )
    )

    (:action Reclutar
        :parameters (?e - edificio ?u - unidad ?l - localizacion)
        :precondition (and
            ; Comprobamos que haya un edificio en la localizacion l1
            (en ?e ?l)             
            
            ; Que el edificio este constuido
            (edificioConstruido ?e)

            ; Que la unidad que vamos a reclutar no este ya reclutada
            (not (unidadReclutada ?u))
            ; (redundante) que la unidad no este en una localizacion
            (not (en ?u ?l))
            ; (redundante) que la unidad no este extrayendo un recurso
            (not (extraerRecurso ?u))

            ; Para cada tipo de unidad
            (exists (?tu - TipoUnidad)
                (and
                    ; Si la unidad que vamos a reclutar es de ese tipo de unidad
                    (tipoUnidad ?u ?tu)

                    ; Comprobamos que el edificio que hay construido sea el necesario para
                    ; reclutar a esa unidad 
                    (exists (?te - TipoEdificio) (and (typeEdificio ?e ?te) (sitioRecluta ?tu ?te)))                
                    
                    ; Comprobamos para todos los recursos
                    (forall (?r - TipoRecurso)
                        (or
                            ; O bien no lo necesitamos para reclutar
                            (not (unidadNecesita ?tu ?r))
                            ; O bien lo necesitamos, lo estamos obteniendo y tenemos los mismos o mas
                            ; recursos necesarios para reclutar esa unidad
                            (and
                                (unidadNecesita ?tu ?r)
                                (obteniendoRecurso ?r)
                                (>= (cantidadRecurso ?r) (cantidadParaUnidad ?tu ?r))
                            )
                        )
                    )
                )
            )

        )
        :effect (and
            ; Ponemos que hemos reclutado la unidad
            (unidadReclutada ?u)
            ; Ponemos que esa unidad se encuentra en la localización l1
            (en ?u ?l)

            ; Si es de tipo Marine lo que hacemos es decrementar sobre el total de
            ; recursos que tenemos los materiales necesarios para reclutar la unidad
            ; incrementamos el coste de tiempo en el coste de tiempo necesario para reclutar esa unidad
            (when  (tipoUnidad ?u Marine)
                (and
                    (decrease (cantidadRecurso Mineral) (cantidadParaUnidad Marine Mineral))
                    (decrease (cantidadRecurso Gas) (cantidadParaUnidad Marine Gas))
                    (increase (costeTiempo) (costeTiempoReclutarUnidad Marine))

                )
            )

            ; Si es de tipo Soldado lo que hacemos es decrementar sobre el total de
            ; recursos que tenemos los materiales necesarios para reclutar la unidad
            ; incrementamos el coste de tiempo en el coste de tiempo necesario para reclutar esa unidad
            (when (tipoUnidad ?u Soldado)
                (and
                    (decrease (cantidadRecurso Mineral) (cantidadParaUnidad Soldado Mineral))
                    (decrease (cantidadRecurso Gas) (cantidadParaUnidad Soldado Gas))
                    (increase (costeTiempo) (costeTiempoReclutarUnidad Soldado))

                )
            )

            ; Si es de tipo VCE lo que hacemos es decrementar sobre el total de
            ; recursos que tenemos los materiales necesarios para reclutar la unidad
            ; incrementamos el coste de tiempo en el coste de tiempo necesario para reclutar esa unidad
            (when (tipoUnidad ?u VCE)
                (and
                    (decrease (cantidadRecurso Mineral) (cantidadParaUnidad VCE Mineral))
                    (increase (costeTiempo) (costeTiempoReclutarUnidad VCE))
                )
            )
            
            ; Incrementamos el coste del plan
            (increase (coste) 1)

        )
    )

    (:action Recolectar
        :parameters (?tr - TipoRecurso ?l1 - localizacion)
        :precondition (and
            (tieneRecurso ?l1 ?tr)

            (obteniendoRecurso ?tr)
        
            (<= (+ (cantidadRecurso ?tr) (* (incrementoRecurso ?tr) (unidadesEnNodo ?l1))) (maximoRecurso ?tr))

            (exists (?u - unidad) 
                (and
                    (en ?u ?l1)
                    (extraerRecurso ?u)
                    (tipoUnidad ?u VCE)
                )
            )
 
        )
        :effect (and
            
            (increase (coste) 1)
            (increase (costeTiempo) (costeTiempoRecolectar ?tr))
            (increase (cantidadRecurso ?tr) (* (incrementoRecurso ?tr) (unidadesEnNodo ?l1)))


        )
    )

    

)