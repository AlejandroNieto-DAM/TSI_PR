(define (domain Ej7)
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
        
        ;Recurso que necesita un tipo de edificio
        (edificioNecesita ?te - TipoEdificio ?tr - TipoRecurso)

        ;Si se esta obteniendo ese recurso
        (obteniendoRecurso ?tr - TipoRecurso)

        ;Que necesitan las unidades como marine o soldado
        (unidadNecesita ?tu - TipoUnidad ?r - TipoRecurso)

        ;Tipo de edificio donde se recluta un tipo de unidad
        (sitioRecluta ?tu - TipoUnidad ?te - TipoEdificio)

        ;Si esa unidad esta reclutada
        (unidadReclutada ?u - Unidad)
  
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

            ; Incrementamos el número de unidades trabajando en l1
            (increase (unidadesEnNodo ?l1) 1)

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
                (when (and (typeEdificio ?e Barracones)) 
                    (and
                        (decrease (cantidadRecurso Gas) (cantidadParaEdificio Barracones Gas))
                        (decrease (cantidadRecurso Mineral) (cantidadParaEdificio Barracones Mineral))
                    )
                )

                ; Si el tipo de edificio es Extractor decrementamos las cantidades
                ; de recursos que tenemos en las necesarias para contruir un edificio de ese tipo
                (when (and (typeEdificio ?e Extractor)) 
                    (and
                        (decrease (cantidadRecurso Mineral) (cantidadParaEdificio Extractor Mineral))
                        (decrease (cantidadRecurso Gas) (cantidadParaEdificio Extractor Gas))

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

            ; Si es de tipo Soldado lo que hacemos es decrementar sobre el total de
            ; recursos que tenemos los materiales necesarios para reclutar la unidad
            (when (and (tipoUnidad ?u Soldado)) 
                (and
                    (decrease (cantidadRecurso Mineral) (cantidadParaUnidad Soldado Mineral))
                    (decrease (cantidadRecurso Gas) (cantidadParaUnidad Soldado Gas))
                )
            )

            ; Si es de tipo VCE lo que hacemos es decrementar sobre el total de
            ; recursos que tenemos los materiales necesarios para reclutar la unidad
            (when (and (tipoUnidad ?u VCE)) 
                (and
                    (decrease (cantidadRecurso Mineral) (cantidadParaUnidad VCE Mineral))
                )
            )

            ; Si es de tipo Marine lo que hacemos es decrementar sobre el total de
            ; recursos que tenemos los materiales necesarios para reclutar la unidad
            (when (and (tipoUnidad ?u Marine)) 
                (and
                    (decrease (cantidadRecurso Mineral) (cantidadParaUnidad Marine Mineral))
                    (decrease (cantidadRecurso Gas) (cantidadParaUnidad Marine Gas))
                )
            )

            ; Incrementamos el coste del plan
            (increase (coste) 1)

        )
    )

    (:action Recolectar
        :parameters (?tr - TipoRecurso ?l1 - localizacion)
        :precondition (and
            ; Miramos si la localizacion que estamos tiene el recurso que queremos
            (tieneRecurso ?l1 ?tr)

            ; Comprobamos que exista al menos
            ; una unidad que este extrayendo recursos de esta localizacion
            ; y que sea de tipo VCCE
            (exists (?u - unidad) 
                (and
                    (en ?u ?l1)
                    (extraerRecurso ?u)
                    (tipoUnidad ?u VCE)
                )
            )

            ; Que se este obteniendo el recurso
            (obteniendoRecurso ?tr)

            ; Que no superemos el limite de almacen para cada recurso teniendo en cuenta
            ; el incremento del recurso por las unidades que hay (puede haber varias en el mismo nodo trabajando)
            (<= (+ (cantidadRecurso ?tr) (* (incrementoRecurso ?tr) (unidadesEnNodo ?l1))) (maximoRecurso ?tr))
 
        )
        :effect (and
            
            ; Incrementamos el coste del plan
            (increase (coste) 1)

            ; Incrementamos la cantidad de material en su incremento por cada unidad que haya 
            ; trabajando en ese nodo
            (increase (cantidadRecurso ?tr) (* (incrementoRecurso ?tr) (unidadesEnNodo ?l1)))
            
        )
    )

    

)