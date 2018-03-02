//
//  IkeaViewController.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 19/02/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import UIKit
import ARKit

// Extend UICollectionVIewDataSrouce because of our collection view
// UICollectionViewDelegate > didSelectItem?
class IkeaViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate {

    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var ikeaSceneView: ARSCNView!
    @IBOutlet weak var planeDetected: UILabel!
    let itemsArray: [String] = ["cup", "vase", "boxing", "table", "shelf"]
    let configuration = ARWorldTrackingConfiguration()
    var selectedItem: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ikeaSceneView.debugOptions = [ ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        // Detect horizontal surfaces
        self.configuration.planeDetection = .horizontal
        self.ikeaSceneView.session.run(configuration)
        
        // Override our extended calsses
        self.itemsCollectionView.dataSource = self
        self.itemsCollectionView.delegate = self
        
        // Register our gesture recognizer
        self.registerGestureRecognizers()
        
        // Register our plane detected label function
        self.ikeaSceneView.delegate = self
        
        // Add a lighting effect
        self.ikeaSceneView.autoenablesDefaultLighting = true;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Register user tap gesture (needs to be exposed to objeC
    func registerGestureRecognizers() {
        // Create the "tap" geasture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        // Create a "pinch" geasture recognizer
        let pinchGeastureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        
        // Create a "long press" recognizer
        let longPressGeastureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
        
        // Add our custom tap, picnch and long press recognizers to the scene view
        self.ikeaSceneView.addGestureRecognizer(pinchGeastureRecognizer)
        self.ikeaSceneView.addGestureRecognizer(tapGestureRecognizer)
        self.ikeaSceneView.addGestureRecognizer(longPressGeastureRecognizer)
    }
    
    // Our "pinch" function
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        
        // Check if we "pinch" an object
        let hitTest = sceneView.hitTest(pinchLocation)
        if !hitTest.isEmpty {
            let results = hitTest.first!
            let node = results.node
            // Scale the node acording to how "far" we pinched it
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(pinchAction)
            // Reset our scaling value to 1, so that the item that
            // we're scaling grows at a constant rate, instead of exponentially
            sender.scale = 1.0
        }
    }
    
    // Our "tap" function
    @objc func tapped(sender: UITapGestureRecognizer) {
        // Check if the surface we tapped is a horizontal surface
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        
        // Matches on a horizontal surface
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        if !hitTest.isEmpty {
            self.addItem(hitTestResult: hitTest.first!)
            print("TOUCHED HORIZONTAL")
        } else {
            print("NO MATCH")
        }
    }
    
    // Our "long press" function
    @objc func rotate(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let holdLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(holdLocation)
        
        if !hitTest.isEmpty {
            let result = hitTest.first!
            // We are currently "pressing" an object
            if sender.state == .began {
                // Apply the a rotation to the selected node
                let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
                let forever = SCNAction.repeatForever(rotation)
                result.node.runAction(forever)
                // We "let go"
            } else if sender.state == .ended {
                result.node.removeAllActions()
            }
        }
    }
    
    // Make sure that our objects rotate ournd their center of origin
    // not their "pivot point"
    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }
    
    // Our add item function
    func addItem(hitTestResult: ARHitTestResult) {
        if let selectedItem = self.selectedItem {
            print(selectedItem)
            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
            // If recursively is true, it checks the entire subtree of the root node
            let node  = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
            // Access the hitTestResults world matrix, in order to get a postion for our 3d model
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3
            // Position our item exactly where the plane was detected
            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            // Fix pivot point issues for certain items
            if selectedItem == "table" {
                self.centerPivot(for: node)
            }
            // Add the new child item
            self.ikeaSceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    // How many cells our collection view displays
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    // Hook up our cell labels to the content in our itemsArray
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! ikeaItemCell
        cell.ikeaItemLabel.text = self.itemsArray[indexPath.row]
        return cell
    }
    
    // Change the color on select
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = itemsArray[indexPath.row]
        cell?.backgroundColor = UIColor.blue
    }
    
    // Remove deselected color
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }
    
    // Display our "plane detected" label
    // This function gets called whenever an anchor is added to the scene view
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // A horizontal surface was detected
        DispatchQueue.main.async {
            guard anchor is ARPlaneAnchor else { return }
            self.planeDetected.isHidden = false
            
            // Hide the label after a few seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.planeDetected.isHidden = true
            }
        }
    }

}

