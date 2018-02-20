//
//  ViewController.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 30/01/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    // Our sceneView
    @IBOutlet weak var sceneView: ARSCNView!
    
    // This is going to track the phones position and orientation
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add debugg options
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin]
        
        
        // Pass the tracking configurations to our sceneView
        self.sceneView.session.run(configuration)
        // Add a light srouce
        self.sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func add(_ sender: Any) {
//        let node = SCNNode()
//        // Create a "Box", and set its width, height, length and border-radius
//        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.33)
//        // Reflect light of the surface
//        node.geometry?.firstMaterial?.specular.contents = UIColor.white
//        // Fill the box with the color blue
//        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//        // Set the position of the node (X,Y,Z)
//        let x = self.randomNumbers(firstNum: 0.3, secondNum: -0.3)
//        let y = self.randomNumbers(firstNum: 0.3, secondNum: -0.3)
//        let z = self.randomNumbers(firstNum: 0.3, secondNum: -0.3)
//        node.position = SCNVector3(x, y, z)
//        // Add our node to the root node
//        self.sceneView.scene.rootNode.addChildNode(node)
        self.createHouse()
    }
    
    @IBAction func reset(_ sender: Any) {
        self.restartSession()
    }
    
    func createHouse() {
        // Create a door node
        let doorNode = SCNNode(geometry: SCNPlane(width: 0.03, height: 0.06))
        doorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        
        // Create a box node
        let boxNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        // Create our child node, and make it a pyramid
        let node = SCNNode()
        node.geometry = SCNPyramid(width: 0.1, height: 0.1, length: 0.1)
        node.geometry?.firstMaterial?.specular.contents = UIColor.orange
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
        // Position all of our 3 nodes
        node.position = SCNVector3(0.2,0.3,-0.2)
        boxNode.position = SCNVector3(0, -0.05, 0)
        doorNode.position = SCNVector3(0,-0.02,0.053)
        
        // Add our nodes (a house) to our root node
        self.sceneView.scene.rootNode.addChildNode(node)
        node.addChildNode(boxNode)
        boxNode.addChildNode(doorNode)
    }
    
    func restartSession() {
        self.sceneView.session.pause()
        
        // Loop through the rootNodes childnodes, and remove our node
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        
        // Reset the sessions tracking and anchors
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    // Helper function that generates random values for us
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}

