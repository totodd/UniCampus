//
//  Constants.swift
//  ARKitNavigationDemo
//
//  Created by Christopher Webb-Orenstein on 9/26/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation
import MapKit

struct LocationConstants {
    static let metersPerRadianLat: Double = 6373000.0
    static let metersPerRadianLon: Double = 5602900.0
    static let harrisonAddress = CLLocationCoordinate2D(latitude: -35.2046, longitude: 149.1487)

    static let uuid = UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")!
    static let major : CLBeaconMajorValue = 16160
    static let minor : CLBeaconMinorValue = 48942
}
