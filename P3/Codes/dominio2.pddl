(define (domain Ej2)
    (:requirements :strips :typing :adl :fluents)
    (:types 
        objetoGenerico localizacion TipoUnidad TipoEdificio TipoRecurso - object   
        unidad edificio - objetoGenerico
    )
    (:constants
        VCE - TipoUnidad
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

        ;Recurso que necesita un edificio
        (edificioNecesita ?te - TipoEdificio ?tr - TipoRecurso)

        ;Si se esta obteniendo ese recurso
        (obteniendoRecurso ?tr - TipoRecurso)
        
    )

    (:action Navegar
        :parameters (?v - unidad ?l1 ?l2 - localizacion )
        :precondition 
            (and 
                ; Si esta en la localización l1 y l1 esta conectado con l2 
                (en ?v ?l1)
                (conectado ?l1 ?l2)
            )
        :effect 
            (and
                ; Hacemos negativo que la unidad este en l1
                (not (en ?v ?l1))
                ; Hacemos que la unidad este en l2
                (en ?v ?l2)
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
            ; y que uno de los recursos que obtenemos es de tipo GAS
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
                
        ) 
            
    )

    (:action Construir
        :parameters (?v - unidad ?e - edificio ?l1 - localizacion ?r - TipoRecurso)
        :precondition 
            (and 

                ; Comprobamos que la unidad este en l1
                (en ?v ?l1)
                ; Que la unidad no este ocupada extrayendo recursos
                (not (extraerRecurso ?v))
                ; Que el edificio que vamos a construir no este construido
                (not(edificioConstruido ?e))
                
                ; Comprobamos para todos los tipos de edificios
                (forall (?te - TipoEdificio)
                    (or
                        ; O el edificio que vamos a construir no necesita el recurso
                        (not (typeEdificio ?e ?te))
                        ; O lo necesita y lo estamos obteniendo
                        (and
                            (edificioNecesita ?te ?r)
                            (obteniendoRecurso ?r)
                            (typeEdificio ?e ?te)
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
                
            )
    )

)