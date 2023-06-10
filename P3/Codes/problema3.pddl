(define (problem Ej3Prob)
    (:domain Ej3)
    (:objects
        VCE1 VCE2 VCE3 - unidad
        CentroDeMando1 - edificio
        Extractor1 - edificio
        Barracones1 - edificio
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
        ; Definimos otra unidad de tipo VCE en la localizacion11
        (en VCE2 loc11)
        (tipoUnidad VCE2 VCE)
        ; Definimos otra unidad de tipo VCE en la localizacion11
        (en VCE3 loc11)
        (tipoUnidad VCE3 VCE)

        ; Definimos un edificio de tipo CentroDeMando en la localización11
        (en CentroDeMando1 loc11)
        (typeEdificio CentroDeMando1 CentroDeMando)
        (edificioConstruido CentroDeMando1)
        
        ; Definimos un edificio de tipo extractor y el material que necesita
        ; al contrario que CentroDeMando no lo ponemos que este en alguna
        ; localizacion para deducir por omision que no esta constuido
        (typeEdificio Extractor1 Extractor)
        (edificioNecesita Extractor Mineral)

        ; Definimos un edificio de tipo Barracones y el material que necesita
        ; al contrario que CentroDeMAndo no lo ponemos que este en alguna
        ; localizacion para deducir por omision que no esta constuido
        (typeEdificio Barracones1 Barracones)
        (edificioNecesita Barracones Mineral)
        (edificioNecesita Barracones Gas)

        ; Definimos las localizaciones donde se encuentran los recursos
        (tieneRecurso loc24 Mineral)
        (tieneRecurso loc44 Mineral)
        (tieneRecurso loc15 Gas)

    )
    (:goal (and
        ; Goal es construir unos Barracones en la localizacion 34
        (en Barracones1 loc34)
    ))
)