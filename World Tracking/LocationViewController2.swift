//
//  LocationViewController2.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 06/04/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MapKit
import ARCL

class LocationViewController2: UIViewController, CLLocationManagerDelegate {
    
    var place :String!
    
    // ARCL Stuff
    var sceneLocationView = SceneLocationView()
    
    // Use lazy to only initialize when the property is actually accessed
    lazy private var locationManager  = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load ARCL's AR view into our "normal" view
        sceneLocationView.run()
        self.view.addSubview(sceneLocationView)
        
        self.title = self.place
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.findLocalLocations()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // For re-sizing ARCL's view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = self.view.bounds
    }
    
    private func findLocalLocations() {
        // Attempt to get the users location
        guard let userLocation = self.locationManager.location else {
            return
        }
        
        // Make a search request using the selected word
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = place
        
        // Setup our search region accorind to the users location
        var region = MKCoordinateRegion()
        region.center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        request.region = region
        
        // Make the actual request
        let search = MKLocalSearch(request: request)
        search.start{ response, error in
            if error != nil {
                return
            }
            
            guard let response = response else {
                return
            }
            
            for item in response.mapItems {
                let url = item.url?.absoluteString
                let placeLocation = (item.placemark.location)!
                let distance = placeLocation.distance(from: userLocation) / 1000
                let distanceString = String(format: "%.3f", distance)
                let name = (item.placemark.name)!
                
                // Use our custom annotation node
                let locationAnnotationNode = LocationAnnotation(location: placeLocation, title: name, distance: distanceString)
                
                // LocationAnnotationNode from ARCL
                let annotationNode = LocationAnnotationNode(location: placeLocation, image: #imageLiteral(resourceName: "Back"))
                //annotationNode.scaleRelativeToDistance = true
                
                // Add our anotation
                DispatchQueue.main.async {
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationAnnotationNode)
                }
            }
        }
    }
    
    

}
