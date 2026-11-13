
# 🗺️ Demo MapKit + Look Around en iOS

### Universidad Tecnológica de El Salvador (UTEC)

**Alumno:** Leonardo Isai Zepeda Tolentino
**Asignatura:** Electiva Técnica Profesional IV (ETPS4)  
**Año:** 2026  
**Plataforma:** iOS  
**Entorno de desarrollo:** Xcode 14.2  

---

## 📖 Descripción del proyecto

Este proyecto consiste en una aplicación demostrativa desarrollada en SwiftUI que permite visualizar una ubicación geográfica mediante MapKit y explorar su entorno utilizando Look Around, una funcionalidad de Apple Maps que ofrece imágenes panorámicas a nivel de calle.

La aplicación utiliza como ejemplo **Times Square, Nueva York, Estados Unidos**.

Su propósito es demostrar cómo integrar ambos componentes en una aplicación iOS, permitiendo consultar información geográfica de forma sencilla e interactiva.

La aplicación no utiliza una base de datos, ya que la información está definida directamente en el código fuente.

---

## 🎯 Objetivo general

Demostrar el funcionamiento e integración de MapKit y Look Around en una aplicación iOS desarrollada con SwiftUI, permitiendo visualizar información geográfica y explorar una ubicación mediante imágenes panorámicas.

## Objetivos específicos

- Implementar MapKit para visualizar una ubicación en un mapa interactivo.
- Integrar Look Around para explorar imágenes panorámicas a nivel de calle.
- Organizar la información mediante estructuras de datos en Swift.
- Diseñar una interfaz sencilla utilizando componentes nativos de SwiftUI.
- Implementar la presentación y el cierre de la vista panorámica.

---

## 🛠️ Tecnologías utilizadas

| Tecnología | Función |
|------------|---------|
| Swift | Lenguaje de programación principal. |
| SwiftUI | Construcción de la interfaz gráfica. |
| MapKit | Visualización de mapas y coordenadas geográficas. |
| Look Around | Visualización panorámica a nivel de calle. |
| UIKit | Integración de MKLookAroundViewController. |
| Xcode 14.2 | Entorno de desarrollo utilizado. |

---

## 📱 Funcionalidades principales

### 1. Visualización del mapa

La aplicación muestra un mapa interactivo mediante MapKit, con un marcador rojo ubicado en Times Square.

También presenta:
- Nombre de la ubicación.
- Descripción.
- Latitud y longitud.
- Botón para abrir Look Around.
- Botón para centrar nuevamente el mapa.

### 2. Vista Look Around

Al seleccionar el botón **Ver Look Around**, la aplicación solicita una escena panorámica mediante los servicios de Apple Maps.

Si la ubicación cuenta con cobertura, se abre una vista interactiva que permite explorar visualmente el entorno.

### 3. Centrar mapa

El botón **Centrar mapa** permite regresar a la ubicación inicial después de desplazarse por el mapa.

### 4. Manejo de errores

La aplicación muestra mensajes cuando:
- No existe cobertura de Look Around para una ubicación.
- Ocurre un error al solicitar la escena panorámica.

También presenta un indicador de carga mientras obtiene la información.

---

## 🏗️ Organización de la información

La aplicación utiliza una estructura de datos de Swift llamada `Lugar`, encargada de almacenar la información geográfica.

```swift
struct Lugar: Identifiable {
    let id = UUID()
    let nombre: String
    let descripcion: String
    let latitud: Double
    let longitud: Double
}
```

### Ubicación utilizada

```swift
let lugar = Lugar(
    nombre: "Times Square",
    descripcion: "Nueva York, Estados Unidos",
    latitud: 40.7580,
    longitud: -73.9855
)
```

Los datos se manejan directamente en memoria.

**No se utiliza Core Data, SQLite, Firebase ni otro sistema de almacenamiento persistente.**

MapKit y Look Around consultan los servicios de Apple para obtener los mapas y las escenas panorámicas.

---

## 🧩 Organización de la aplicación

El proyecto utiliza una organización sencilla basada en el patrón **Modelo–Vista (MV)**.

### Modelo

La estructura `Lugar` almacena los datos de la ubicación.

### Vista

`ContentView` presenta el mapa, los datos geográficos y los botones.

### Componentes de visualización

MapKit representa las coordenadas mediante un mapa interactivo y Look Around muestra la escena panorámica.

SwiftUI utiliza `@State` para administrar los cambios de la interfaz.

No se implementa una arquitectura MVVM completa, debido a que se trata de una demostración sencilla.

---

## 📂 Estructura del proyecto

```text
DemoMapKit/
│
├── DemoMapKitApp.swift
├── ContentView.swift
├── LookAroundView.swift
├── Assets.xcassets/
└── README.md
```

### Descripción de los archivos

| Archivo | Descripción |
|---------|-------------|
| DemoMapKitApp.swift | Punto de entrada de la aplicación. |
| ContentView.swift | Contiene el modelo Lugar, el mapa, los botones y la lógica principal. |
| LookAroundView.swift | Integra MKLookAroundViewController con SwiftUI mediante UIViewControllerRepresentable. |
| Assets.xcassets | Recursos gráficos de la aplicación. |
| README.md | Documentación del proyecto. |

---

## 💻 Requisitos

Para ejecutar el proyecto se necesita:

- macOS compatible con Xcode 14.2.
- Xcode 14.2.
- Swift 5.
- iOS 16.0 o superior.
- Simulador de iOS o dispositivo físico compatible.
- Conexión a Internet para consultar los servicios de Apple Maps.

**Nota:** La disponibilidad de Look Around depende de la cobertura geográfica de Apple y de las capacidades del entorno de ejecución.

---

## 🚀 Instalación y ejecución

### Paso 1. Clonar el repositorio

```bash
git clone https://github.com/IsaiZepeda04/DemoMapKit
```

### Paso 2. Abrir el proyecto

Abrir el archivo `DemoMapKit.xcodeproj` desde Xcode.

### Paso 3. Seleccionar el dispositivo

Elegir un simulador de iOS 16 o superior o un dispositivo físico compatible.

### Paso 4. Ejecutar la aplicación

Presionar el botón **Run** de Xcode o utilizar:

```text
Command + R
```

### Paso 5. Probar las funcionalidades

1. Visualizar Times Square en el mapa.
2. Desplazarse por el mapa.
3. Presionar **Centrar mapa**.
4. Presionar **Ver Look Around**.
5. Explorar la escena panorámica disponible.
6. Cerrar Look Around para regresar a la pantalla principal.

---

## 🔄 Flujo de navegación

```text
Inicio de la aplicación
         |
         v
 Pantalla principal
         |
         | Ver Look Around
         v
    Vista panorámica
         |
         | Cerrar / Regresar
         v
 Pantalla principal
```

El botón **Centrar mapa** solamente modifica la región visible del mapa y no abre otra pantalla.

---

## ⚠️ Limitaciones

- La demostración utiliza una única ubicación predefinida.
- No cuenta con una base de datos.
- No permite agregar ni editar ubicaciones.
- No implementa autenticación de usuarios.
- Look Around requiere cobertura y acceso a los servicios de Apple.
- Su funcionamiento puede variar según el simulador o dispositivo utilizado.

---

## ✅ Conclusiones

La implementación demuestra que MapKit y Look Around pueden integrarse en una aplicación desarrollada con SwiftUI para presentar información geográfica de manera visual e interactiva.

La estructura `Lugar` facilita la organización de los datos, mientras que `@State` permite controlar los cambios de la interfaz.

Al tratarse de una aplicación demostrativa, no fue necesario implementar una base de datos ni una arquitectura compleja.

El proyecto permite comprender el uso de los componentes nativos de Apple y su posible aplicación futura en soluciones que requieran información geográfica.

---

## 📚 Referencias

- [Apple Developer – MapKit](https://developer.apple.com/documentation/mapkit/)
- [Apple Developer – SwiftUI](https://developer.apple.com/documentation/swiftui/)
- [Apple Developer – MKLookAroundViewController](https://developer.apple.com/documentation/mapkit/mklookaroundviewcontroller)
- [Apple Developer – MKLookAroundSceneRequest](https://developer.apple.com/documentation/mapkit/mklookaroundscenerequest)

---

## 🎓 Información académica

**Institución:** Universidad Tecnológica de El Salvador (UTEC)  
**Asignatura:** Electiva Técnica Profesional IV (ETPS4)  
**Proyecto:** Demostración de MapKit + Look Around en iOS  
**Año:** 2026  

---

**Proyecto desarrollado con fines académicos para demostrar la integración de MapKit y Look Around en aplicaciones iOS.**
