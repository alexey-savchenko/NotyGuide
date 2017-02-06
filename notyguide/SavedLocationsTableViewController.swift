//
//  SavedLocationsTableViewController.swift
//  notyguide
//
//  Created by Alexey Savchenko on 05.02.17.
//  Copyright © 2017 SuddenlyPancakes. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps

class SavedLocationsTableViewController: UITableViewController {
  
  
  //MARK: Properiites
  var locations: [Location] = []
  var selectedLocation = GMSMarker()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadSavedLocations()
  }
  
  func loadSavedLocations(){
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    do{
      try self.locations = context.fetch(Location.fetchRequest())
      print(self.locations.count)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return locations.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SavedLocationCell", for: indexPath) as! SavedLocationCell
    
    cell.configureCell(with: locations[indexPath.row])
    
    return cell
  }
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let locationToRemove = locations[indexPath.row]
    
    if editingStyle == .delete
    {
      do {
        managedContext.delete(locationToRemove)
        locations.remove(at: indexPath.row)
        tableView.reloadData()
        try managedContext.save()
      } catch  {
        print(error)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    selectedLocation = GMSMarker(position: CLLocationCoordinate2D(latitude: locations[indexPath.row].latitude, longitude: locations[indexPath.row].longtitude))
    
    performSegue(withIdentifier: "toLocationGuideView", sender: self)
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toLocationGuideView" {
      let target = segue.destination as! LocationGuideViewController
      target.marker = selectedLocation
    }
  }
  
  @IBAction func deleteAllRecordsFromCoreData(_ sender: UIBarButtonItem) {
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
    fetchRequest.returnsObjectsAsFaults = false
    locations = []
    do
    {
      let results = try managedContext.fetch(fetchRequest)
      for managedObject in results
      {
        let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
        managedContext.delete(managedObjectData)
      }
      print("\n All records are deleted! \n")
      DispatchQueue.main.async{
        self.tableView.reloadData()
      }
    } catch let error as NSError {
      print(error)
    }
  }
  
  
  
  
}
