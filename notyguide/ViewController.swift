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

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
  
  
  // MARK: Properities
  let locationManager = CLLocationManager()
  var plusButtonTimesTapped = 0
  
  @IBOutlet weak var googleMapsView: GMSMapView!
  
  // MARK: Outlets for buttons
  
  @IBOutlet weak var btnConstr: NSLayoutConstraint!
  @IBOutlet weak var btn: RoundButton!
  @IBOutlet weak var notepadButton: RoundButton!
  @IBOutlet weak var searchButton: RoundButton!
  @IBOutlet weak var locationButton: RoundButton!
  
  
  
  // MARK: Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    btn.alpha = 0
    notepadButton.alpha = 0
    searchButton.alpha = 0
    locationButton.alpha = 0
    
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    locationManager.startMonitoringSignificantLocationChanges()
  
    btnConstr.constant -= view.bounds.width / 5
    
    googleMapsView.settings.zoomGestures = true
    googleMapsView.settings.scrollGestures = true
    googleMapsView.isMyLocationEnabled = true
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
  }
  
  //MARK: Outlets
  @IBAction func locationButtonTap(_ sender: RoundButton) {
    if let loc  = googleMapsView.myLocation {
      let camera = GMSCameraPosition.camera(withLatitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, zoom: 16.0)
      let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
      mapView.isMyLocationEnabled = true
      
      self.googleMapsView.camera = camera
      
    }
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
      }) {success in
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
  

  
  //MARK: CLLocation manager delegate methods
  

  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("\n Location manager filed with error: \(error) \n")
  }
  
  //MARK: Autocomplete delegate methods
  
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
    let camera = GMSCameraPosition(target: place.coordinate, zoom: 13.0, bearing: 0, viewingAngle: 0)
    googleMapsView.camera = camera
    let marker = GMSMarker(position: place.coordinate)
    marker.isDraggable = true
    marker.map = googleMapsView
    self.dismiss(animated: true, completion: nil)
    
  }
  
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    print("Autocomplete fail with error: \(error)")
  }
  
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

