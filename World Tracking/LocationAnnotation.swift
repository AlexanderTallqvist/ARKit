//
//  LocationAnnotation.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 06/04/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import Foundation
import ARCL
import CoreLocation
import SceneKit

class LocationAnnotation : LocationNode {
    
    var title :String!
    var distance :String!
    var annotationNode :SCNNode
    
    init(location: CLLocation?, title: String, distance: String) {
        self.annotationNode = SCNNode()
        self.title = title
        self.distance = distance
        super.init(location: location)
        self.createUI()
        print(title)
    }
    
    // Required by LocationNode
    required init?(coder aDecoder: NSCoder) {
        fatalError("Error")
    }
    
    private func createUI() {
        let plane = SCNPlane(width: 5, height: 3)
        plane.cornerRadius = 0.2
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        
        // Text nodes
        let text = SCNText(string: self.createTextString(), extrusionDepth: 0)
        text.containerFrame = CGRect(x: 0, y: 0, width: 5, height: 3)
        text.isWrapped = true
        text.font = UIFont(name: "Futura", size: 0.35)
        text.alignmentMode = kCAAlignmentCenter
        text.truncationMode = kCATruncationMiddle
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(0, 0, 0.2)
        centerText(node: textNode)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.addChildNode(textNode)
        
        self.annotationNode.scale = SCNVector3(3,3,3)
        self.annotationNode.addChildNode(planeNode)
        
        // Crate a bilboard constraint, so that our annotations are always facing us
        let bilboardConstraint = SCNBillboardConstraint()
        bilboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [bilboardConstraint]
        
        self.addChildNode(self.annotationNode)
    }
    
    // Function for centering our text
    private func centerText(node: SCNNode) {
        let (min, max) = node.boundingBox
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        node.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
    }
    
    private func createTextString() -> String {
        let returnString = self.title + " - Distance: " + self.distance + " km"
        return returnString
    }
}
