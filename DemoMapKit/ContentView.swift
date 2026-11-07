
import SwiftUI
import MapKit

// MARK: - MODELO DE UBICACION
struct Lugar: Identifiable {
    let id = UUID()
    let nombre: String
    let descripcion: String
    let latitud: Double
    let longitud: Double

    // MapKit necesita las coordenadas en este formato.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
    }
}

// MARK: - MODOS DE VISUALIZACION
enum ModoMapa: String, CaseIterable, Identifiable {
    case demostracion = "Demo"
    case real = "Real"

    var id: String { rawValue }
}

// MARK: - PANTALLA PRINCIPAL
struct ContentView: View {

    // Lugar inicial de la aplicacion.
    @State private var lugarSeleccionado = Lugar(
        nombre: "Times Square",
        descripcion: "Nueva York, Estados Unidos",
        latitud: 40.7580,
        longitud: -73.9855
    )

    // Iniciamos en Demo porque Apple Maps no carga en el VMware utilizado.
    @State private var modo: ModoMapa = .demostracion

    // Busqueda de direcciones.
    @State private var textoBusqueda = ""
    @State private var resultadosBusqueda: [Lugar] = []
    @State private var buscando = false
    @State private var mensajeBusqueda = ""

    // Region visible del mapa real.
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    // Look Around real.
    @State private var escenaReal: MKLookAroundScene?
    @State private var mostrarReal = false
    @State private var cargando = false
    @State private var errorReal = ""

    // Mapa y panoramica simulados.
    @State private var zoom: CGFloat = 1.0
    @State private var offsetMapa = CGSize.zero
    @State private var offsetAnterior = CGSize.zero
    @State private var mostrarDemo = false

    // MARK: - INTERFAZ PRINCIPAL
    var body: some View {
        ScrollView {
            // Dividimos la interfaz en secciones para que Xcode 14.2
            // no produzca el error "Extra argument in call".
            VStack(spacing: 14) {
                encabezado
                selectorModo
                buscador
                seccionMapa
                informacionLugar
                controles
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $mostrarDemo) {
            PanoramaDemoView()
        }
        .sheet(isPresented: $mostrarReal) {
            if let escena = escenaReal {
                LookAroundView(scene: escena)
            } else {
                Text("Vista no disponible")
                    .padding()
            }
        }
    }

    // MARK: - ENCABEZADO
    private var encabezado: some View {
        VStack(spacing: 4) {
            Text("MapKit + Look Around")
                .font(.title2)
                .bold()

            Text("Explora diferentes ubicaciones")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 12)
    }

    // MARK: - SELECTOR DE MODO
    private var selectorModo: some View {
        Picker("Modo de visualizacion", selection: $modo) {
            Text("Demo sin conexion")
                .tag(ModoMapa.demostracion)
            Text("MapKit real")
                .tag(ModoMapa.real)
        }
        .pickerStyle(.segmented)
        .onChange(of: modo) { _ in
            mensajeBusqueda = ""
            errorReal = ""
        }
    }

    // MARK: - BUSCADOR
    private var buscador: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Buscar ubicacion")
                .font(.headline)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Ciudad, direccion o lugar...", text: $textoBusqueda)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .onSubmit {
                        buscarUbicaciones()
                    }

                Button("Buscar") {
                    buscarUbicaciones()
                }
                .font(.subheadline)
                .disabled(
                    buscando || textoBusqueda.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty
                )
            }
            .padding(12)
            .background(Color.gray.opacity(0.10))
            .cornerRadius(10)

            if buscando {
                ProgressView("Buscando ubicaciones...")
            }

            if !resultadosBusqueda.isEmpty {
                listaResultados
            }

            if !mensajeBusqueda.isEmpty {
                Text(mensajeBusqueda)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - RESULTADOS DE BUSQUEDA
    private var listaResultados: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Resultados encontrados")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(8)

            ForEach(resultadosBusqueda) { resultado in
                Button {
                    seleccionarUbicacion(resultado)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            Text(resultado.nombre)
                                .font(.subheadline)
                                .bold()
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }

                        Text(resultado.descripcion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                Divider()
            }
        }
        .background(Color.gray.opacity(0.07))
        .cornerRadius(10)
    }

    // MARK: - SECCION MAPA
    private var seccionMapa: some View {
        VStack(spacing: 8) {
            if modo == .demostracion {
                Text("SIMULACION: mapa ilustrativo de Times Square")
                    .font(.caption)
                    .foregroundColor(.orange)

                mapaIlustrativo
                    .frame(height: 365)
            } else {
                Text("MAPA REAL DE APPLE")
                    .font(.caption)
                    .foregroundColor(.secondary)

                mapaReal
                    .frame(height: 365)
            }
        }
    }

    // MARK: - INFORMACION DEL LUGAR
    private var informacionLugar: some View {
        VStack(spacing: 7) {
            Text(lugarSeleccionado.nombre)
                .font(.title2)
                .bold()

            Text(lugarSeleccionado.descripcion)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text(String(
                format: "Lat: %.5f | Long: %.5f",
                lugarSeleccionado.latitud,
                lugarSeleccionado.longitud
            ))
            .font(.caption)
            .foregroundColor(.secondary)

            if modo == .demostracion && lugarSeleccionado.nombre != "Times Square" {
                Text("El mapa y la panoramica del modo Demo siguen mostrando Times Square, aunque hayas seleccionado otra ubicacion.")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - BOTONES Y MENSAJES
    private var controles: some View {
        VStack(spacing: 10) {
            if cargando {
                ProgressView("Consultando Look Around...")
            }

            if !errorReal.isEmpty && modo == .real {
                Text(errorReal)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: abrirPanorama) {
                Label("Ver Look Around", systemImage: "binoculars.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(cargando)

            Button(action: centrarMapa) {
                Label("Centrar mapa", systemImage: "location.fill")
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.blue.opacity(0.10))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
            }

            if modo == .demostracion {
                Text("El modo Demo utiliza imagenes locales. La busqueda de direcciones requiere conexion a los servicios de Apple.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - MAPA DEMOSTRATIVO (IMAGEN LOCAL)
    private var mapaIlustrativo: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                Image("MapaDemo")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .scaleEffect(zoom)
                    .offset(offsetMapa)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offsetMapa = CGSize(
                                    width: offsetAnterior.width + value.translation.width,
                                    height: offsetAnterior.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                offsetAnterior = offsetMapa
                            }
                    )

                VStack(spacing: 8) {
                    Button { ampliar(0.2) } label: {
                        Image(systemName: "plus")
                            .frame(width: 38, height: 38)
                    }
                    Button { ampliar(-0.2) } label: {
                        Image(systemName: "minus")
                            .frame(width: 38, height: 38)
                    }
                }
                .background(Color.white.opacity(0.95))
                .foregroundColor(.blue)
                .cornerRadius(10)
                .padding(12)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(14)
        }
    }

    // MARK: - MAPA REAL CON MARCADOR DINAMICO
    private var mapaReal: some View {
        Map(coordinateRegion: $region, annotationItems: [lugarSeleccionado]) { ubicacion in
            MapMarker(coordinate: ubicacion.coordinate, tint: .red)
        }
        .cornerRadius(14)
    }

    // MARK: - BUSCAR UBICACIONES CON APPLE MAPS
    private func buscarUbicaciones() {
        let consulta = textoBusqueda.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !consulta.isEmpty else {
            mensajeBusqueda = "Escribe una direccion o lugar."
            return
        }

        buscando = true
        mensajeBusqueda = ""
        resultadosBusqueda = []

        let solicitud = MKLocalSearch.Request()
        solicitud.naturalLanguageQuery = consulta
        let busqueda = MKLocalSearch(request: solicitud)

        busqueda.start { respuesta, error in
            DispatchQueue.main.async {
                buscando = false

                if let error = error {
                    mensajeBusqueda = "No se pudo realizar la busqueda. Revisa los servicios de Apple Maps."
                    print("Error de busqueda: \(error.localizedDescription)")
                    return
                }

                guard let elementos = respuesta?.mapItems, !elementos.isEmpty else {
                    mensajeBusqueda = "No se encontraron ubicaciones."
                    return
                }

                resultadosBusqueda = elementos.prefix(8).map { elemento in
                    let coordenadas = elemento.placemark.coordinate
                    return Lugar(
                        nombre: elemento.name ?? "Ubicacion",
                        descripcion: elemento.placemark.title ?? "Resultado de busqueda",
                        latitud: coordenadas.latitude,
                        longitud: coordenadas.longitude
                    )
                }
            }
        }
    }

    // MARK: - AL SELECCIONAR UN RESULTADO
    private func seleccionarUbicacion(_ lugar: Lugar) {
        lugarSeleccionado = lugar
        textoBusqueda = lugar.nombre
        resultadosBusqueda = []
        mensajeBusqueda = ""
        errorReal = ""

        region = MKCoordinateRegion(
            center: lugar.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )

        if modo == .demostracion {
            mensajeBusqueda = "Ubicacion seleccionada. El mapa ilustrativo sigue mostrando Times Square; cambia a MapKit real para consultar ese lugar."
        }
    }

    // MARK: - ZOOM DEMOSTRATIVO
    private func ampliar(_ incremento: CGFloat) {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoom = min(max(zoom + incremento, 1.0), 2.2)
        }
    }

    // MARK: - CENTRAR MAPA
    private func centrarMapa() {
        if modo == .demostracion {
            withAnimation {
                zoom = 1.0
                offsetMapa = .zero
                offsetAnterior = .zero
            }
        } else {
            region = MKCoordinateRegion(
                center: lugarSeleccionado.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }

    // MARK: - BOTON LOOK AROUND
    private func abrirPanorama() {
        if modo == .demostracion {
            mostrarDemo = true
        } else {
            Task {
                await abrirLookAroundReal()
            }
        }
    }

    // MARK: - LOOK AROUND REAL
    @MainActor
    private func abrirLookAroundReal() async {
        cargando = true
        errorReal = ""
        escenaReal = nil

        let solicitud = MKLookAroundSceneRequest(
            coordinate: lugarSeleccionado.coordinate
        )

        do {
            if let escena = try await solicitud.scene {
                escenaReal = escena
                mostrarReal = true
            } else {
                errorReal = "Look Around no esta disponible para esta ubicacion."
            }
        } catch {
            errorReal = "No se pudo cargar Look Around. Revisa los servicios de Apple Maps."
            print("Error Look Around: \(error.localizedDescription)")
        }
        cargando = false
    }
}

// MARK: - VISTA PANORAMICA DE DEMOSTRACION
struct PanoramaDemoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var desplazamiento: CGFloat = 0
    @State private var desplazamientoPrevio: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let ancho = geometry.size.width
            let alto = geometry.size.height
            let anchoImagen = max(ancho * 1.65, alto * 0.95)
            let limite = max((anchoImagen - ancho) / 2, 0)

            ZStack {
                Color.black.ignoresSafeArea()

                Image("PanoramaDemo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: anchoImagen, height: alto)
                    .offset(x: desplazamiento)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let posicion = desplazamientoPrevio + value.translation.width
                                desplazamiento = min(max(posicion, -limite), limite)
                            }
                            .onEnded { _ in
                                desplazamientoPrevio = desplazamiento
                            }
                    )
                    .frame(width: ancho, height: alto)
                    .clipped()

                VStack {
                    HStack {
                        Button { dismiss() } label: {
                            Label("Volver", systemImage: "chevron.left")
                                .font(.headline)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                        Text("PANORAMA SIMULADO")
                            .font(.caption)
                            .bold()
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    Spacer()

                    VStack(spacing: 6) {
                        Text("Times Square, Nueva York")
                            .font(.headline)
                        Text("Desliza para explorar la imagen")
                            .font(.caption)
                        Text("Imagen ilustrativa local, no Look Around real.")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.65))
                }
            }
            .frame(width: ancho, height: alto)
            .clipped()
        }
    }
}

// MARK: - VISTA PREVIA PARA XCODE 14.2
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
