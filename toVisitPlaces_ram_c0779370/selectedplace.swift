//
//  selectedplace.swift
//  toVisitPlaces_ram_c0779370
//
//  Created by rschakar on 6/16/20.
//  Copyright © 2020 rs_chakar. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class selectedplaces:UIViewController,MKMapViewDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var findBtn: UIButton!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var mapViewselect: MKMapView!
    var locationManager:CLLocationManager!
    
    
    var annotation = MKPointAnnotation()
       let destinationRequest = MKDirections.Request()
    let defaults = UserDefaults.standard
        var lat : Double = 0.0
        var long : Double = 0.0
        var drag : Bool? = false
     var editedPlace : Int = 0
     var editPlaces : [favplaces]?

    override func viewDidLoad() {
             super.viewDidLoad()
        
        determineCurrentLocation()
        
        
            mapViewselect.delegate = self
             
             self.editedPlace = defaults.integer(forKey: "edit")
                     
             self.mapViewselect.addAnnotation(dragablePin())
             let latDelta: CLLocationDegrees = 0.05
             let longDelta: CLLocationDegrees = 0.05
              
              // 3 - Creating the span, location coordinate and region
             let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
             let customLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
             let region = MKCoordinateRegion(center: customLocation, span: span)
                    
              // 4 - assign region to map
             mapViewselect.setRegion(region, animated: true)
             
             loadData()
         
         }
    
    @IBAction func homeBtnAction(_ sender: UIButton) {
         yourLocation(_Location: locationManager.location!)
    }
    
    @IBAction func findBtnAction(_ sender: UIButton) {
         let finalLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
         mapThis(destinationCord:finalLocation)
    }
    
    func determineCurrentLocation() {
             locationManager = CLLocationManager()
             locationManager.delegate = self
             locationManager.desiredAccuracy = kCLLocationAccuracyBest
             locationManager.requestAlwaysAuthorization()
             locationManager.requestWhenInUseAuthorization()
             mapViewselect.delegate = self
             }
    
    
    func yourLocation(_Location: CLLocation){
               let location = locationManager.location!
                            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
               var region = MKCoordinateRegion(center: center, span: MKCoordinateSpan( latitudeDelta: 0.01, longitudeDelta: 0.01))
                            region.center = mapViewselect.userLocation.coordinate
                            mapViewselect.setRegion(region, animated: true)
             
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
                self.mapViewselect.addOverlay(route.polyline,level: .aboveRoads)
              self.mapViewselect.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            self.mapViewselect.delegate = self
            
           
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
    
    
    
    
    
    
    
    
    
         
        func dragablePin() -> MKPointAnnotation{
         self.lat = defaults.double(forKey: "latitude")
         self.long = defaults.double(forKey: "longitude")
         
         self.drag = defaults.bool(forKey: "bool")
         
         print("Lat: \(lat): Long: \(long)")
         let annotation = MKPointAnnotation()
         annotation.coordinate = CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
         annotation.title = "Your Favourite Location"
         //        self.mapView.addAnnotation(annotation)
         return annotation
         
         
         }
          
             func getDataFilePath() -> String {
                    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let filePath = documentPath.appending("/favplaces.txt")
                    return filePath
                }
             
             func loadData() {
                 self.editPlaces = [favplaces]()
                 
                 let filePath = getDataFilePath()
                 
                 if FileManager.default.fileExists(atPath: filePath){
                     do{
                         //creating string of file path
                      let fileContent = try String(contentsOfFile: filePath)
                         
                         let contentArray = fileContent.components(separatedBy: "\n")
                         for content in contentArray{
                            
                             let placeContent = content.components(separatedBy: ",")
                             if placeContent.count == 6 {
                                 let place = favplaces(placeLat: Double(placeContent[0]) ?? 0.0, placeLong: Double(placeContent[1]) ?? 0.0, placeName: placeContent[2], city: placeContent[3], postalCode: placeContent[4], country: placeContent[5])
                                 self.editPlaces?.append(place)
                             }
                     }
                        
                     }
                     catch{
                         print(error)
                     }
                 }
             }
             
             func editLocation() {
                 let filePath = getDataFilePath()

                 var saveString = ""
                 for place in self.editPlaces!{
                    saveString = "\(saveString)\(place.placeLat),\(place.placeLong),\(place.placeName),\(place.city),\(place.country),\(place.postalCode)\n"
                     do{
                    try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
                     }
                     catch{
                         print(error)
                     }
                 }
             }
         
         /*
         // MARK: - Navigation

         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             // Get the new view controller using segue.destination.
             // Pass the selected object to the new view controller.
         }
         */

     }

     extension selectedplaces{
         
         func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
             
       
             let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "marker")
                     pinAnnotation.tintColor = .blue
                     pinAnnotation.isDraggable = true
                     pinAnnotation.canShowCallout = true
                     pinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                     return pinAnnotation
         
         }
         
         func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
                 let alertController = UIAlertController(title: "Add to Favourites", message:
                     "Are you sure to change this location?", preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(title: "Yes", style:  .default, handler: { (UIAlertAction) in
                    
                 CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: mapView.annotations[0].coordinate.latitude, longitude: mapView.annotations[0].coordinate.longitude)) {  placemark, error in
                            if let error = error as? CLError {
                                print("CLError:", error)
                                return
                             }
                            else if let placemark = placemark?[0] {
                             
                             var placeName = ""
                             var neighbourhood = ""
                             var city = ""
                             var state = ""
                             var postalCode = ""
                             var country = ""
                             
                             
                             if let name = placemark.name {
                                 placeName += name
                                         }
                             if let sublocality = placemark.subLocality {
                                 neighbourhood += sublocality
                                         }
                             if let locality = placemark.subLocality {
                                  city += locality
                                         }
                             if let area = placemark.administrativeArea {
                                           state += area
                                       }
                             if let code = placemark.postalCode {
                                           postalCode += code
                                       }
                             if let cntry = placemark.country {
                                                     country += cntry
                                                 }
                             
                             
                             let place = favplaces(placeLat:  mapView.annotations[0].coordinate.latitude, placeLong: mapView.annotations[0].coordinate.longitude, placeName: placeName, city: city, postalCode: postalCode, country: country)
                             self.editPlaces?.remove(at: self.editedPlace)
                             self.editPlaces?.append(place)
                             
                             self.editLocation()
                             self.navigationController?.popToRootViewController(animated: true)
                             }
                         
                         }
                    
                }))
            
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(alertController, animated: true, completion: nil)
                            
            }
}
