
# MapKit + Look Around | Demo iOS

Aplicación demostrativa desarrollada en SwiftUI que
permite visualizar ubicaciones geográficas mediante
MapKit y explorar vistas panorámicas utilizando
Look Around de Apple.

Este proyecto fue desarrollado con fines académicos
para demostrar la integración de herramientas de
geolocalización y visualización en aplicaciones iOS.

## Tecnologías utilizadas

- Swift 5
- SwiftUI
- MapKit
- Look Around
- UIKit
- Xcode 14.2
- iOS 16.0 o superior

## Funcionalidades principales

La aplicación permite:

- Visualizar la ubicación de Times Square, Nueva York.
- Mostrar información geográfica y coordenadas.
- Utilizar un mapa interactivo mediante MapKit.
- Centrar el mapa en una ubicación determinada.
- Consultar vistas panorámicas mediante Look Around.
- Cambiar entre modo demostración y modo real.

## Modos de funcionamiento

### Modo demostración

Este modo permite explorar la interfaz sin depender
de los servicios de Apple Maps.

Incluye:

- Mapa ilustrativo de Times Square.
- Controles para acercar y alejar la imagen.
- Desplazamiento del mapa.
- Botón para centrar la ubicación.
- Vista panorámica ilustrativa con desplazamiento
  horizontal.

Nota: Este modo utiliza imágenes locales y simula
la interacción. No proporciona mapas geográficos
reales ni navegación panorámica de 360 grados.

### Modo MapKit real

Utiliza las herramientas oficiales de Apple:

- MapKit para representar mapas interactivos.
- MKCoordinateRegion para definir la región.
- MapMarker para señalar ubicaciones.
- MKLookAroundSceneRequest para solicitar escenas.
- MKLookAroundViewController para visualizar
  Look Around.

Este modo requiere acceso a los servicios de Apple
Maps y un entorno compatible.

## Estructura del proyecto

```text
DemoMapKit/
|
|-- DemoMapKitApp.swift
|-- ContentView.swift
|-- LookAroundView.swift
|
|-- Assets.xcassets/
    |-- MapaDemo.imageset/
    |-- PanoramaDemo.imageset/
```

### Descripción de archivos

**DemoMapKitApp.swift**

Archivo principal que inicia la aplicación.

**ContentView.swift**

Contiene la interfaz principal, la estructura Lugar,
el mapa y la lógica de los modos de visualización.

**LookAroundView.swift**

Permite integrar MKLookAroundViewController
con SwiftUI mediante UIViewControllerRepresentable.

**Assets.xcassets**

Contiene las imágenes utilizadas para el modo
demostración.

## Organización de los datos

Se utiliza una estructura llamada Lugar para
almacenar la información de una ubicación.

Los principales datos son:

- Nombre
- Descripción
- Latitud
- Longitud

No se utiliza una base de datos, ya que los datos
se encuentran definidos directamente en el código.

## Cómo ejecutar el proyecto

1. Clonar o descargar este repositorio.
2. Abrir el archivo DemoMapKit.xcodeproj en Xcode.
3. Seleccionar un simulador con iOS 16 o superior.
4. Ejecutar la aplicación.
5. Seleccionar el modo de visualización deseado.

## Limitaciones

El proyecto fue desarrollado utilizando Xcode 14.2.

Durante las pruebas en un entorno macOS virtualizado
mediante VMware se identificaron limitaciones
gráficas que impiden visualizar correctamente
los servicios de Apple Maps.

Por este motivo se incorporó un modo demostración
que utiliza recursos locales.

La implementación real de MapKit y Look Around
se conserva en el proyecto, pero su funcionamiento
requiere un entorno compatible y disponibilidad
de los servicios de Apple.

## Objetivo académico

Demostrar el manejo de información geográfica
en aplicaciones iOS, utilizando SwiftUI, MapKit
y Look Around.

También se busca comprender la organización de
datos mediante estructuras de Swift y la integración
de componentes de UIKit dentro de SwiftUI.

## Estado del proyecto

Versión académica demostrativa.

La interfaz y el modo demostración están
implementados. La integración real requiere
validación en un entorno compatible.
