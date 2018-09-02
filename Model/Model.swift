//
//  Model.swift
//  GoogleMapProjectTest
//
//  Created by Admin on 5/26/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces
import CoreLocation

class model {
    var latitude :Double!
    var longitude :Double!
    var placeid:String!
    var vieww:ViewControllerMapp!
    var viewwdetails:ViewControllerdetails!
    var destinaton:CLLocationCoordinate2D!
    var source:CLLocationCoordinate2D!
    var dist_km:String!
    var name:String!
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D,type:String) {
        let googleURLString = NSString(format:"https://maps.googleapis.com/maps/api/place/radarsearch/json?location=%f,%f&radius=5000&type=%@&key=AIzaSyBk4AwcieAT5O-UVrcULFlJHCKyFkp30Tk",coordinate.latitude,coordinate.longitude,type) as String
        let googleURL = URL(string: googleURLString)
        let request = URLRequest(url: googleURL!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request){ (data , response ,error) in
            do {
                
                var json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,AnyObject>
                if let locations:NSArray = json["results"] as? NSArray{
                    for  index in 0...locations.count-1
                    {
                        if let dic:NSDictionary = locations[index] as? NSDictionary{
                            if let dicc:NSDictionary = dic["geometry"] as? NSDictionary{
                                if let loc:NSDictionary = dicc["location"] as? NSDictionary{
                                    if let lat = loc["lat"] as? Double{
                                        self.latitude = lat
                                    }
                                    if let long = loc["lng"] as? Double{
                                        self.longitude = long
                                    }
                                }
                            }
                            if let str:String = dic["place_id"] as? String{
                                self.placeid=str
                            }
                        }
                        DispatchQueue.main.async{
                        self.vieww.setMarker(latitude: self.latitude,longitude: self.longitude,place_id:self.placeid)
                        }
                    }
                }
            }catch
            {
                print("error")
            }
        }
        task.resume()
    }
    
    func drawPath()
    {
        let origin = "\(source.latitude),\(source.longitude)"
        let destination = "\(destinaton.latitude),\(destinaton.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyBk4AwcieAT5O-UVrcULFlJHCKyFkp30Tk"
        let urlString2 = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking&key=AIzaSyBk4AwcieAT5O-UVrcULFlJHCKyFkp30Tk"
        let url = URL(string: urlString)
        let url2 = URL(string: urlString2)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print(error!.localizedDescription)
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let preroutes:NSArray = json["routes"] as! NSArray
                    for  index in 0...preroutes.count-1
                    {
                        let routes:NSDictionary = preroutes[index] as! NSDictionary
                        let routeOverviewPolyline = routes.value(forKey: "overview_polyline") as! NSDictionary
                        let points = routeOverviewPolyline.object(forKey: "points") as! String
                        DispatchQueue.main.async{
                            let path = GMSPath.init(fromEncodedPath: points)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3
                            polyline.strokeColor = UIColor.red
                            let bounds = GMSCoordinateBounds(path: path!)
                            self.viewwdetails.map!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            polyline.map = self.viewwdetails.map
                        }
                    }
                    
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
        URLSession.shared.dataTask(with: url2!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print(error!.localizedDescription)
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let preroutes:NSArray = json["routes"] as! NSArray
                    for  index in 0...preroutes.count-1
                    {
                        let routes:NSDictionary = preroutes[index] as! NSDictionary
                        let routeOverviewPolyline = routes.value(forKey: "overview_polyline") as! NSDictionary
                        let legs = routes.object(forKey: "legs") as! NSArray
                        let dis = legs[0] as!NSDictionary
                        let distance = dis.value(forKey:"distance") as! NSDictionary
                        self.dist_km = distance.value(forKey: "text") as! String
                        let points = routeOverviewPolyline.object(forKey: "points") as! String
                        print(self.dist_km)
                        DispatchQueue.main.async{
                            let path = GMSPath.init(fromEncodedPath: points)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3
                            polyline.strokeColor = UIColor.green
                            let bounds = GMSCoordinateBounds(path: path!)
                            self.viewwdetails.map!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            polyline.map = self.viewwdetails.map
                        }
                    }
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
        self.getData()
    }
    
    func getData()
    {
        let urlString3 = NSString(format:"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyBk4AwcieAT5O-UVrcULFlJHCKyFkp30Tk",self.placeid) as String
        let url3 = URL(string: urlString3)
        URLSession.shared.dataTask(with: url3!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print(error!.localizedDescription)
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let result:NSDictionary = json["result"] as! NSDictionary
                    self.name = result.value(forKey: "name") as! String
                    DispatchQueue.main.async{
                       self.viewwdetails.setData(name: self.name,distance: self.dist_km)
                    }
                }catch let error as NSError{
                    print("error:\(error)")
            }
            }
        }).resume()
        
}
}
