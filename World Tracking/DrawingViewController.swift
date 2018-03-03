//
//  DrawingViewController.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 10/02/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import UIKit
import ARKit

// Note that we extend ARSCNViewDelegate
class DrawingViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var drawingSceneView: ARSCNView!
    @IBOutlet weak var draw: UIButton!
    
    var currentColor = UIColor.blue
    
    // Our color changers
    @IBAction func purpleColor(_ sender: Any) {
        self.currentColor = UIColor.purple
    }
    @IBAction func yellowColor(_ sender: Any) {
        self.currentColor = UIColor.yellow
    }
    @IBAction func brownColor(_ sender: Any) {
        self.currentColor = UIColor.brown
    }
    @IBAction func greenColor(_ sender: Any) {
        self.currentColor = UIColor.green
    }
    @IBAction func blueColor(_ sender: Any) {
        self.currentColor = UIColor.blue
    }
    @IBAction func redColor(_ sender: Any) {
        self.currentColor = UIColor.red
    }
    // This is going to track the phones position and orientation
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add debugg options
        self.drawingSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin]
        
        // Show statistics
        self.drawingSceneView.showsStatistics = true;

        // Pass the tracking configurations to our drawingSceneView
        self.drawingSceneView.session.run(configuration)
        
        // Call the delegate renender function when a scene is rendered
        self.drawingSceneView.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This function gets called every time we render a scene (60xsecond)
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {

        // Get the camersas position (use guard to guarantee a value)
        guard let pointOfView = drawingSceneView.pointOfView else { return }
        
        // Extract position from the transform matrix
        let transform = pointOfView.transform
        
        // Get the cameras orientation AKA where is our device facing. (transform.m31 == third column, row one)
        // The orientation is originally reversed, so we pass in negative values
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        
        // Get the cameras location
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        // Combine the two vectors with our custom '+' function
        let currentPositionOfCamera = orientation + location
        
        // Make everything run asyncronosly
        DispatchQueue.main.async {
            // Detect when the draw button is being pressed
            if self.draw.isHighlighted {
                // Create a spehere and give it the current position of the camera
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = currentPositionOfCamera
                
                // Add the spehere to the root node
                self.drawingSceneView.scene.rootNode.addChildNode(sphereNode)
                
                // Give the spehere a color
                sphereNode.geometry?.firstMaterial?.diffuse.contents = self.currentColor
            } else {
                // Give the user a "pointer", to indicate for the user where they will be drawing
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
                pointer.position = currentPositionOfCamera
                
                // Remove the previous pointers
                self.drawingSceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "pointer" {
                     node.removeFromParentNode()
                    }
                })
                self.drawingSceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = self.currentColor
            }
            
            // Orientation debugging
            //print(orientation.x, orientation.y, orientation.z)
        }
    }

}

// Our custom function that takes in two vector positions and returns a new one
func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x  + right.x, left.y + right.y, left.z + right.z)
}
