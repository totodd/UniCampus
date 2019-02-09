//
//  BaseNode.swift
//  ARKitDemoApp
//
//  Created by Christopher Webb-Orenstein on 8/27/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import SceneKit
import UIKit
import ARKit
import CoreLocation

class BaseNode: SCNNode {
    
    let title: String
    var anchor: ARAnchor?
    var location: CLLocation!
    
    init(title: String, location: CLLocation) {
        self.title = title
        super.init()
//        let billboardConstraint = SCNBillboardConstraint()
//        billboardConstraint.freeAxes = SCNBillboardAxis.Y
//        constraints = [billboardConstraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSphereNode(with radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: geometry)
        return sphereNode
    }
    
    func addSphere(with radius: CGFloat, and color: UIColor) {
        let sphereNode = createSphereNode(with: radius, color: color)
        addChildNode(sphereNode)
//        addChildNode(createArrowNode())
    }
    
    func addNode(with radius: CGFloat, and color: UIColor, and text: String) {
        let sphereNode = createSphereNode(with: radius, color: color)
        let newText = SCNText(string: title, extrusionDepth: 0.05)
        newText.font = UIFont (name: "AvenirNext-Medium", size: 1)
        newText.firstMaterial?.diffuse.contents = UIColor.red
        let _textNode = SCNNode(geometry: newText)
        let annotationNode = SCNNode()
        annotationNode.addChildNode(_textNode)
        annotationNode.position = sphereNode.position
        addChildNode(sphereNode)
        addChildNode(annotationNode)
    }
    
    func createArrowNode() -> SCNNode {
        let scene = SCNScene(named: "3dModels.scnassets/arrow.scn")
        let node = (scene?.rootNode.childNode(withName: "arrow_root", recursively: false))!
        node.pivot = SCNMatrix4MakeRotation(Float.pi/2, 1, 0, 0)
        node.pivot = SCNMatrix4MakeRotation(Float.pi/2*3, 0, 0, 1)
//        node.pivot = SCNMatrix4MakeRotation(Float.pi/2, 0, 1, 0)

//        let transform = hitTestResult.worldTransform
//        let thirdColumn = transform.columns.3
//        node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
//        if selectedItem == "table" {
//            self.centerPivot(for: node)
//        }
        return node
    }
}

