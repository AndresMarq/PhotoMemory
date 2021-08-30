//
//  MapView.swift
//  PhotoMemory
//
//  Created by Andres Marquez on 2021-08-14.
//
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    
    var annotation: MKPointAnnotation
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.addAnnotation(annotation)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}
