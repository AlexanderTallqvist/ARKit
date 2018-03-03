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
    
    var earthFacts = "   EARTH" + "\n" +
                     "    Equatorial Diameter: 12,756 km" + "\n" +
                     "    Polar Diameter: 12,714 km" + "\n" +
                     "    Mass: 5.97 x 10^24 kg" + "\n" +
                     "    Moons: 1 " + "\n" +
                     "    Orbit Distance: 149,598,262 km (1 AU)" + "\n" +
                     "    Orbit Period: 365.24 days" + "\n" +
                     "    Surface Temperature: -88 to 58°C"
    
    var venusFacts = "    VENUS" + "\n" +
                     "    Diameter: 12,104 km" + "\n" +
                     "    Mass: 4.87 x 10^24 kg (81.5% Earth)" + "\n" +
                     "    Moons: None" + "\n" +
                     "    Orbit Distance: 108,209,475 km (0.73 AU)" + "\n" +
                     "    Orbit Period: 225 days" + "\n" +
                     "    Surface Temperature: 462 °C" + "\n" +
                     "    First Record: 17th century BC" + "\n" +
                     "    Recorded By: Babylonian astronomers"
    
    var marsFacts = "    MARS" + "\n" +
                    "    Equatorial Diameter: 6,792 km" + "\n" +
                    "    Polar Diameter: 6,752 km" + "\n" +
                    "    Mass: 6.42 x 10^23 kg (10.7% Earth)" + "\n" +
                    "    Moons: 2 (Phobos & Deimos)" + "\n" +
                    "    Orbit Distance: 227,943,824 km (1.52 AU)" + "\n" +
                    "    Orbit Period: 687 days (1.9 years)" + "\n" +
                    "    Surface Temperature: -153 to 20 °C" + "\n" +
                    "    First Record: 2nd millennium BC" + "\n" +
                    "    Recorded By: Egyptian astronomers"
    
    var sunFacts =  "    THE SUN" + "\n" +
                    "    Age: 4.6 Billion Years" + "\n" +
                    "    Type: Yellow Dwarf (G2V)" + "\n" +
                    "    Diameter: 1,392,684 km" + "\n" +
                    "    Equatorial Circumference 4,370,005.6 km" + "\n" +
                    "    Mass: 1.99 × 10^30 kg (333,060 Earths)" + "\n" +
                    "    Surface Temperature: 5,500 °C"
    
    var moonFacts = "    THE MOON" + "\n" +
                    "    Diameter: 3,475 km" + "\n" +
                    "    Mass: 7.35 × 10^22 kg (0.01 Earths)" + "\n" +
                    "    Orbits: The Earth" + "\n" +
                    "    Orbit Distance: 384,400 km" + "\n" +
                    "    Orbit Period: 27.3 days" + "\n" +
                    "    Surface Temperature: -233 to 123 °C"

    @IBOutlet weak var planetSceneView: ARSCNView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.planetSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                              ARSCNDebugOptions.showWorldOrigin]
        self.planetSceneView.session.run(configuration)
        
        // Register our gesture recognizer
        self.registerGestureRecognizers()
        
        // Add a light source so that our specular map can work
        //self.planetSceneView.autoenablesDefaultLighting = true
    }
    
    // Register user tap gesture (needs to be exposed to objeC
    func registerGestureRecognizers() {
        // Create the "tap" geasture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        // Add our custom tap, picnch and long press recognizers to the scene view
        self.planetSceneView.addGestureRecognizer(tapGestureRecognizer)
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
                if(node.name == "Earth") {
                    self.infoLabel.text = self.earthFacts
                }
                if(node.name == "Venus") {
                    self.infoLabel.text = self.venusFacts
                }
                if(node.name == "Sun") {
                    self.infoLabel.text = self.sunFacts
                }
                if(node.name == "Mars") {
                    self.infoLabel.text = self.marsFacts
                }
                if(node.name == "Moon") {
                    self.infoLabel.text = self.moonFacts
                }
            }
        }
    }
    
    // Ovverride the built-in viewDidAppear method
    override func viewDidAppear(_ animated: Bool) {
        
//        Create space
//        let space = SCNNode(geometry: SCNSphere(radius: 1.8))
//        space.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Stars")
//        space.geometry?.firstMaterial?.isDoubleSided = true
//        space.position = SCNVector3(0, 0, -3)
//        self.planetSceneView.scene.rootNode.addChildNode(space)
        
        // Create the Sun
        let sun = SCNNode(geometry: SCNSphere(radius: 0.25))
        sun.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Sun Diffuse")
        sun.position = SCNVector3(0, 0, -2)
        sun.name = "Sun"
    
        
        // Create parent nodes for the earth and venus, in order to avoid them
        // rotating around the sun in a locked position. These are going to be
        // "invisible" nodes with NO geometry
        let earthParent = SCNNode()
        let venusParent = SCNNode()
        let marsParent  = SCNNode()
        let moonParent  = SCNNode()
        
        // Position earthParent and venusParent where the sun is
        earthParent.position = SCNVector3(0, 0, -2)
        venusParent.position = SCNVector3(0, 0, -2)
        marsParent.position  = SCNVector3(0, 0, -2)
        moonParent.position  = SCNVector3(0.7, 0, 0)
        
        // Add our main objects to the root node
        self.planetSceneView.scene.rootNode.addChildNode(sun)
        self.planetSceneView.scene.rootNode.addChildNode(earthParent)
        self.planetSceneView.scene.rootNode.addChildNode(venusParent)
        self.planetSceneView.scene.rootNode.addChildNode(marsParent)
        
        // Create earth with our new planet function
        let earth = planet(geometry: SCNSphere(radius: 0.1), diffuse: #imageLiteral(resourceName: "EarthDay"), specular: nil, emission: nil, normal: #imageLiteral(resourceName: "EarthTexture"), position: SCNVector3(0.7, 0, 0), name: "Earth")
        
        // Create venus
        let venus = planet(geometry: SCNSphere(radius: 0.07), diffuse: #imageLiteral(resourceName: "Venus Surface"), specular: nil, emission: #imageLiteral(resourceName: "Venus Atmosphere"), normal: nil, position: SCNVector3(0.4, 0, 0), name: "Venus")
        
        // Create mars
        let mars = planet(geometry: SCNSphere(radius: 0.04), diffuse: #imageLiteral(resourceName: "Mars"), specular: nil, emission: nil, normal: nil, position: SCNVector3(1, 0, 0), name: "Mars")
        
        // Moon
        let earthMoon = planet(geometry: SCNSphere(radius: 0.02), diffuse: #imageLiteral(resourceName: "Moon"), specular: nil, emission: nil, normal: nil, position: SCNVector3(0.15, 0, 0), name: "Moon")
        
        // Add actions
        let sunAction = Rotation(time: 10)
        let marsParentAction = Rotation(time: 25)
        let earthParentAction = Rotation(time: 20)
        let venusParentAction = Rotation(time: 15)
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
                normal: UIImage?, position: SCNVector3, name: String) -> SCNNode {
        let planet = SCNNode(geometry: geometry);
        planet.geometry?.firstMaterial?.diffuse.contents = diffuse
        planet.geometry?.firstMaterial?.specular.contents = specular
        planet.geometry?.firstMaterial?.emission.contents = emission
        planet.geometry?.firstMaterial?.normal.contents = normal
        planet.position = position
        planet.name = name
        
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
