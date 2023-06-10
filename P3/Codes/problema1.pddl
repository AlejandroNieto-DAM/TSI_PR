(define (problem Ej1Prob)
    (:domain Ej1)
    (:objects
        VCE1 - unidad
        CentroDeMando1 - edificio
        loc11 loc12 loc13 loc14 loc15 loc21 loc22 loc23 loc24 loc31 loc32 loc33 loc34 loc44 loc42 loc43 loc44 - localizacion
    )
    (:init

        ; Definimos todas las casillas conectadas
        (conectado loc11 loc12)
        (conectado loc11 loc21)
        
        (conectado loc12 loc22)
        (conectado loc12 loc11)

        (conectado loc21 loc11)
        (conectado loc21 loc31)

        (conectado loc31 loc21)
        (conectado loc31 loc32)

        (conectado loc22 loc12)
        (conectado loc22 loc32)
        (conectado loc22 loc23)

        (conectado loc32 loc22)
        (conectado loc32 loc42)
        (conectado loc32 loc31)

        (conectado loc13 loc23)

        (conectado loc23 loc13)
        (conectado loc23 loc22)
        (conectado loc23 loc33)
        (conectado loc23 loc24)

        (conectado loc33 loc23)

        (conectado loc43 loc42)
        (conectado loc43 loc44)

        (conectado loc14 loc15)
        (conectado loc14 loc24)

        (conectado loc24 loc14)
        (conectado loc24 loc23)

        (conectado loc34 loc44)
        
        (conectado loc44 loc34)
        (conectado loc44 loc43)
        (conectado loc44 loc15)

        (conectado loc42 loc32)
        (conectado loc42 loc43)

        (conectado loc15 loc14)
        (conectado loc15 loc44)

        ; Definimos una unidad de tipo VCE en la localizacion11
        (en VCE1 loc11)
        (tipoUnidad VCE1 VCE)

        ; Definimos un edificio de tipo CentroDeMando en la localización11
        (en CentroDeMando1 loc11)
        (edificioConstruido CentroDeMando1)
        (tipoEdificio CentroDeMando1 CentroDeMando)

        ; Definimos las localizaciones donde se encuentran los recursos
        (tieneRecurso loc24 Mineral)
        (tieneRecurso loc44 Mineral)

    )
    (:goal (and
        ; El goal es extrarer recurso
        (extraerRecurso VCE1)
    ))
)