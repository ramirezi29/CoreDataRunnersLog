//
//  DetailVC.swift
//  RunnersLog
//
//  Created by Ivan Ramirez on 1/26/22.
//

import UIKit
import MapKit
import CoreLocation


class DetailVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var saveButton: UIButton!
    
    var entry: Entry?
    
    private let locationManager = CLLocationManager()
    /// 804.672 meters is half a mile
    private let metersPerHalfMile = 804.672
    var locationFareDetail = "Current Location"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
        
        // Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        // Map
        myMapView.delegate = self
        myMapView.showsUserLocation = true
        myMapView.userTrackingMode = .follow
        myMapView.showsCompass = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let entry = entry {
            tracking(enabled: entry.trackLocation)
        }
    }
    
    func updateView() {
        
        guard let entry = entry else { return }
        
        distanceTextField.text = entry.distance
        locationSwitch.isOn = entry.trackLocation
    }
    
    func enableLocation() {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        myMapView.showsUserLocation = true
    }
    
    func disableLocation() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        myMapView.showsUserLocation = false
    }
    
    func tracking(enabled: Bool) {
        if enabled {
            enableLocation()
        } else {
            disableLocation()
        }
    }
    
    //MARK: - Location
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
            
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .denied:
            // pop up alert explaining why tracking is important to your app
            break
        case .restricted:
            break
        default:
            break
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let userLocation: CLLocation = locations[0] as CLLocation
        print(" 😝 \(userLocation.description) 😝")
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        myMapView.setRegion(region, animated: true)
        
        // Get user's Current Location and drop a pin
        let annotation: MKPointAnnotation = MKPointAnnotation()
        
        let previousAnnotations = self.myMapView.annotations
        
        if !previousAnnotations.isEmpty {
            let annotations = myMapView.annotations.filter({ !($0 is MKUserLocation) })
            myMapView.removeAnnotations(annotations)
        }
        
        annotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        
        annotation.title =  self.setUsersClosestLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        annotation.subtitle = "This place rocks"
        
        myMapView.addAnnotation(annotation)
    }
    
    
    func setUsersClosestLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> String {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geoCoder.reverseGeocodeLocation(location) {
            (placeMarks, error) -> Void in
            
            guard let placeMark = placeMarks?.first else { return }
            
            let thoroughfare = placeMark.thoroughfare ?? ""
            
            let subThoroughfare = placeMark.subThoroughfare ?? ""
            
            self.locationFareDetail = "\(thoroughfare), \(subThoroughfare)"
        }
        
        return locationFareDetail
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: metersPerHalfMile, longitudinalMeters: metersPerHalfMile)
        
        print(coordinateRegion.center)
        print(coordinateRegion)
        myMapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let distance = distanceTextField.text, !distance.isEmpty else {
            return
        }
        
        //check if an entry already exists
        if let entry = self.entry {
            //update
            EntryController.shared.updateEntry(entry: entry, trackLocation: locationSwitch.isOn, distance: distance)
        } else {
            //save
            let newEntry = Entry(distance: distance, trackLocation: locationSwitch.isOn, date: Date())
            
            EntryController.shared.createEntry(entry: newEntry)
        }
        dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name("RefreshNotificationIdentifier"), object: nil)
    }
    
    @IBAction func locationToggled(_ sender: Any) {
        tracking(enabled: locationSwitch.isOn)
    }
    
}
