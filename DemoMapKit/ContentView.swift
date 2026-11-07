import SwiftUI
import MapKit

// MARK: - Datos de la ubicacion
struct Lugar: Identifiable {
    let id = UUID()
    let nombre: String
    let descripcion: String
    let latitud: Double
    let longitud: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
    }
}

// Dos modos: el primero NO necesita los servicios de Apple Maps.
enum ModoMapa: String, CaseIterable, Identifiable {
    case demostracion = "Demo"
    case real = "Real"
    var id: String { rawValue }
}

struct ContentView: View {
    private let lugar = Lugar(
        nombre: "Times Square",
        descripcion: "Nueva York, Estados Unidos",
        latitud: 40.7580,
        longitud: -73.9855
    )

    @State private var modo: ModoMapa = .demostracion

    // Mapa real (solo cuando el usuario cambia a modo Real)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var escenaReal: MKLookAroundScene?
    @State private var mostrarReal = false
    @State private var cargando = false
    @State private var errorReal = ""

    // Mapa ilustrativo: se puede mover y ampliar sin Internet.
    @State private var zoom: CGFloat = 1.0
    @State private var offsetMapa = CGSize.zero
    @State private var offsetAnterior = CGSize.zero
    @State private var mostrarDemo = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                VStack(spacing: 3) {
                    Text("MapKit + Look Around")
                        .font(.title2)
                        .bold()
                    Text("Demostracion en SwiftUI")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 12)

                Picker("Modo de visualizacion", selection: $modo) {
                    Text("Demo sin conexion").tag(ModoMapa.demostracion)
                    Text("MapKit real").tag(ModoMapa.real)
                }
                .pickerStyle(.segmented)

                if modo == .demostracion {
                    Text("SIMULACION: mapa y panorama ilustrativos")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    mapaIlustrativo
                        .frame(height: 365)
                } else {
                    Text("MODO REAL: requiere Apple Maps y graficos compatibles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    mapaReal
                        .frame(height: 365)
                }

                VStack(spacing: 8) {
                    Text(lugar.nombre).font(.title2).bold()
                    Text(lugar.descripcion)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Lat: 40.7580  |  Long: -73.9855")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if cargando {
                    ProgressView("Cargando Look Around...")
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
                    Text("Desliza el mapa o usa +/- para ampliar. El modo Demo no usa datos geograficos en vivo.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
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
                Text("Vista no disponible").padding()
            }
        }
    }

    // MARK: - Mapa ilustrativo (funciona sin Apple Maps)
    private var mapaIlustrativo: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                Image("MapaDemo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
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
                            .onEnded { _ in offsetAnterior = offsetMapa }
                    )

                VStack(spacing: 8) {
                    Button(action: { ampliar(0.2) }) {
                        Image(systemName: "plus")
                            .frame(width: 38, height: 38)
                    }
                    Button(action: { ampliar(-0.2) }) {
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
            .background(Color(white: 0.94))
            .cornerRadius(14)
        }
    }

    private var mapaReal: some View {
        Map(coordinateRegion: $region, annotationItems: [lugar]) { ubicacion in
            MapMarker(coordinate: ubicacion.coordinate, tint: .red)
        }
        .cornerRadius(14)
    }

    private func ampliar(_ incremento: CGFloat) {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoom = min(max(zoom + incremento, 1.0), 2.2)
        }
    }

    private func centrarMapa() {
        if modo == .demostracion {
            withAnimation(.easeInOut(duration: 0.25)) {
                zoom = 1.0
                offsetMapa = .zero
                offsetAnterior = .zero
            }
        } else {
            region = MKCoordinateRegion(
                center: lugar.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }

    private func abrirPanorama() {
        if modo == .demostracion {
            mostrarDemo = true
        } else {
            Task { await abrirLookAroundReal() }
        }
    }

    // MARK: - Servicio oficial de Look Around (modo Real)
    @MainActor
    private func abrirLookAroundReal() async {
        cargando = true
        errorReal = ""
        escenaReal = nil
        let solicitud = MKLookAroundSceneRequest(coordinate: lugar.coordinate)

        do {
            if let escena = try await solicitud.scene {
                escenaReal = escena
                mostrarReal = true
            } else {
                errorReal = "Look Around no esta disponible para esta ubicacion."
            }
        } catch {
            errorReal = "No se pudo cargar Look Around: revisa los servicios de Apple Maps."
            print("Look Around error: \(error.localizedDescription)")
        }
        cargando = false
    }
}

// MARK: - Panorama ilustrativo con desplazamiento horizontal
// No es una escena MKLookAroundScene. Es una imagen de demostracion.
struct PanoramaDemoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var desplazamiento: CGFloat = 0
    @State private var desplazamientoPrevio: CGFloat = 0

    var body: some View {
        GeometryReader { geometria in
            let ancho = geometria.size.width
            let alto = geometria.size.height
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
                                let x = desplazamientoPrevio + value.translation.width
                                desplazamiento = min(max(x, -limite), limite)
                            }
                            .onEnded { _ in desplazamientoPrevio = desplazamiento }
                    )
                    // Recortamos la ilustracion al tamano de la pantalla.
                    // Asi los controles flotantes permanecen visibles.
                    .frame(width: ancho, height: alto)
                    .clipped()

                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Label("Volver", systemImage: "chevron.left")
                                .font(.headline)
                                .padding(10)
                                .background(Color.black.opacity(0.55))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                        Text("PANORAMA SIMULADO")
                            .font(.caption).bold()
                            .padding(10)
                            .background(Color.black.opacity(0.65))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 20)

                    Spacer()

                    VStack(spacing: 6) {
                        Text("Times Square, Nueva York")
                            .font(.headline)
                        Text("Desliza a izquierda o derecha para explorar la ilustracion")
                            .font(.caption)
                        Text("No es Look Around real ni imagen en vivo")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.62))
                }
                .frame(width: ancho, height: alto)
            }
            .frame(width: ancho, height: alto)
            .clipped()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View { ContentView() }
}
