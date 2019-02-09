//
//  DestinationAnnotation.swift
//  ARKitNavigationDemo
//
//  Created by TOTO on 20/1/19.
//  Copyright © 2019 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation
import MapKit

class DestinationAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
    
    
}
