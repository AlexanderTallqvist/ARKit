//
//  LocationViewController.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 02/04/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import ARCL
import CoreLocation
import UIKit
import ARKit

class LocationViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var LocationSceneView: ARSCNView!
    var sceneLocationView = SceneLocationView()
    lazy var geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.run()
        //view.addSubview(sceneLocationView)
        LocationSceneView.addSubview(sceneLocationView)
        
        
        let coordinate = CLLocationCoordinate2D(latitude: 59.975937, longitude: 23.450618)
        let location = CLLocation(coordinate: coordinate, altitude: 10)
        print("INFO:", location)
//        location.streetNameWithCompletionBlock { street in
//            print("street \(String(describing: street))")
//        }
        let image = UIImage(named: "Back")!
        
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        annotationNode.scaleRelativeToDistance = true
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            print("Unable to Find Address for Location")
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                print(placemark.compactAddress)
            } else {
                print("No Matching Addresses Found")
            }
        }
    }

}


extension CLPlacemark {
    
    var compactAddress: String? {
        if let name = name {
            var result = name
            
            if let street = thoroughfare {
                result += ", \(street)"
            }
            
            if let city = locality {
                result += ", \(city)"
            }
            
            if let country = country {
                result += ", \(country)"
            }
            
            return result
        }
        
        return nil
    }
    
}



