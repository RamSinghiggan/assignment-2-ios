//
//  ViewController.swift
//  toVisitPlaces_ram_c0779370
//
//  Created by rschakar on 6/16/20.
//  Copyright © 2020 rs_chakar. All rights reserved.
//

import UIKit
import MapKit
class ViewController:  UIViewController ,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet var doubelTap: UITapGestureRecognizer!
    @IBOutlet weak var infobtn: UIButton!
    var locationManager:CLLocationManager!
    var currentLocationStr = "Current location"
    var annotation = MKPointAnnotation()
    let destinationRequest = MKDirections.Request()
    let geoCoder = CLGeocoder()
    var destinationCoordinates : CLLocationCoordinate2D!
    var places:[favplaces]?
    let defaults = UserDefaults.standard
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var zoomin: UIButton!
    @IBOutlet weak var zoomout: UIButton!
    @IBOutlet weak var walk: UIButton!
    @IBOutlet weak var userlocationbtn: UIButton!
    @IBOutlet weak var findwaybtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
     
                          
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
              determineCurrentLocation()
              alertWelcome()
              loadData()
         }
   
        //Alert Welcome fn
        func alertWelcome(){
            let alert = UIAlertController(title: "Welcome", message: "1.Press Home Button to get your Location  & There is info button on top left of the screen for futher guides", preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler:nil ))
                   // show the alert
                          self.present(alert, animated: true, completion: nil)
        }

        
        
      //info btn action
    @IBAction func infoAction(_ sender: UIButton) {
        alertUserlocation()
    }
    //zoom Out Button
    @IBAction func zoomOut(_ sender: UIButton) {
        zoomOutfunc()
    }

         //Zoom In Button
    @IBAction func zoomIn(_ sender: UIButton) {
        zoomInfunc()
    }
  

          //Double Tap Action
    @IBAction func actionDoubletap(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: mapView)
                   let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
      
                annotation.coordinate = newCoordinates
                annotation.title = "Destination"
                annotation.subtitle = "1.Press Add sign to make Fav place"
                mapView.addAnnotation(annotation)
                mapView.removeAnnotations(mapView.annotations.filter { $0 !== mapView.userLocation })
             
                self.mapView.addAnnotation(annotation)
                print(newCoordinates,"Double Tap")
    }
  
 
             //Button for  User's Current Locaton.
    @IBAction func userlocAction(_ sender: UIButton) {
        yourLocation(_Location: locationManager.location!)
    }
    
     
   
        //Walking Button action
    @IBAction func walkbtnAction(_ sender: UIButton) {
      
                      mapThis(destinationCord: annotation.coordinate)
                     mapView.removeOverlays(mapView.overlays)
                    medium(source: sender)
                            print("walking on")
    }
    
        
    // Find way Button action
    @IBAction func findwayAction(_ sender: UIButton) {
        medium(source: sender)
                         print(annotation.coordinate,"Button")
                         mapThis(destinationCord: annotation.coordinate)
                         mapView.removeOverlays(mapView.overlays)
               
    }
  
    
            
    // function to get directions
        func mapThis(destinationCord : CLLocationCoordinate2D) {
          
            let souceCordinate = (locationManager.location?.coordinate)!
            
            let soucePlaceMark = MKPlacemark(coordinate: souceCordinate)
            let destPlaceMark = MKPlacemark(coordinate: destinationCord)
            
            let sourceItem = MKMapItem(placemark: soucePlaceMark)
            let destItem = MKMapItem(placemark: destPlaceMark)
            print(destItem,"destiantion placemark")
            destinationRequest.source = sourceItem
            destinationRequest.destination = destItem
            destinationRequest.requestsAlternateRoutes = false
          
            
            
    //Direction Part
            let directions = MKDirections(request: destinationRequest)
            directions.calculate { (response, error) in
                guard let response = response else {
                    if error != nil {
                        print("Something is wrong :(")
                    }
                    return
                }
                
                
    //Route Part
              let route = response.routes[0]
                self.mapView.addOverlay(route.polyline,level: .aboveRoads)
              self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            self.mapView.delegate = self
            
           
        }
        
    //To show Direction Route
        func mapView(_ mapView: MKMapView,
                     rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

          let polylineRenderer = MKPolylineRenderer(overlay: overlay)
          if (overlay is MKPolyline) {
            if mapView.overlays.count == 1 {
              polylineRenderer.strokeColor =
                UIColor.blue.withAlphaComponent(0.75)
            } else if mapView.overlays.count == 2 {
              polylineRenderer.strokeColor =
                UIColor.orange.withAlphaComponent(0.75)
            } else if mapView.overlays.count == 3 {
              polylineRenderer.strokeColor =
                UIColor.red.withAlphaComponent(0.75)
            }
            polylineRenderer.lineWidth = 5
          }
          return polylineRenderer

        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                print("Error - locationManager: \(error.localizedDescription)")
            }
        

       
    //function to get current Loacation
        func determineCurrentLocation() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            mapView.delegate = self
            }
        
        
        
        
        
    //User location fn
        func yourLocation(_Location: CLLocation){
            let location = locationManager.location!
                         let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            var region = MKCoordinateRegion(center: center, span: MKCoordinateSpan( latitudeDelta: 0.01, longitudeDelta: 0.01))
                         region.center = mapView.userLocation.coordinate
                         mapView.setRegion(region, animated: true)
          
        }
        
        
        //Alert userlocation fn
          func alertUserlocation(){
              let alert = UIAlertController(title: "Select Destiantion", message: "1.Please use magnifier Buttons for Zoom in and Zoom out  2.Double tap to set a destination location  3. Select a medium of transport from the right bottom buttons  4.Double tap walking Button for walking Route", preferredStyle: UIAlertController.Style.alert)
                     alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler:nil ))
                     // show the alert
                            self.present(alert, animated: true, completion: nil)
          }
        
    //Zoom Out Function
         func zoomOutfunc(){
          
    //
    //        let maxRegion=MKCoordinateRegion(center:mapView.region.center ,span:  MKCoordinateSpan(latitudeDelta: +214.98590353, longitudeDelta: +162.98586887));
          
             let newRegion=MKCoordinateRegion(center: mapView.region.center,span: MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta/0.5, longitudeDelta: mapView.region.span.longitudeDelta/0.5));
                mapView.setRegion(newRegion,animated: true)
             
         }
         
         
         
         //Zoom in Function
         func zoomInfunc(){
             let newRegion=MKCoordinateRegion(center: mapView.region.center,span: MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta*0.5, longitudeDelta: mapView.region.span.longitudeDelta*0.5));
                   mapView.setRegion(newRegion, animated: true)
             
         }
        
        
        
    //Medium function
        func medium(source:UIButton){
            if(source.tag==1){
                print ("Walking")
                destinationRequest.transportType = .walking
                
            }
            else if(source.tag==2){
                print("Automobile")
                destinationRequest.transportType = .automobile
            }
        }
        
      
    //geocode fn
        func geocoder(){
             print("geocoder  enter")
            
                   let location = CLLocation(latitude: annotation.coordinate.latitude,
                                             longitude: annotation.coordinate.longitude)
                     geoCoder.reverseGeocodeLocation(location, completionHandler:
                       {(placemarks, error) in
                                 if let error = error as? CLError {
                                        print("CLError:", error)
                                        return
                                     }
                                    else if let placemark = placemarks?[0] {
                                     
                                     var placeName = ""
                                     var neighbourhood = ""
                                     var city = ""
                                     var state = ""
                                     var postalCode = ""
                                     var country = ""
                                     
                                     
   
if let plocality = placemark.subLocality { city += plocality}
if let parea = placemark.administrativeArea { state += parea}
 if let pname = placemark.name {placeName += pname}
  if let psublocality = placemark.subLocality {neighbourhood += psublocality
                                                                                    }
if let pcode = placemark.postalCode {postalCode += pcode}
if let pcountry = placemark.country {country += pcountry
                                                          }

                                     
                                     
                                    let place = favplaces(placeLat: self.annotation.coordinate.latitude, placeLong:self.annotation.coordinate.longitude, placeName: placeName, city: city, postalCode: postalCode, country: country)
                                   print("geocode" ,place)
                                     self.places?.append(place)
                                     self.saveData()
                                     
                                     }
                         })
                   
        }
        
        
        func saveData() {
                      let filePath = getDataFilePath()
                      var saveString = ""
                      for place in places!{
                         saveString = "\(saveString)\(place.placeLat),\(place.placeLong),\(place.placeName),\(place.city),\(place.country),\(place.postalCode)\n"
                          do{
                         try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
                          }
                          catch{
                              print(error)
                          }
                      }
                  }
        
        func getDataFilePath() -> String
                       {
                              let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                              let filePath = documentPath.appending("/favplaces.txt")
                              return filePath
                       }
        
        func dragablePin(){
                        let latitudeLocation = defaults.double(forKey: "latitude")
                        let longitudeLocation = defaults.double(forKey: "longitude")
                        
                        annotation.coordinate = CLLocationCoordinate2D(latitude: latitudeLocation, longitude: longitudeLocation )
                        print(latitudeLocation, longitudeLocation)
                        mapView.addAnnotation(annotation)
                    }
        
            func loadData() {
                places = [favplaces]()
                
                let filePath = getDataFilePath()
                
                if FileManager.default.fileExists(atPath: filePath){
                    do{
                        //creating string of file path
                     let fileContent = try String(contentsOfFile: filePath)
                        
                        let contentArray = fileContent.components(separatedBy: "\n")
                        for content in contentArray{
                           
                            let placeContent = content.components(separatedBy: ",")
                            if placeContent.count == 6
                            {
                                let place = favplaces(placeLat: Double(placeContent[0]) ?? 0.0, placeLong: Double(placeContent[1]) ?? 0.0, placeName: placeContent[2], city: placeContent[3], postalCode: placeContent[4], country: placeContent[5])
                                    places?.append(place)
                               
                            }
                        }
        //                print(places?.count)
                    }
                    catch{
                        print(error)
                    }
                }
            }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
                
                
                        if annotation is MKUserLocation {
                            return nil
                        }
                    
                            let pinAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
                            pinAnnotation.markerTintColor = .orange
                            pinAnnotation.glyphTintColor = .white
                            pinAnnotation.canShowCallout = true
    //
                          pinAnnotation.rightCalloutAccessoryView = UIButton(type: .contactAdd)
                            return pinAnnotation
                
                    }
                func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
                       let alertController = UIAlertController(title: "Add to Favourites", message:
                          "Do you want to add to favourites?", preferredStyle: .actionSheet)
                      alertController.addAction(UIAlertAction(title: "Yes", style:  .default, handler: { (UIAlertAction) in
                        print("callout yes enter")
                        self.geocoder()
                          
                      }))
                  
                      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                          self.present(alertController, animated: true, completion: nil)
                                  
                  }
       
    }






