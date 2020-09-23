//
//  PlaceFinderViewController.swift
//  ViajandoPeloMundo
//
//  Created by Rodrigo Queiroz on 21/09/20.
//

import UIKit
import MapKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: Functions
    private func load(show: Bool) {
        
        viewLoading.isHidden = !show
        
        show ? aiLoading.startAnimating() : aiLoading.stopAnimating()
        
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
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        mapView.setRegion(region, animated: true)
        
        //self.showMessage(type: .confirmation(place.name))
        
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
                print("Ok!!!")
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
