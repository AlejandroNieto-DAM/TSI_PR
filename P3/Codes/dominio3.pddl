(define (domain Ej3)
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

        ;Si un tipo de edificio necesita un recurso
        (edificioNecesita ?te - TipoEdificio ?tr - TipoRecurso)

        ;Si se esta obteniendo el recurso
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
        :parameters (?v - unidad ?e - edificio ?l1 - localizacion )
        :precondition 
            (and 

                ; Comprobamos que la unidad este en l1
                (en ?v ?l1)
                ; Que la unidad no este ocupada extrayendo recursos
                (not (extraerRecurso ?v))

                ; Que el edificio que vamos a construir no este construido
                (not (edificioConstruido ?e))
                ; Que el edificio no este en la localización l1 (redundante para acotar espacio de busqueda)   
                (not (en ?e ?l1))

                ; Comprobamos que no haya ya un edificio construido en
                ; esta localización
                (not 
                    (exists (?ed - edificio)
                        (en ?ed ?l1)
                    )
                )
               
                ; Comprobamos si existe un tipo de edificio que sea el que vamos a construir  
                (exists (?tp - TipoEdificio)
                    (and
                        (typeEdificio ?e ?tp)
                        
                        ; Comprobamos para todos los recursos   
                        (forall (?r - TipoRecurso)
                            (or
                                ; Si no lo necesitamos para nuestro tipo de edificio
                                (not(edificioNecesita ?tp ?r))
                                ; Si lo necesitamos y lo estamos obteniendo
                                (and
                                    (edificioNecesita ?tp ?r)
                                    (obteniendoRecurso ?r)
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
                
            )
    )

)