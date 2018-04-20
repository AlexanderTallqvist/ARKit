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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the views delegate
        imageDetectionSceneView.delegate = self
        
        imageDetectionSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                             ARSCNDebugOptions.showWorldOrigin]
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        imageDetectionSceneView.scene = scene
    }
    
    // This function gets called whenever an image gets detected
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARImageAnchor {
            
            guard let imageAnchor = anchor as? ARImageAnchor else { return }
            let referenceImage = imageAnchor.referenceImage
            let imageName = referenceImage.name!
            
            // Grab our 3d model
            let modelScene = SCNScene(named: "ImageDetection/\(imageName).scn")!
            
            // Grab the node parent node from our 3d model
            let modelNode = modelScene.rootNode
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configurations
        let configuration = ARWorldTrackingConfiguration()
        
        // Our image reference
        if #available(iOS 11.3, *) {
            guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
                fatalError("Missing expected asset resources.")
            }

            configuration.detectionImages = referenceImages
        } else {
            fatalError("IOS version of 11.3 needed.")
        }
        
        imageDetectionSceneView.session.run(configuration)
    }

}
