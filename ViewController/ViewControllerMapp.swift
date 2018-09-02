//
//  ViewControllerMapp.swift
//  GoogleMapProjectTest
//
//  Created by Admin on 5/25/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewControllerMapp: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate {
    var mod :model = model()
    @IBOutlet weak var map: GMSMapView!
    var locationManager = CLLocationManager()
    lazy var mapView = GMSMapView()
    private let searchRadius: Double = 1000
    var userLocation:CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate=self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mod.vieww = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse
            else {
            return
        }
        locationManager.startUpdatingLocation()
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 13.0)
        self.map.camera = camera
        self.map.isMyLocationEnabled=true
       self.setUserLocationMark()
        self.map.animate(to:camera)
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func musqubtn(_ sender: UIButton) {
        
        map.clear()
        self.setUserLocationMark()
        mod.fetchNearbyPlaces(coordinate: userLocation.coordinate,type:"mosque")
    }
    @IBAction func banksbtn(_ sender: UIButton) {
        map.clear()
        self.setUserLocationMark()
        mod.fetchNearbyPlaces(coordinate: userLocation.coordinate,type:"bank")
    }
   func setUserLocationMark()
   {
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
    marker.title = "Alex"
    marker.snippet = "Egypt"
    marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0)
    marker.map = map
    
    }
    func setMarker(latitude:Double,longitude:Double,place_id:String)
    {
            let markerr = GMSMarker()
            markerr.position = CLLocationCoordinate2DMake(latitude,longitude)
            markerr.map = self.map
            markerr.userData = place_id
            self.map.reloadInputViews()
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "details") as! ViewControllerdetails
        secondViewController.destinaton = marker.position
        secondViewController.source=userLocation.coordinate
        secondViewController.placeid = marker.userData as! String
        print(marker.userData)
        self.navigationController?.pushViewController(secondViewController, animated: true)
        return true
    }

}
