//
//  GameViewController.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 04/03/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import UIKit
import ARKit

class GameViewController: UIViewController {
    
    // Import ARKit SceneView
    @IBOutlet weak var GameSceneView: ARSCNView!
    
    // Add world tracking in order to track the position of our device.
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add debugg options
        self.GameSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                             ARSCNDebugOptions.showWorldOrigin]
        // Add our configurations to our session
        self.GameSceneView.session.run(configuration)
        
        // Add a "tap" geasture recognizer
        let tapGeastureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        // Recognize any taps that occure in the scene view
        self.GameSceneView.addGestureRecognizer(tapGeastureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Import our buttons
    @IBOutlet weak var Play: UIButton!
    
    @IBAction func Reset(_ sender: Any) {
    }
    
    @IBAction func Play(_ sender: Any) {
        self.addNode()
        // Disable the play button temporarely
        self.Play.isEnabled = false
    }
    
    // This function will add our game target node
    func addNode() {
        // Create a scene with our 3d model
        let bottleScene = SCNScene(named: "Models.scnassets/beer.scn")
        // Convert the scene to a node
        let bottleNode = bottleScene?.rootNode.childNode(withName: "bottle", recursively: false)
        // Give our new node a position
        bottleNode?.position = SCNVector3(0,0,-1)
        // Add it to our root node
        self.GameSceneView.scene.rootNode.addChildNode(bottleNode!)
    }
    
    // Handle the tapping of an object
    // The paremeter UITapGestureRecognizer if going to give us information
    // about the object that was tapped
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        // The our "touch cordinates"
        let touchCordinates = sender.location(in: sceneViewTappedOn)
        // Check if we "hit" an object
        let hitTest = sceneViewTappedOn.hitTest(touchCordinates)
        
        if hitTest.isEmpty {
            print("NO MATCH")
        } else {
            print("TOUCHED")
            let result = hitTest.first!
            let node = result.node
            // Only run the animation once
            if node.animationKeys.isEmpty {
                self.animateNode(node: node)
            }
        }
    }
    
    // Animation function
    func animateNode(node: SCNNode) {
        // Animate the nodes position
        let spin = CABasicAnimation(keyPath: "position")
        // Get the current state of the object in the sceneview
        spin.fromValue = node.presentation.position
        // Do  the animation relative to the nodes current position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.1,
                                  node.presentation.position.y - 0.1,
                                  node.presentation.position.z - 0.1)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 3
        node.addAnimation(spin, forKey: "position")
    }
    
    // Function for generating a random number for our bottles position
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}





