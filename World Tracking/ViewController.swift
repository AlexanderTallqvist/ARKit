//
//  ViewController.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 30/01/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // Our sceneView
    @IBOutlet weak var sceneView: ARSCNView!
    
    // Our labels
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    // Our staring position
    var startingPosition: SCNNode?
    
    // This is going to track the phones position and orientation
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add debugg options
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin]
        
        // Pass the tracking configurations to our sceneView
        self.sceneView.session.run(configuration)
        
        // Add a tap geasture recognizer
        let tapGeastureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGeastureRecognizer)
        
        // Enables us to trigger our own delegate function
        self.sceneView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Our function to handle the tap event
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        // Get the current frame
        guard let currentFrame = sceneView.session.currentFrame else {return}
        // Stop measuring the distance when we tap the screen again
        if self.startingPosition != nil {
            self.startingPosition?.removeFromParentNode()
            self.startingPosition = nil
            return
        }
        // Access the cameras location
        let camera = currentFrame.camera
        // Access the position of the cameras transform matrix
        let transform = camera.transform
        // Create another matrix in order to place the spehere infront of the camera
        var translationMatrix = matrix_identity_float4x4
        // We want to set the "dot" 10cm away from the camera
        translationMatrix.columns.3.z = -0.1
        // Multiply our two matrixes aka change our z value in the cameras own matrix
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        // Create our sphere
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.004))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        // Position our spehere infront of the camera
        sphere.simdTransform = modifiedMatrix
        // Add the node to the sceneview
        self.sceneView.scene.rootNode.addChildNode(sphere)
        // Set the starting positon
        self.startingPosition = sphere
    }
    
    // This gets called 60x/second
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Only continue if the user has provided us with a starting position
        guard let startingPosition = self.startingPosition else {return}
        // Cameras point of view
        guard let pointOfView = self.sceneView.pointOfView else {return}
        // Extract the needed matrix values
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        // Calculate the distance traveled
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        
        // Set the values of our labels
        DispatchQueue.main.async {
            self.xLabel.text = "X: " + String(format: "%.2f", xDistance) + " m"
            self.yLabel.text = "Y: " + String(format: "%.2f", yDistance) + " m"
            self.zLabel.text = "Z: " + String(format: "%.2f", zDistance) + " m"
            self.distance.text = "Distance: " + String(format: "%.2f", self.distanceTravelled(x: xDistance, y: yDistance, z: zDistance)) + " m"
        }
    }
    
    // Calculate the diagonal distance
    func distanceTravelled(x: Float, y: Float, z: Float) -> Float {
        // Pythagoras sats
        return (sqrt(x*x + y*y + z*z))
    }
    
    
//    Old buttons
//    @IBAction func add(_ sender: Any) {}
//    @IBAction func reset(_ sender: Any) {}
}

