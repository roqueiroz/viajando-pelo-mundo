//
//  MapViewController.swift
//  ViajandoPeloMundo
//
//  Created by Rodrigo Queiroz on 21/09/20.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var vwInfo: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    var places: [Place]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
        
        for place in places {
            addToMap(place)
        }
        
    }
    
    //MARK: Functions
    private func configView() {
        
        mapView.delegate = self
        
        searchBar.isHidden = true
        vwInfo.isHidden = true
        
        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus Lugares"
        }
    }
    
    private func addToMap(_ place: Place) {
        
        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
        annotation.title = place.name
        annotation.address = place.address
        
        mapView.addAnnotation(annotation)
        
        showPlaces()
    }
    
    private func showPlaces() {
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        
    }
    
    //MARK: Action
    @IBAction func showRoute(_ sender: Any) {
    }
    
    @IBAction func showSearchBar(_ sender: Any) {
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is PlaceAnnotation) {
            return nil
        }
        
        let type = (annotation as! PlaceAnnotation).type
        let identifier =  "\(type)"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "poi")
        annotationView?.glyphImage = type == .place ? UIImage(named: "placeGlyph") : UIImage(named: "poiGlyph")
        annotationView?.displayPriority = type == .place ? .required : .defaultHigh
        
        return annotationView
    }
    
}
