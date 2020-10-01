//
//  PlaceFinderViewController.swift
//  ViajandoPeloMundo
//
//  Created by Rodrigo Queiroz on 21/09/20.
//

import UIKit
import MapKit

protocol PlaceFinderDelegate: class {
    func addPlace(_ place: Place)
}

class PlaceFinderViewController: UIViewController {
    
    enum PlaceFinderMessageType {
        case error(String)
        case confirmation(String)
    }
    
    
    @IBOutlet weak var txtPlaces: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viewLoading: UIView!
    
    var place: Place!
    weak var delegate: PlaceFinderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_:)))
        gesture.minimumPressDuration = 2.0
        
        mapView.addGestureRecognizer(gesture)
    }
    
    //MARK: Functions
    private func load(show: Bool) {
        
        viewLoading.isHidden = !show
        
        show ? aiLoading.startAnimating() : aiLoading.stopAnimating()
        
    }
    
    @objc private func getLocation(_ gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            
            load(show: true)
            
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                
                if error == nil {
                    
                    if !self.savePlace(with: placemarks?.first) {
                        self.showMessage(type: .error("Ops..Algo deu erro!"))
                    }
                    
                } else {
                    self.showMessage(type: .error("Local não encontrado!"))
                }
                
                self.load(show: false)
                
            }
        }
        
    }
    
    private func savePlace(with placeMark: CLPlacemark?) -> Bool {
        
        guard let placeMark = placeMark,
              let coordinate = placeMark.location?.coordinate else {
            return false
        }
        
        let name = placeMark.name ?? placeMark.country ?? "unknown"
        
        place = Place(
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            address: Place.getFormattedAddress(with: placeMark))
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        
        mapView.setRegion(region, animated: true)
        
        self.showMessage(type: .confirmation(place.name))
        
        return true
    }
    
    private func showMessage(type: PlaceFinderMessageType) {
        
        let title: String, message: String
        var hasConfirmation: Bool = false
        
        switch type {
        case .confirmation(let name):
            title = ""
            message = "Deseja adicionar \(name)"
            hasConfirmation = true
            
        case .error(let errorMessage):
            title = "Erro"
            message = errorMessage
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(cancelAction)
        
        if hasConfirmation {
            
            let confirmAction = UIAlertAction(title: "Ok", style: .default) { (action) in
               
                self.delegate?.addPlace(self.place)
                self.dismiss(animated: true, completion: nil)
                
            }
            
            alert.addAction(confirmAction)
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: Actions
    @IBAction func btnFindPlaces(_ sender: Any) {
        
        load(show: true)
        
        txtPlaces.resignFirstResponder()
        
        let place = txtPlaces.text!
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(place) {
            
            (placemarks, error) in
            
            if error == nil {
                
                if !self.savePlace(with: placemarks?.first) {
                    self.showMessage(type: .error("Ops..Algo deu erro!"))
                }
                
            } else {
                self.showMessage(type: .error("Local não encontrado!"))
            }
            
            self.load(show: false)
        }
        
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
