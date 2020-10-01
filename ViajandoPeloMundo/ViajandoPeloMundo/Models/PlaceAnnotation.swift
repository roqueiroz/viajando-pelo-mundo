//
//  PlaceAnnotation.swift
//  ViajandoPeloMundo
//
//  Created by Rodrigo Queiroz on 01/10/20.
//

import Foundation
import MapKit

enum PlaceType {
    case place
    case poi
}

class PlaceAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: PlaceType
    var address: String?
    
    init(coordinate:  CLLocationCoordinate2D, type: PlaceType) {
        self.coordinate = coordinate
        self.type = type
    }
    
}
