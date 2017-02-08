//
//  ViewController.swift
//  notyguide
//
//  Created by Alexey Savchenko on 03.02.17.
//  Copyright © 2017 SuddenlyPancakes. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreData

class MainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
  
  
  // MARK: Properities
  let locationManager = CLLocationManager()
  var selfLocationMarker = GMSMarker()
  var plusButtonTimesTapped = 0
  var markerOnMapView = GMSMarker()
  var tempNameOfLocationToSave: String?
  
  // MARK: Outlets
  @IBOutlet weak var googleMapsView: GMSMapView!
  
  @IBOutlet weak var btnConstr: NSLayoutConstraint!
  @IBOutlet weak var btn: RoundButton!
  @IBOutlet weak var notepadButton: RoundButton!
  @IBOutlet weak var searchButton: RoundButton!
  @IBOutlet weak var locationButton: RoundButton!
  
  @IBOutlet weak var saveLocationButton: UIBarButtonItem!
  @IBOutlet weak var headToLocationButton: UIBarButtonItem!
  
  // MARK: Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    btn.alpha = 0
    notepadButton.alpha = 0
    searchButton.alpha = 0
    locationButton.alpha = 0
    
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.startUpdatingLocation()
    
    
    btnConstr.constant -= view.bounds.width / 5
    
    googleMapsView.settings.zoomGestures = true
    googleMapsView.settings.scrollGestures = true
    
    Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateSelfMarkerPosition), userInfo: nil, repeats:  true)
    
    self.googleMapsView.delegate = self
    
    
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.animate(withDuration: 1.0,
                   delay: 0,
                   options: .curveEaseInOut,
                   animations: {
                    
                    self.btnConstr.constant = 10
                    self.btn.alpha = 1.0
                    self.view.layoutIfNeeded()
                    
    }, completion: nil)
    
    updateSelfLocation()
  }
  
  //MARK: Outlets
  
  
  
  @IBAction func notepadButtonTap(_ sender: RoundButton) {
    performSegue(withIdentifier: "toSavedLocationsView", sender: self)
  }
  
  @IBAction func locationButtonTap(_ sender: RoundButton) {
    
    updateSelfLocation()
    
  }
  
  func updateSelfLocation(){
    let selfLocation = locationManager.location?.coordinate
    
    let camera = GMSCameraPosition.camera(withLatitude: (selfLocation?.latitude)!, longitude: (selfLocation?.longitude)!, zoom: 16.0)
    self.googleMapsView.camera = camera
  }
  
  func updateSelfMarkerPosition(){
    
    selfLocationMarker.map = nil
    selfLocationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!,
                                                                    longitude: (locationManager.location?.coordinate.longitude)!))
    selfLocationMarker.icon = UIImage(named: "locationPoint")
    selfLocationMarker.map = googleMapsView
    
    
  }
  
  @IBAction func btnTap(_ sender: RoundButton) {
    
    let btn = sender
    let initSize = btn.bounds
    
    plusButtonTimesTapped += 1
    
    if !(plusButtonTimesTapped % 2 == 0){
      UIView.animate(withDuration: 0.5,
                     delay: 0,
                     usingSpringWithDamping: 0.2,
                     initialSpringVelocity: 5,
                     options: .curveEaseInOut,
                     animations: {
                      btn.bounds.size = CGSize(width: initSize.width - initSize.width * 0.3, height: initSize.height - initSize.height * 0.3)
                      btn.layer.cornerRadius -= btn.layer.cornerRadius * 0.3
      }) { success in
        if success {
          UIView.animate(withDuration: 0.1, animations: {
            self.searchButton.alpha = 1
            self.notepadButton.alpha = 1
            self.locationButton.alpha = 1
          })
        }
      }
    } else{
      UIView.animate(withDuration: 0.1,
                     animations: {
                      btn.bounds.size = CGSize(width: 60, height: 60)
                      btn.layer.cornerRadius = 30
      }) { success in
        if success {
          UIView.animate(withDuration: 0.1, animations: {
            self.notepadButton.alpha = 0
            self.searchButton.alpha = 0
            self.locationButton.alpha = 0
          })
        }
      }
    }
  }
  
  @IBAction func searchButtonTap(_ sender: RoundButton) {
    
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self
    
    self.locationManager.stopUpdatingLocation()
    self.present(autocompleteController, animated: true, completion: nil)
  }
  
  @IBAction func headToLocationButtonTap(_ sender: UIBarButtonItem) {
    performSegue(withIdentifier: "toLocationGuideView", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toLocationGuideView" {
      let target = segue.destination as! LocationGuideViewController
      self.locationManager.stopUpdatingLocation()
      target.marker = markerOnMapView
    }
  }
  
  @IBAction func saveLocationButtonTap(_ sender: UIBarButtonItem) {
    
    let alert = UIAlertController(title: "Save location", message: "Enter name of location", preferredStyle: .alert)
    
    alert.addTextField(configurationHandler: nil)
    
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
      //Impelement saving of location
      
      
      let appDel = UIApplication.shared.delegate as! AppDelegate
      
      let context = appDel.persistentContainer.viewContext
      
      let loc = Location(context: context)
    
      let textField = alert.textFields?[0]
      
      loc.name = textField?.text
      loc.latitude = self.markerOnMapView.position.latitude
      loc.longtitude = self.markerOnMapView.position.longitude
      loc.dateAdded = Date() as NSDate?
      
      appDel.saveContext()
      
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(alert, animated: true, completion: nil)
    
  }
  
  //MARK: GMSMapViewDelegate methods
  
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    
    markerOnMapView.map = nil
    
    markerOnMapView = GMSMarker(position: coordinate)
    markerOnMapView.map = googleMapsView
    
    saveLocationButton.isEnabled = true
    headToLocationButton.isEnabled = true
  }
  
  //MARK: CLLocation manager delegate methods
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("\n Location manager filed with error: \(error) \n")
  }
  
  //MARK: Autocomplete delegate methods
  
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    markerOnMapView.map = nil
    
    let camera = GMSCameraPosition(target: place.coordinate, zoom: 13.0, bearing: 0, viewingAngle: 0)
    googleMapsView.camera = camera
    markerOnMapView = GMSMarker(position: place.coordinate)
    markerOnMapView.isDraggable = true
    markerOnMapView.map = googleMapsView
    self.dismiss(animated: true, completion: nil)
    
  }
  
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    print("Autocomplete fail with error: \(error)")
  }
  
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

