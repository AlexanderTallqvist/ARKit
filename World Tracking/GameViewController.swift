//
//  GameViewController.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 04/03/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import UIKit
import ARKit
import Each

class GameViewController: UIViewController {
    
    // Import ARKit SceneView
    @IBOutlet weak var GameSceneView: ARSCNView!
    
    // Create a timer that counts up by 1 seconnd, using the "Each" library
    var timer = Each(1).seconds
    
    // Score and countdown variables
    var countdown = 20
    var score = 0
    
    // Add world tracking in order to track the position of our device.
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add debugg options
        self.GameSceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
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
    
    // Our score and time labels
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    // Import our buttons
    @IBOutlet weak var Play: UIButton!
    
    @IBAction func Reset(_ sender: Any) {
        // Stop the timer, and re-enable the play button
        self.timer.stop()
        self.restoreTimer()
        self.Play.isEnabled = true
        // Reset the score
        self.scoreLabel.text = "Score: 0"
        self.score = 0
        
        // Remove all all childeren from our root sceneView
        GameSceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if (node.name != nil && node.name != "") {
                if (node.name == "Bottle") {
                    node.removeFromParentNode()
                }
            }
        }
    }
    
    @IBAction func Play(_ sender: Any) {
        // Start the timer
        self.setTimer()
        // Add our first node
        self.addNode()
        // Disable the play button temporarely
        self.Play.isEnabled = false
        // Reset our score
        self.scoreLabel.text = "Score: 0"
    }
    
    // This function will add our game target node
    func addNode() {
        // Create a scene with our 3d model
        let bottleScene = SCNScene(named: "Models.scnassets/beer.scn")
        // Convert the scene to a node
        let bottleNode = bottleScene?.rootNode.childNode(withName: "bottle", recursively: false)
        // Give our new node a position
        bottleNode?.position = SCNVector3(ran(firstNum: -1, secondNum: 1), ran(firstNum: -0.5, secondNum: 0.5), ran(firstNum: -1, secondNum: 1))
        // Add it to our root node
        bottleNode?.name = "Bottle"
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
            // Allso get the node for referencing the name
            let result = hitTest.first!
            let node = result.node
            // Run our checks
            if (node.name != nil && node.name != "") {
                if (node.name == "Bottle") {
                    
                    // If we still have time left
                    if countdown > 0 {
                        
                        // Add our audio file
                        if let source = SCNAudioSource(fileNamed: "Models.scnassets/glass.mp3") {
                            source.volume = 1
                            source.isPositional = true
                            source.shouldStream = true
                            source.loops = false
                            source.load()
                            let player = SCNAudioPlayer(source: source)
                            node.addAudioPlayer(player)
                        }
                        
                        let result = hitTest.first!
                        let node = result.node
                        // Only run the animation once, and start an SCNTransacrion
                        if node.animationKeys.isEmpty {
                            SCNTransaction.begin()
                            self.animateNode(node: node)
                            // Remove our botthe when the aninmation is complete
                            SCNTransaction.completionBlock = {
                                node.removeFromParentNode()
                                // And add a new random botthe to the scene
                                self.addNode()
                                // Restore the timer after we hit each node
                                self.restoreTimer()
                                // Increase our score
                                self.score += 1
                                self.scoreLabel.text = "Score: " + String(self.score)
                            }
                            SCNTransaction.commit()
                        }
                    }
                }
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
    func ran(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timeLabel.text = "Time: " + String(self.countdown)
            if self.countdown == 0 {
                self.timeLabel.text = "You lose!"
                return .stop
            }
            return .continue
        }
    }
    
    // Function for restoring our timer
    func restoreTimer() {
        self.countdown = 20
        self.timeLabel.text = String("Time: 20")
        
    }
}





