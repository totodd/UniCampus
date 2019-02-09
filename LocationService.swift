//
//  LocationService.swift
//  ARKitDemoApp
//
//  Created by Christopher Webb-Orenstein on 8/27/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

final class LocationService: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var delegate: LocationServiceDelegate?
    var currentLocation: CLLocation?
    var initial: Bool = true
    var userHeading: CLLocationDirection!
    var locations: [CLLocation] = []
    var beaconsFound: CLBeacon?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        
        
        requestAuthorization(locationManager: locationManager)
        
//        switch(CLLocationManager.authorizationStatus()) {
//        case .authorizedAlways, .authorizedWhenInUse:
//            startUpdatingLocation(locationManager: locationManager)
//            lastLocation = locationManager.location
//        case .notDetermined, .restricted, .denied:
//            stopUpdatingLocation(locationManager: locationManager)
//            locationManager.requestWhenInUseAuthorization()
//        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
    }
    
    func requestAuthorization(locationManager: CLLocationManager) {
        locationManager.requestAlwaysAuthorization()
        switch(CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation(locationManager: locationManager)
        case .denied, .notDetermined, .restricted:
            stopUpdatingLocation(locationManager: locationManager)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }
        
        let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        userHeading = heading
        NotificationCenter.default.post(name: Notification.Name(rawValue:"myNotificationName"), object: self, userInfo: nil)
    }
    
    func startUpdatingLocation(locationManager: CLLocationManager) {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingLocation(locationManager: CLLocationManager) {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            delegate?.trackingLocation(for: location)
        }
        currentLocation = manager.location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        updateLocationDidFailWithError(error: error as NSError)
    }
    
    func updateLocation(currentLocation: CLLocation) {
        guard let delegate = delegate else { return }
        delegate.trackingLocation(for: currentLocation)
    }
    
    func updateLocationDidFailWithError(error: Error) {
        guard let delegate = delegate else { return }
        delegate.trackingLocationDidFail(with: error)
    }
}

extension LocationService {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        rangeBeacons()
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("did range beacons in \(region.identifier)")
        guard let discoveredBeacon = beacons.first else { return }
        guard let delegate = delegate else { return }
        let beaconRange = discoveredBeacon.proximity
//        if beaconRange == .immediate{
//            beaconsFound = discoveredBeacon
//        }
//        print(beacons.count)
        delegate.updateBeacon(beacon: discoveredBeacon)
    }
    
    func rangeBeacons(){
        
        let id = "BeaconRegiontest"
        //        let region = CLBeaconRegion(proximityUUID: uuid, major: major, identifier: id)
        let region = CLBeaconRegion(proximityUUID: LocationConstants.uuid, major: LocationConstants.major, minor: LocationConstants.minor, identifier: id)
        region.notifyOnExit = true
        region.notifyOnEntry = true
        region.notifyEntryStateOnDisplay = true
        locationManager?.startRangingBeacons(in: region)
        locationManager?.startMonitoring(for: region)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(region.identifier)
        pushNotification(str: "enter")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print(region.identifier)
        pushNotification(str: "exit")
    }
    
    func pushNotification(str: String){
        let content = UNMutableNotificationContent()
        content.title = str
        content.launchImageName = "faceless"
        content.body = " I am body"
        content.sound = UNNotificationSound.default()
        let request3 = UNNotificationRequest(identifier: "notId2", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request3, withCompletionHandler: nil)
    }
}
