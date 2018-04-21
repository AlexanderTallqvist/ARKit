//
//  ImageDetectionViewController.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 20/04/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ImageDetectionViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var imageDetectionSceneView: ARSCNView!
    
    @IBOutlet weak var InfoArea: UILabel!
    
    @IBOutlet weak var DetectionLabel: UILabel!
    
    
    var googleFacts =   "    THE Google Pixel" + "\n" +
                        "    Age: 4.6 Billion Years" + "\n" +
                        "    Type: Yellow Dwarf (G2V)" + "\n" +
                        "    Diameter: 1,392,684 km" + "\n" +
                        "    Equatorial Circumference 4,370,005.6 km" + "\n" +
                        "    Mass: 1.99 × 10^30 kg (333,060 Earths)" + "\n" +
                        "    Surface Temperature: 5,500 °C"
    
    var vaseFacts =     "    THE MOON" + "\n" +
                        "    Diameter: 3,475 km" + "\n" +
                        "    Mass: 7.35 × 10^22 kg (0.01 Earths)" + "\n" +
                        "    Orbits: The Earth" + "\n" +
                        "    Orbit Distance: 384,400 km" + "\n" +
                        "    Orbit Period: 27.3 days" + "\n" +
                        "    Surface Temperature: -233 to 123 °C"
    
    // Configurations
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageDetectionSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                             ARSCNDebugOptions.showWorldOrigin]
        
        // Our image reference
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset resources.")
        }
        configuration.detectionImages = referenceImages
        
        
        self.imageDetectionSceneView.session.run(configuration)
        
        // Set the views delegate
        self.imageDetectionSceneView.delegate = self
        
        // Register our gesture recognizer
        self.registerGestureRecognizers()
    }
    
    // Register user tap gesture (needs to be exposed to objeC
    func registerGestureRecognizers() {
        // Create the "tap" geasture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))

        // Add our custom tap recognizers to the scene view
        self.imageDetectionSceneView.addGestureRecognizer(tapGestureRecognizer)
    }


    // Our "tap" function
    @objc func tapped(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let tappedLocation = sender.location(in: sceneView)

        // Check if we "tapped" an object
        let hitTest = sceneView.hitTest(tappedLocation)
        if !hitTest.isEmpty {
            let results = hitTest.first!
            let node = results.node
            if (node.name != nil && node.name != "") {
                if((node.name!) == "Google") {
                    self.InfoArea.text = self.googleFacts
                }
                if(node.name! == "Vase") {
                    self.InfoArea.text = self.vaseFacts
                }
            }
        }
    }

    // This function gets called whenever an image gets detected
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        DispatchQueue.main.async {
            self.DetectionLabel.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.DetectionLabel.isHidden = true
        }
        
        if anchor is ARImageAnchor {

            guard let imageAnchor = anchor as? ARImageAnchor else { return }
            let referenceImage = imageAnchor.referenceImage
            let imageName = referenceImage.name!

            // Grab our 3d model
            let modelScene = SCNScene(named: "ImageDetection/\(imageName).scn")!

            // Grab the node parent node from our 3d model
            let modelNode = modelScene.rootNode
            modelNode.name = imageName

            // Get the camersas position (use guard to guarantee a value)
            guard let pointOfView = imageDetectionSceneView.pointOfView else { return }

            // Extract position from the transform matrix
            let transform = pointOfView.transform

            // Rotate our object
            let rotateAction = SCNAction.rotateBy(x: 0, y: 0.5, z: 0, duration: 1)
            let infiniteAction = SCNAction.repeatForever(rotateAction)
            modelNode.runAction(infiniteAction)

            // Postion our 3d model
            //modelNode.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
            modelNode.position = SCNVector3(transform.m41, transform.m42, transform.m43)
            self.imageDetectionSceneView.scene.rootNode.addChildNode(modelNode)

        }
    }

}
