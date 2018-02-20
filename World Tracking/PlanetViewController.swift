//
//  PlanetViewController.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 10/02/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import UIKit
import ARKit

class PlanetViewController: UIViewController {

    @IBOutlet weak var planetSceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.planetSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                              ARSCNDebugOptions.showWorldOrigin]
        self.planetSceneView.session.run(configuration)
        
        // Add a light source so that our specular map can work
        //self.planetSceneView.autoenablesDefaultLighting = true
    }
    
    // Ovverride the built-in viewDidAppear method
    override func viewDidAppear(_ animated: Bool) {
        
        // Create space
        let space = SCNNode(geometry: SCNSphere(radius: 1.8))
        space.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Stars")
        space.geometry?.firstMaterial?.isDoubleSided = true
        space.position = SCNVector3(0, 0, -3)
        self.planetSceneView.scene.rootNode.addChildNode(space)
        
        // Create the Sun
        let sun = SCNNode(geometry: SCNSphere(radius: 0.25))
        sun.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Sun Diffuse")
        sun.position = SCNVector3(0, 0, -3)
    
        
        // Create parent nodes for the earth and venus, in order to avoid them
        // rotating around the sun in a locked position. These are going to be
        // "invisible" nodes with NO geometry
        let earthParent = SCNNode()
        let venusParent = SCNNode()
        let marsParent  = SCNNode()
        let moonParent  = SCNNode()
        
        // Position earthParent and venusParent where the sun is
        earthParent.position = SCNVector3(0, 0, -3)
        venusParent.position = SCNVector3(0, 0, -3)
        marsParent.position  = SCNVector3(0, 0, -3)
        moonParent.position  = SCNVector3(0.7, 0, 0)
        
        // Add our main objects to the root node
        self.planetSceneView.scene.rootNode.addChildNode(sun)
        self.planetSceneView.scene.rootNode.addChildNode(earthParent)
        self.planetSceneView.scene.rootNode.addChildNode(venusParent)
        self.planetSceneView.scene.rootNode.addChildNode(marsParent)
        
        // Create earth with our new planet function
        let earth = planet(geometry: SCNSphere(radius: 0.1), diffuse: #imageLiteral(resourceName: "EarthDay"), specular: nil, emission: nil, normal: #imageLiteral(resourceName: "EarthTexture"), position: SCNVector3(0.7, 0, 0))
        
        // Create venus
        let venus = planet(geometry: SCNSphere(radius: 0.07), diffuse: #imageLiteral(resourceName: "Venus Surface"), specular: nil, emission: #imageLiteral(resourceName: "Venus Atmosphere"), normal: nil, position: SCNVector3(0.4, 0, 0))
        
        // Create mars
        let mars = planet(geometry: SCNSphere(radius: 0.04), diffuse: #imageLiteral(resourceName: "Mars"), specular: nil, emission: nil, normal: nil, position: SCNVector3(1, 0, 0))
        
        // Moon
        let earthMoon = planet(geometry: SCNSphere(radius: 0.02), diffuse: #imageLiteral(resourceName: "Moon"), specular: nil, emission: nil, normal: nil, position: SCNVector3(0.15, 0, 0))
        
        // Add actions
        let sunAction = Rotation(time: 8)
        let marsParentAction = Rotation(time: 16)
        let earthParentAction = Rotation(time: 13)
        let venusParentAction = Rotation(time: 10)
        let marsAction = Rotation(time: 7)
        let earthAction = Rotation(time: 8)
        let moonAction = Rotation(time: 5)
        let venusAction = Rotation(time: 8)
        
        // Run the action
        sun.runAction(sunAction)
        earthParent.runAction(earthParentAction)
        venusParent.runAction(venusParentAction)
        marsParent.runAction(marsParentAction)
        earth.runAction(earthAction)
        moonParent.runAction(moonAction)
        venus.runAction(venusAction)
        mars.runAction(marsAction)
        
        // Earth and Venus to parent nodes
        earthParent.addChildNode(earth)
        earthParent.addChildNode(moonParent)
        venusParent.addChildNode(venus)
        marsParent.addChildNode(mars)
        
        // Moon relative to planet
        earth.addChildNode(earthMoon)
        moonParent.addChildNode(earthMoon)
        
        
    }
    
    // Planet function because "DNRY"
    func planet(geometry: SCNGeometry, diffuse: UIImage, specular: UIImage?, emission: UIImage?,
                normal: UIImage?, position: SCNVector3) -> SCNNode {
        let planet = SCNNode(geometry: geometry);
        planet.geometry?.firstMaterial?.diffuse.contents = diffuse
        planet.geometry?.firstMaterial?.specular.contents = specular
        planet.geometry?.firstMaterial?.emission.contents = emission
        planet.geometry?.firstMaterial?.normal.contents = normal
        planet.position = position
        
        return planet
    }
    
    // Rotation function
    // Add rotation with the SCNAction animation class (use our custom degreesToRadians extension)
    func Rotation(time: TimeInterval) -> SCNAction {
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        let forever  = SCNAction.repeatForever(rotation)
        
        return forever;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// Custom extension that converts a degree value to a radians
extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
