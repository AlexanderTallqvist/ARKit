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
class IkeaViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var ikeaSceneView: ARSCNView!
    let itemsArray: [String] = ["cup", "vase", "boxing", "table"]
    let configuration = ARWorldTrackingConfiguration()
    var selectedItem: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ikeaSceneView.debugOptions = [ ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        // Detect horizontal surfaces
        self.configuration.planeDetection = .horizontal
        self.ikeaSceneView.session.run(configuration)
        
        // Override our extended calsses
        self.itemsCollectionView.dataSource = self;
        self.itemsCollectionView.delegate = self;
        
        // Register our gesture recognizer
        self.registerGestureRecognizers()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Register user tap gesture (needs to be exposed to objeC
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        // Add our custom tapGeastureRecognizer to the scene view
        self.ikeaSceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
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
    
    // Our add item function
    func addItem(hitTestResult: ARHitTestResult) {
        if let selectedItem = self.selectedItem {
            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
            // If recursively is true, it checks the entire subtree of the root node
            let node  = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
            // Access the hitTestResults world matrix, in order to get a postion for our 3d model
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3
            // Position our item exactly where the plane was detected
            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
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
    

}
