//
//  LocationTableViewController.swift
//  World Tracking
//
//  Created by Alexander Tallqvist on 06/04/2018.
//  Copyright © 2018 Alexander Tallqvist. All rights reserved.
//

import Foundation
import UIKit

class LocationTableViewController : UITableViewController {
    
    private let locations = ["Coffee", "Bars", "Fast Food", "Banks", "Hospitals", "Gas Stations", "Grocery Store"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Set the number of rows to match our location count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count
    }
    
    // Populate the cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.locations[indexPath.row]
        return cell
    }
    
    // Allows us to move a table cell value to the next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.tableView.indexPathForSelectedRow == nil {
            return
        }
        let indexPath = (self.tableView.indexPathForSelectedRow)!
        let location = self.locations[indexPath.row]
        let ViewController = segue.destination as! LocationViewController2
        ViewController.place = location
        
    }
}
