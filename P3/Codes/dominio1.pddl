(define (domain Ej1)
    (:requirements :strips :typing)
    (:types 
        objetoGenerico localizacion - object   
        unidad edificio - objetoGenerico
    )
    (:constants
        VCE - TipoUnidad
        CentroDeMando Barracones - TipoEdificio
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
        (tipoEdificio ?e - edificio ?t - TipoEdificio)
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
        :parameters (?v - unidad ?l1 - localizacion ?r - TipoRecurso)
        :precondition 
            (and 
                ; Si la unidad esta en la localización l1
                (en ?v ?l1)
                ; Si la localización l1 tiene el recurso r
                (tieneRecurso ?l1 ?r)
                ; Si la unidad v no está ya asignada extrayendo un recurso
                (not (extraerRecurso ?v))
            )
        :effect 
            (and
                ; Asignamos a unidad v que esta extrayendo un recurso
                (extraerRecurso ?v)
            )
    )

)