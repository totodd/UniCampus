//
//  ARVC.swift
//  Mapwize
//
//  Created by TOTO on 29/1/19.
//  Copyright © 2019 MapWize. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import MapwizeForMapbox

class ARVC: UIViewController {

    var direction: MWZDirection?
    
//    var locationData: LocationData!
    private var updateNodes: Bool = false
    private var locationService = LocationService()

//    private var steps: [MKRouteStep] = []
    private var locations: [CLLocation] = []
    internal var startingLocation: CLLocation!
    
    private var destinationLocation: CLLocationCoordinate2D!
    private var currentLegs: [[CLLocationCoordinate2D]] = []
//    internal var annotations: [POIAnnotation] = []
    private let configuration = ARWorldTrackingConfiguration()
    private var done: Bool = false
    private var updatedLocations: [CLLocation] = []
    private var nodes: [BaseNode] = []
    private var anchors: [ARAnchor] = []


    @IBOutlet weak var sceneView: ARSCNView!
    
    private var locationUpdates: Int = 0 {
        didSet {
            if locationUpdates >= 4 {
                updateNodes = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupLocationService()

        setupNavigation()
        startNavigation()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ARVC {
    private func setupScene() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        navigationController?.setNavigationBarHidden(false, animated: true)
        runSession()
    }

    private func setupLocationService() {
        locationService = LocationService()
        locationService.delegate = self
    }
    
    private func setupNavigation() {
        locations = getLocationData()
//            steps.append(contentsOf: locationData.steps)
//            currentLegs.append(contentsOf: locationData.legs)
//            let coordinates = currentLegs.flatMap { $0 }
//            locations = coordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
//            annotations.append(contentsOf: annotations)
//            destinationLocation = locationData.destinationLocation.coordinate
        done = true
    }
    
    
    func runSession() {
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func startNavigation(){
        updateNodes = true
        if updatedLocations.count > 0 {
            startingLocation = getStartLocation()
            if (startingLocation != nil ) && done == true {
                DispatchQueue.main.async {
//                    self.centerMapInInitialCoordinates()
//                    self.showPointsOfInterestInMap(currentLegs: self.currentLegs)
//                    self.addAnnotations()
                    self.addAnchors()
                }
            }
        }
    }
    
    //TODO:  get start location

    
    private func getLocationData() -> [CLLocation]{
        var res = [CLLocation]()
        let coord = self.direction?.routes.first?.path.map{$0.coordinates}
        coord?.forEach({ (co) in
            res.append(CLLocation(latitude: co.latitude, longitude: co.longitude))
        })
        return res
    }
    
    private func getStartLocation() -> CLLocation{
        return CLLocation.bestLocationEstimate(locations: updatedLocations)
    }
}

extension ARVC : ARSCNViewDelegate{

    // MARK: - ARSCNViewDelegate

    func session(_ session: ARSession, didFailWithError error: Error) {
        presentMessage(title: "Error", message: error.localizedDescription)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        presentMessage(title: "Error", message: "Session Interuption")
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            print("ready")
        case .notAvailable:
            print("wait")
        case .limited(let reason):
            print("limited tracking state: \(reason)")
        }
    }
}

extension ARVC {
    
    private func addAnchors() {
        guard startingLocation != nil else { return }
//        for step in steps { addSphere(for: step) }
        for location in locations { addSphere(for: location) }
        //        addSpheres(for: locations)
    }
    
    private func addSphere(for location: CLLocation) {
        let locationTransform = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: startingLocation, location: location)
        let stepAnchor = ARAnchor(transform: locationTransform)
        let sphere = BaseNode(title: "Title", location: location)
        sphere.addSphere(with: 0.25, and: .blue)
        if nodes.count > 1{
            let lastNode = nodes[nodes.count - 1]
            if let transform = lastNode.childNodes.first?.childNodes.first?.worldTransform{
                let trans = float4x4(transform)
                let thirdColumn = trans.columns.3
                sphere.look(at: SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z))
                print(thirdColumn)
            }
        }
        anchors.append(stepAnchor)
        sphere.location = location
        sceneView.session.add(anchor: stepAnchor)
        sceneView.scene.rootNode.addChildNode(sphere)
        sphere.anchor = stepAnchor
        nodes.append(sphere)
    }
}

extension ARVC {
    func presentMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}

extension float4x4 {
    init(_ matrix: SCNMatrix4) {
        self.init([
            float4(matrix.m11, matrix.m12, matrix.m13, matrix.m14),
            float4(matrix.m21, matrix.m22, matrix.m23, matrix.m24),
            float4(matrix.m31, matrix.m32, matrix.m33, matrix.m34),
            float4(matrix.m41, matrix.m42, matrix.m43, matrix.m44)
            ])
    }
}

extension ARVC: LocationServiceDelegate {
    func updateBeacon(beacon: CLBeacon) {
        print()
    }
    
    
    func trackingLocation(for currentLocation: CLLocation) {
        if currentLocation.horizontalAccuracy <= 65.0 {
            updatedLocations.append(currentLocation)
            updateNodePosition()
        }
    }
    
    func trackingLocationDidFail(with error: Error) {
        presentMessage(title: "Error", message: error.localizedDescription)
    }
    
    private func updateNodePosition() {
        if updateNodes {
            locationUpdates += 1
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            if updatedLocations.count > 0 {
                startingLocation = getStartLocation()
                for baseNode in nodes {
                    let translation = MatrixHelper.transformMatrix(for:  matrix_identity_float4x4, originLocation: startingLocation, location: baseNode.location)
                    let position = SCNVector3.positionFromTransform(translation)
                    let distance = baseNode.location.distance(from: startingLocation)
                    DispatchQueue.main.async {
                        let scale = 100 / Float(distance)
                        baseNode.scale = SCNVector3(x: scale, y: scale, z: scale)
                        baseNode.anchor = ARAnchor(transform: translation)
                        baseNode.position = position
                    }
                }
            }
            SCNTransaction.commit()
        }
    }
}
