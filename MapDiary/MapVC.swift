//
//  MapVC.swift
//  MapDiary
//
//  Created by canberk yılmaz on 2023-03-11.
//

import UIKit
import MapKit


class MapVC: UIViewController {
    
    var modelView = ModelView()
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var longituteV = Double()
    lazy var latitudeV = Double()
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        mapView.delegate = self
     goToMap(lat: latitudeV, lon: longituteV)
   
        
        
    }
    
    func goToMap(lat: Double, lon: Double){
        //taking location parameters and assign it as CLLocation
        let location = CLLocation(latitude: lat, longitude: lon)
        //changing the CLLocation instance into CLLocationCoordinate2D
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        //determining the zoom rate
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        //setting the region
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        //adding a annotation pin to the given region
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "Title"
        pin.subtitle = "SubTitle"
        mapView.addAnnotation(pin)
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard !(annotation is MKUserLocation) else {
//            return nil
//        }
//
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
//
//        if annotationView == nil {
//            //Create the view
//
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
////            annotationView?.annotation = .
//            annotationView?.canShowCallout = true
//            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//
//        }else {
//            annotationView?.annotation = annotation
//        }
//
//
//        annotationView?.image = UIImage(named: "mappin.circle.fill")
//
//
//        return annotationView
//    }
    
    
    func openMapButtonAction(latitude: Double, longitude: Double) {
            

            let appleURL = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
            let googleURL = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"
            let wazeURL = "waze://?ll=\(latitude),\(longitude)&navigate=false"

            let googleItem = ("Google Map", URL(string:googleURL)!)
            let wazeItem = ("Waze", URL(string:wazeURL)!)
            var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]

            if UIApplication.shared.canOpenURL(googleItem.1) {
                installedNavigationApps.append(googleItem)
            }

            if UIApplication.shared.canOpenURL(wazeItem.1) {
                installedNavigationApps.append(wazeItem)
            }

            let alert = UIAlertController(title: "Selection", message: "Select Navigation App", preferredStyle: .actionSheet)
            for app in installedNavigationApps {
                let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                    UIApplication.shared.open(app.1, options: [:], completionHandler: nil)
                })
                alert.addAction(button)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
    
    @IBAction func navigateToMap(_ sender: UIBarButtonItem) {
        
        openMapButtonAction(latitude: latitudeV, longitude: longituteV)

    }

}

