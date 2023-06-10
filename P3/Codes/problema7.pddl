(define (problem Ej7Prob)
    (:domain Ej7)
    (:objects
        VCE1 VCE2 VCE3 Marine1 Marine2 Soldado1 - unidad
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
        (unidadReclutada VCE1)

        ; Definimos 2 unidades de tipo VCE que no estan reclutadas
        ; porque no se encuentran en ninguna localizacion
        (tipoUnidad VCE2 VCE)
        (tipoUnidad VCE3 VCE)
        ; Recursos que necesita una unidad de tipo VCE
        (unidadNecesita VCE Mineral)
        ; Sitio donde se recluta una unidad de tipo VCE
        (sitioRecluta VCE CentroDeMando)

        ; Definimos 2 unidades de tipo Marine que no estan reclutadas
        ; porque no se encuentran en ninguna localizacion
        (tipoUnidad Marine1 Marine)
        (tipoUnidad Marine2 Marine)
        ; Recursos que necesita una unidad de tipo Marine
        (unidadNecesita Marine Gas)
        (unidadNecesita Marine Mineral)
        ; Sitio donde se recluta una unidad de tipo Marine
        (sitioRecluta Marine Barracones)

        ; Definimos 1 unidad de tipo Soldado que no esta reclutada
        ; porque no se encuentra en ninguna localizacion
        (tipoUnidad Soldado1 Soldado)
        ; Recursos que necesita una unidad de tipo Soldado
        (unidadNecesita Soldado Mineral)
        (unidadNecesita Soldado Gas)
        ; Sitio donde se recluta una unidad de tipo Soldado
        (sitioRecluta Soldado Barracones)

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
        ; y las unidades trabajando en ese nodo
        (tieneRecurso loc22 Mineral)
        (= (unidadesEnNodo loc22) 0)
        (tieneRecurso loc44 Mineral)
        (= (unidadesEnNodo loc44) 0)
        (tieneRecurso loc15 Gas)
        (= (unidadesEnNodo loc15) 0)


        ; Coste del plan
        (= (coste) 0)

        ; Cantidad inicial de los recursos
        (= (cantidadRecurso Mineral) 0)
        (= (cantidadRecurso Gas) 0)
        
        ; Cantidad de recursos necesarios para reclutar un VCE
        (= (cantidadParaUnidad VCE Mineral) 5)
        
        ; Cantidad de recursos necesarios para reclutar un Marine
        (= (cantidadParaUnidad Marine Mineral) 10)
        (= (cantidadParaUnidad Marine Gas) 15)
        
        ; Cantidad de recursos necesarios para reclutar un Soldado
        (= (cantidadParaUnidad Soldado Mineral) 30)
        (= (cantidadParaUnidad Soldado Gas) 40)

        ; Cantidad de recursos necesarios para construir un extractor
        (= (cantidadParaEdificio Extractor Mineral) 10)
        (= (cantidadParaEdificio Extractor Gas) 0)

        ; Cantidad de recursos necesarios para construir los barracones
        (= (cantidadParaEdificio Barracones Mineral) 40)
        (= (cantidadParaEdificio Barracones Gas) 10)

        ; Incremento de recurso cada vez que se recolecta
        (= (incrementoRecurso Mineral) 5)
        (= (incrementoRecurso Gas) 10)

        ; Cantidad maxima de recursos
        (= (maximoRecurso Mineral) 50)
        (= (maximoRecurso Gas) 60)

    )
    (:goal (and
        ; Goal constuir barracones en loc33
        ; tener marine1 loc31 otro marine en loc24
        ; tener soldado en loc12
        (en Barracones1 loc33)
        (en Marine1 loc31)
        (en Marine2 loc24)
        (en Soldado1 loc12)

        ; Coste del plan
        (< (coste) 58)
    ))
)