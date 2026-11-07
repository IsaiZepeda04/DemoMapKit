
import SwiftUI
import MapKit

// Permite utilizar Look Around de UIKit en SwiftUI
struct LookAroundView: UIViewControllerRepresentable {

    // Escena panorámica seleccionada
    let scene: MKLookAroundScene

    // Crea el controlador de Look Around
    func makeUIViewController(
        context: Context
    ) -> MKLookAroundViewController {

        let controlador = MKLookAroundViewController()

        // Asignamos la escena panorámica
        controlador.scene = scene

        return controlador
    }

    // Actualiza el controlador cuando cambia la escena
    func updateUIViewController(
        _ uiViewController: MKLookAroundViewController,
        context: Context
    ) {

        uiViewController.scene = scene
    }
}
