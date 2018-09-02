//
//  ViewControllerdetails.swift
//  GoogleMapProjectTest
//
//  Created by Admin on 5/26/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewControllerdetails: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate{
    var mod :model = model()
    var destinaton:CLLocationCoordinate2D!
    var source:CLLocationCoordinate2D!
    var placeid:String!
    var locationManager = CLLocationManager()
    var userLocation:CLLocation!
    @IBOutlet weak var map: GMSMapView!
    @IBOutlet weak var Titlelabel: UILabel!
    @IBOutlet weak var Distancelabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mod.viewwdetails=self
        map.delegate=self
        mod.source = source
        mod.destinaton = destinaton
        mod.placeid = placeid
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        self.mod.drawPath()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    func setUserLocationMark()
    {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        marker.title = "Alex"
        marker.snippet = "Egypt"
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0)
        marker.map = map
    }
    func setData(name:String,distance:String)
    {
        Distancelabel.text = distance
        Titlelabel.text = name
        
    }
}
