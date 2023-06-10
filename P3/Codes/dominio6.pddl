(define (domain Ej6)
    (:requirements :strips :typing :adl :fluents)
    (:types 
        objetoGenerico localizacion investigacion TipoUnidad TipoEdificio TipoRecurso TipoInvestigacion - object   
        unidad edificio - objetoGenerico
    )
    (:constants
        VCE Marine Soldado - TipoUnidad
        CentroDeMando Barracones Extractor Laboratorio - TipoEdificio
        Spartan - TipoInvestigacion
        Mineral Gas Especia - TipoRecurso
    )
    (:functions
        ; Función que nos medirá el coste del plan
        (coste)
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

        ;Recurso que un tipo de edificio necesita
        (edificioNecesita ?te - TipoEdificio ?tr - TipoRecurso)

        ;Si se esta obteniendo el recurso
        (obteniendoRecurso ?tr - TipoRecurso)

        ;Que necesitan las unidades como marine o soldado
        (unidadNecesita ?tu - TipoUnidad ?r - TipoRecurso)
        
        ;El tipo de edificio donde se recluta un tipo de unidad
        (sitioRecluta ?tu - TipoUnidad ?te - TipoEdificio)

        ;Si esa unidad esta reclutada ya
        (unidadReclutada ?u - Unidad)

        ;Definimos el tipo de investigacion de la investigación
        (investigacionEs ?v - investigacion ?ti - TipoInvestigacion)
        ;Si se ha realizado ya la investigación
        (investigacionRealizada ?v - investigacion)
        ;Define el tipo de recursos que necesita una investigación
        (investigacionNecesita ?ti - TipoInvestigacion ?r - TipoRecurso)

    )

    (:action Navegar
        :parameters (?v - unidad ?l1 ?l2 - localizacion )
        :precondition 
            (and 
                ; Si esta en la localización l1 y l1 esta conectado con l2 
                (en ?v ?l1)
                (conectado ?l1 ?l2)
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
            
            ; Si el recurso es de tipo Especia el que
            ; esta en la localización l1
            ; decimos que la unidad v está extrayendo recursos
            ; y que uno de los recursos que obtenemos es de tipo Especia
            (when (and(tieneRecurso ?l1 Especia))
                (and
                    (extraerRecurso ?v)
                    (obteniendoRecurso Especia)
                )
            )

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

            ; Vamos a mirar que si la unidad que se quiere reclutar es
            ; de tipo Soldado tenemos que haber realizado
            ; una investigacion y esta investigación debe ser de
            ; tipo Spartan
            (imply (tipoUnidad ?u Soldado)
                (exists (?i - investigacion) 
                    (and
                        (investigacionRealizada ?i)
                        (investigacionEs ?i Spartan)
                    )
                )   
            )

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
                            ; O bien lo necesitamos y lo estamos obteniendo
                            (and
                                (unidadNecesita ?tu ?r)
                                (obteniendoRecurso ?r)
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

            ; Incrementamos el coste del plan
            (increase (coste) 1)
        )
    )

    (:action Investigar
        :parameters (?e - edificio ?inv - investigacion)
        :precondition (and  
        
        ; Miramos que la investigación que vayamos a investigar
        ; que no este ya investigada
        (not (investigacionRealizada ?inv))
        
        ; Que este construido el edificio y ese edificio
        ; sea de tipo laboratorio porque es el que necesitamos
        ; para realizar las investigaciones
        (edificioConstruido ?e)
        (typeEdificio ?e Laboratorio)

        ; Por cada tipo de investigacion
        (exists (?ti - TipoInvestigacion)
            (and
                ; Vemos si la investigacion a realizar es de ese tipo
                (investigacionEs ?inv ?ti)
                ; Para todos los recursos que hay
                (forall (?r - TipoRecurso)
                    (or
                        ; O no los necesitamos para la investigacion
                        (not (investigacionNecesita ?ti ?r))
                        ; O si los necesitamos y los estamos obteniendo
                        (and
                            (investigacionNecesita ?ti ?r)
                            (obteniendoRecurso ?r)
                        )
                    )
                )
            )
        )
    )
    :effect (and
        ; Realizamos la investigacion
        (investigacionRealizada ?inv)

        ;Incrementamos el coste del plan
        (increase (coste) 1)
        )
    )
)
    

    

