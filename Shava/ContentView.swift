//
//  ContentView.swift
//  Shava
//
//  Created by Alice Zolotareva on 02.07.2021.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Home: View{
    //latitude широта/ longitude долгота
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 13.086, longitude: 80.2769), latitudinalMeters: 10000, longitudinalMeters: 10000)
    @State var tracking: MapUserTrackingMode = .follow
    
    @State var manager = CLLocationManager()
    @StateObject var managerDelegate = locationDelegate()
    var body: some View{
        VStack{
            
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: managerDelegate.pins){pin in
                MapPin(coordinate: pin.location.coordinate, tint: .blue)
            }
        }
        .onAppear{
            
            manager.delegate = managerDelegate
        }
    }
}

class locationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var pins : [Pin] = []
    //checking autorization status
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse{
            print("authorized")
            
            if manager.accuracyAuthorization != .fullAccuracy{
                print("reduced Accuracy")
                
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Location"){ (err) in
                    
                    if err != nil {
                        print(err!)
                        return
                    }
                }
            }
            
            manager.startUpdatingLocation()
        }
        else{
            print("not autorized")
            
            manager.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        pins.append(Pin(location: locations.last!))
    }
}

struct Pin: Identifiable {
    var id = UUID().uuidString
    var location : CLLocation
}
