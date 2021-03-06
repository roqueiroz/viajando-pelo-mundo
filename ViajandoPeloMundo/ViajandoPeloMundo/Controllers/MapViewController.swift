//
//  MapViewController.swift
//  ViajandoPeloMundo
//
//  Created by Rodrigo Queiroz on 21/09/20.
//

import UIKit
import MapKit

enum MapMessageType {
    case routeError
    case authorizationWarning
}

class MapViewController: UIViewController {

    //MARKL Outlet`s
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var vwInfo: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    //MARK: Variaveis
    var places: [Place]!
    var poiList: [MKAnnotation] = []
    lazy var locationManager = CLLocationManager()
    var btnUserLocation: MKUserTrackingButton!
    var selectedAnnotation: PlaceAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
        
        for place in places {
            addToMap(place)
        }
        
        configLocationButton()
        showPlaces()
//        requestUserLocationAuthorization()
        
    }
    
    //MARK: Functions
    private func showInfo() {
            
        lblName.text = selectedAnnotation!.title
        lblAddress.text = selectedAnnotation!.address
        
        vwInfo.isHidden = false
        
    }
    
    private func configLocationButton() {
    
        btnUserLocation = MKUserTrackingButton(mapView: mapView)
        btnUserLocation.backgroundColor = .white
        btnUserLocation.frame.origin.x = 10
        btnUserLocation.frame.origin.y = 10
        btnUserLocation.layer.cornerRadius = 5
        btnUserLocation.layer.borderWidth = 1
        btnUserLocation.layer.borderColor = UIColor(named: "main")?.cgColor
        
    }
    
    private func configView() {
        
        locationManager.delegate = self
        
        mapView.delegate = self
        mapView.mapType = .mutedStandard
        
        searchBar.isHidden = true
        searchBar.searchTextField.backgroundColor = UIColor.white
        searchBar.searchTextField.textColor = UIColor(named: "main")
        
        vwInfo.isHidden = true
        
        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus Lugares"
        }
    }
    
    private func requestUserLocationAuthorization() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch locationManager.authorizationStatus  {
            
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.addSubview(btnUserLocation)
                
            case .denied:
                showMessage(type: .authorizationWarning)
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            case .restricted:
                break
                
            default:
                break
                
            }
            
        }
        
    }
    
    private func addToMap(_ place: Place) {
        
        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
        annotation.title = place.name
        annotation.address = place.address
        
        mapView.addAnnotation(annotation)
        
        
    }
    
    private func showPlaces() {
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        
    }
    
    private func showMessage(type: MapMessageType) {
        
        let title = type == .authorizationWarning ? "Aviso": "Erro"
        let message = type == .authorizationWarning ? "Você precisa permitar o uso da localização na tela de Configurações." : "Não foi possivel encontrar a rota."
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(cancelAction)
        
        if type == .authorizationWarning {
            
            let confirmAction = UIAlertAction(title: "Configurações", style: .default, handler: {
                
                (action) in
                
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
                
            })
            
            alert.addAction(confirmAction)
            
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: Action
    @IBAction func showRoute(_ sender: Any) {
    }
    
    @IBAction func showSearchBar(_ sender: Any) {
        
        searchBar.isHidden = !searchBar.isHidden
        searchBar.resignFirstResponder()
    }
    
}

//MARK: Extension`s
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        let status = manager.authorizationStatus
        
        switch status {
        
        case .notDetermined, .denied:
            self.requestUserLocationAuthorization()
            
        case .authorizedAlways, .authorizedWhenInUse:
            
            self.mapView.showsUserLocation = true
            self.mapView.addSubview(btnUserLocation)
            
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "wantAccurateLocation", completion: { [self]
                error in
                
                locationManager.startUpdatingLocation()
            })
            
        default:
            break
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let camera = MKMapCamera()
        camera.centerCoordinate = view.annotation!.coordinate
        camera.pitch = 80
        camera.altitude = 100
        
        mapView.setCamera(camera, animated: true)
        
        selectedAnnotation = (view.annotation as! PlaceAnnotation)
        self.showInfo()
    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//
//        switch status {
//        case .authorizedAlways, .authorizedWhenInUse:
//
//            mapView.showsUserLocation = true
//            mapView.addSubview(btnUserLocation)
//
//            locationManager.startUpdatingLocation()
//
//        default:
//            break
//        }
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
    }
    
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        loading.startAnimating()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        
        let service = MKLocalSearch(request: request)
        service.start {
            
            (response, error) in
            
            if error == nil {
                
                guard response == response else {
                    self.loading.stopAnimating()
                    return
                }
                
                self.mapView.removeAnnotations(self.poiList)
                self.poiList.removeAll()
                
                for item in response!.mapItems {
                    
                    let annotation = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .poi)
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.address = Place.getFormattedAddress(with: item.placemark)
                    
                    self.poiList.append(annotation)
                    
                    self.mapView.addAnnotations(self.poiList)
                    self.mapView.showAnnotations(self.poiList, animated: true)
                    
                    self.loading.stopAnimating()
                    
                }
                
            }
            
        }
        
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
