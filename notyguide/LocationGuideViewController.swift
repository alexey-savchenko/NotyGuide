//
//  LocationGuideViewController.swift
//  notyguide
//
//  Created by Alexey Savchenko on 06.02.17.
//  Copyright © 2017 SuddenlyPancakes. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class LocationGuideViewController: UIViewController, CLLocationManagerDelegate {
  
  
  //MARK: Properities
  
  var selfLocationMarker = GMSMarker()
  var regionToMonitor = CLCircularRegion()
  var marker = GMSMarker()
  let locationManager = CLLocationManager()
  
  
  @IBOutlet weak var metersToTargetLabel: UILabel!
  @IBOutlet weak var mapView: GMSMapView!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    
    initMap(with: marker)
    
    regionToMonitor = CLCircularRegion(center: marker.position, radius: 50, identifier: "targetRegion")
  
    locationManager.requestAlwaysAuthorization()
    
    locationManager.startUpdatingLocation()
    
    locationManager.startMonitoring(for: regionToMonitor)
  
    Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateDistanceLabel), userInfo: nil, repeats: true)
    Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateSelfMarkerPosition), userInfo: nil, repeats:  true)
    
  }
  
  override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    print("\n Unwind")
  }
  
  func updateSelfMarkerPosition(){
    selfLocationMarker.map = nil
    selfLocationMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!,
                                                                    longitude: (locationManager.location?.coordinate.longitude)!))
    
    selfLocationMarker.map = mapView
    
    if regionToMonitor.contains(selfLocationMarker.position) {
      print("\n Contains")
    }
    //USE TO IMPLEMENT target entr region
    //CLCircularRegion
  }
  
  
  
  
  func updateDistanceLabel(){
    
    let R = 6378.137
    
    let lat1 = locationManager.location?.coordinate.latitude
    let long1 = locationManager.location?.coordinate.longitude
    
    let lat2 = marker.position.latitude
    let long2 = marker.position.longitude
    
    let dLat = lat2 * M_PI / 180 - lat1! * M_PI / 180
    let dLong = long2 * M_PI / 180 - long1! * M_PI / 180
    
    let ds = cos(lat1! * M_PI / 180) * cos(lat2 * M_PI / 180) * sin(dLong / 2) * sin(dLong / 2)
    
    let a = sin(dLat / 2) * sin(dLat / 2) + ds
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    let d = R * c
    
    metersToTargetLabel.text = "\(round(d * 1000)) m"
    
    
  }
  
  func initMap(with marker: GMSMarker) {
    let camera = GMSCameraPosition(target: marker.position, zoom: 14.0, bearing: 0, viewingAngle: 0)
    mapView.camera = camera
    
    marker.map = mapView
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region.identifier == "targetRegion"{
      print("\n Region entered")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("\n CLLocationManager failed, \(error.localizedDescription)")
  }
  
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("\n Monitoring failed, \(error.localizedDescription)")
  }
  
  func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    self.locationManager.requestState(for: regionToMonitor)
  }
  
  func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    if (state == .inside)
    {
      //Start Ranging
      print("\n Inside")
      
    }
    else
    {
      //Stop Ranging here
      print("\n Outside")
    }
  }
  
  
}
