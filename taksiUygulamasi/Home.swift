//
//  ContentView.swift
//  taksiUygulamasi
//
//  Created by Tülay MAYUNCUR on 10.04.2023.
//

import SwiftUI
import MapKit
import CoreLocation
import Firebase
import FirebaseAuth



struct ContentView: View {

    @State private var showLoginSignup = false
    @State var showSearch = false
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var source : CLLocationCoordinate2D!
    @State var destination : CLLocationCoordinate2D!
    @State var name = ""
    @State var distance = ""
    @State var time = ""
    @State var show = false
    @State var loading = false
    @State var book = false
    @State var doc = ""
    @State var data : Data = .init(count: 0)
    @State var search = false
    @State private var plate = ""
    

    var body: some View {
        
        
        ZStack {
            Color.yellow.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {

                    Spacer()
                    Button(action: {
                        self.showLoginSignup = true
                    }) {
                        Image(systemName: "power")
                            .foregroundColor(.black)
                    }
                    .frame(width: 80)
                  
                   // .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
                   // .frame(width: 55, height: 20)

                }
                Home()
            }
        }
        .fullScreenCover(isPresented: $showLoginSignup) {
            LoginSignUp()
                
     // .sheet(isPresented: $showSearch) {}
    }
        
}

struct Home : View {
    
    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert = false
    @State var source : CLLocationCoordinate2D!
    @State var destination : CLLocationCoordinate2D!
    @State var name = ""
    @State var distance = ""
    @State var time = ""
    @State var show = false
    @State var loading = false
    @State var book = false
    @State var doc = ""
    @State var data : Data = .init(count: 0)
    @State var search = false
    
    
    var body: some View{
         
         ZStack{
             
             ZStack(alignment: .bottom){
                 
                 VStack(spacing: 0){
                     HStack{
                         VStack(alignment: .leading, spacing: 15){
                             Text(self.destination != nil ? "Varış Noktası" : "Konum Seçiniz")
                                 .font(.title)
                                 //.offset(y: -10)
                                 
                             if self.destination != nil{
                                 Text(self.name)
                                     .fontWeight(.bold)
                             }
                         }
                         
                         Spacer()
                         
                         Button(action: {
                            self.search.toggle()
                         }){
                             Image(systemName:  "magnifyingglass")
                                 .foregroundColor(.black)
                                 .frame(width: 50,height: 50)
                         }
                     }
                     .padding()
                  //   .padding(.top)
                   //  .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
                 
                     .background(Color.yellow)

                     
                     MapView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination, name: self.$name, distance: self.$distance, time: self.$time, show: self.$show)
                     
                         .onAppear{
                             self.manager.requestAlwaysAuthorization()
                             
                         }
                     
                    }
                
                if self.destination != nil && self.show{
                    
                    if self.destination != nil{
                        
                        
                        ZStack(alignment: .topTrailing){
                            let price = String(format: "%.2f", 12.65 + (Double(self.distance) ?? 0.0) * 8.51)
                            let tarih = Date.now
                            
                            VStack(spacing:20){
                                
                                HStack{
                                    VStack(alignment:.leading, spacing: 15){
                                        Text("Bilgiler").bold()
                                        Text("Tarih: \(tarih)" )
                                        Text("Mesafe - "+self.distance+" KM")
                                        Text("Yolculuk Süresi:  - "+self.time+" Min")
                                        if let distance = Double(self.distance), 0.0..<3.22 ~= distance {
                                            Text("Ücret: 40₺")
                                            
                                        }else{
                                            
                                            Text("Ücret: \(price) ₺")
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                }
                                
                                Button(action: {
                                    
                                    self.loading.toggle()
                                    self.Book(price: price)
                                    
                                }){
                                    Text("Doküman Oluşturmak için Tıklayınız")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .frame(width: UIScreen.main.bounds.width/2)
                                }
                                .background(Color.red)
                                .clipShape(Capsule())
                                
                            }
                            
                            Button(action: {
                                self.map.removeOverlays((self.map.overlays))
                                self.map.removeAnnotations(self.map.annotations)
                                self.destination = nil
                                
                                self.show.toggle()
                                
                            }){
                                
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                                
                            }
                            
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                        .background(Color.white)
                        
                    }
                    
                }
            }
            
            if self.loading{
                Loader()
            }
            
            if self.book{
                
                Booked(data: self.$data, doc: self.$doc, loading: self.$loading, book: self.$book)
                
            }
             
             if self.search{
                 
                 SearchView(show: self.$search, map: self.$map, source: self.$source, destination: self.$destination, name: self.$name, distance: self.$distance, time: self.$time, detail: self.$show)
                 
             }
            
        }
        
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: self.$alert) { () -> Alert in
            
            Alert(title: Text("Error"), message: Text("Lütfen Ayarlarda Konumu Etkinleştirin!"),dismissButton: .destructive(Text("Tamam")))
            
        }
    }
    
    func Book(price: String) {
        let db = Firestore.firestore()
        let doc = db.collection("dokuman").document()
        self.doc = doc.documentID // Örnek bir özelliği olduğunu varsayarak güncellendi
        
        let from = GeoPoint(latitude: self.source.latitude, longitude: self.source.longitude)
        let to = GeoPoint(latitude: self.destination.latitude, longitude: self.destination.longitude)
        
        var priceText = ""
        if let distance = Double(self.distance), 0.0..<3.22 ~= distance {
            priceText = "40₺"
        } else {
            priceText = "\(price) ₺"
        }
        
        guard let user = Auth.auth().currentUser else {
            // Kullanıcı oturumu açmamışsa işlemi durdurun veya kullanıcıyı giriş yapmaya yönlendirin.
            return
        }
        
        let userEmail = user.email ?? "" // Kullanıcının e-posta adresini alın
        
        doc.setData(["kullanıcı": userEmail, "bulunduğu konum": from, "varış konumu": to, "km mesafesi": self.distance, "ücret": priceText, "tarih": FieldValue.serverTimestamp()]) { (err) in
            if let error = err {
                print(error.localizedDescription)
                return
            }
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(self.doc.data(using: .ascii), forKey: "inputMessage")
            
            
            if let outputImage = filter?.outputImage?.transformed(by: CGAffineTransform(scaleX: 5, y: 5)){
                let image = UIImage(ciImage: outputImage)
                self.data = image.pngData()!
            }
            
            self.loading.toggle()
            self.book.toggle()
        }
    }


    struct Loader : View {
        
        @State var show = false
        
        var body: some View{
            GeometryReader{ geometry in
                VStack(spacing: 20){
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 30, height: 30)
                        .rotationEffect(.init(degrees: self.show ? 360 : 0))
                        .onAppear(){
                            withAnimation(Animation.default.speed(0.45).repeatForever(autoreverses: false)){
                                self.show.toggle()
                            }
                        }
                    Text("Lütfen Bekleyin...")
                }
                .padding(.vertical, 25)
                .padding(.horizontal,40)
                .background(Color.white)
                .cornerRadius(12)
                
                .background(Color.black.opacity(0.25).edgesIgnoringSafeArea(.all))
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
    
    struct MapView: UIViewRepresentable {
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(parent1: self)
        }
        
        @Binding var map: MKMapView
        @Binding var manager: CLLocationManager
        @Binding var alert: Bool
        @Binding var source: CLLocationCoordinate2D!
        @Binding var destination: CLLocationCoordinate2D!
        @Binding var name : String
        @Binding var distance : String
        @Binding var time : String
        @Binding var show : Bool
        
        
        
        
        func makeUIView(context: Context) -> MKMapView {
            map.delegate = context.coordinator
            manager.delegate = context.coordinator
            map.showsUserLocation = true
            let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.tap(ges:)))
            
            map.addGestureRecognizer(gesture)
            return map
        }
        
        func updateUIView(_ uiView: MKMapView, context: Context) {
        }
      
        class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
            
            var parent: MapView
            
            init(parent1: MapView) {
                parent = parent1
            }
            
            func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                if status == .denied {
                    self.parent.alert.toggle()
                } else {
                    self.parent.manager.startUpdatingLocation()
                }
            }
            
            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                
                let region = MKCoordinateRegion(center: locations.last!.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
                self.parent.source = locations.last!.coordinate
                self.parent.map.region = region
                
            }
            @objc func tap(ges: UITapGestureRecognizer){
                
                let location = ges.location(in: self.parent.map)
                let mplocation = self.parent.map.convert(location,toCoordinateFrom: self.parent.map)
                
                let point = MKPointAnnotation()
                
                point.subtitle = "Varış Noktası"
                point.coordinate = mplocation
                
                self.parent.destination = mplocation
                
                let decoder = CLGeocoder()
                decoder.reverseGeocodeLocation(CLLocation(latitude: mplocation.latitude, longitude: mplocation.longitude )) { (places,err) in
                    
                    if err != nil{
                        
                        print((err?.localizedDescription)!)
                        return
                    }
                    self.parent.name = places?.first?.name ?? ""
                    point.title = places?.first?.name ?? ""
                    
                    self.parent.show = true
                    
                }
                
                let req = MKDirections.Request()
                req.source = MKMapItem(placemark: MKPlacemark(coordinate: self.parent.source))
                
                req.destination = MKMapItem(placemark: MKPlacemark(coordinate: mplocation))
                
                let directions = MKDirections(request: req)
                directions.calculate{ (dir,err) in
                    
                    if err != nil{
                        
                        print((err?.localizedDescription)!)
                        return
                        
                    }
                    let polyline = dir?.routes[0].polyline
                    
                    let dis = dir?.routes[0].distance as! Double
                    self.parent.distance = String(format: "%0.2f",dis / 1000)
                    
                    let time = dir?.routes[0].distance as! Double
                    self.parent.time = String(format: "%0.2f",time / 60)
                    
                    
                    self.parent.map.removeOverlays(self.parent.map.overlays)
                    
                    self.parent.map.addOverlay(polyline!)
                    self.parent.map.setRegion(MKCoordinateRegion(polyline!.boundingMapRect), animated: true)
                    
                }
                
                self.parent.map.removeAnnotations(self.parent.map.annotations)
                self.parent.map.addAnnotation(point)
                
            }
            
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
                
                let over = MKPolylineRenderer(overlay: overlay)
                over.strokeColor = .red
                over.lineWidth = 3
                return over
                
                
            }
        }
    }
    
    //güncel sarı renkli taksi açılış ücreti 12,65 TL, kilometre başına ücreti ise 8,51 TL’dir.
    
    struct Booked : View {
        
        @Binding var data : Data
        @Binding var doc : String
        @Binding var loading : Bool
        @Binding var book : Bool
        
        
        var body: some View{
            
            ZStack {
                Color.black.opacity(0.25).edgesIgnoringSafeArea(.all) // Arkaplanı ekleyin
                
                GeometryReader { geometry in
                    VStack(spacing: 25) {
                        Image(uiImage: UIImage(data: self.data)!)
                        Text("Döküman oluşturuldu !").foregroundColor(Color.green)
                        Button(action: {
                            self.loading.toggle()
                            self.book.toggle()
                            
                            let db = Firestore.firestore()
                            db.collection("Dokuman").document(self.doc).delete { (err) in
                                if err != nil {
                                    print((err?.localizedDescription)!)
                                    return
                                }
                                self.loading.toggle()
                            }
                        })
                        {
                            Text("Kapat")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .frame(width: geometry.size.width / 2) // Genişlik için geometry.size.width kullanın
                        }
                        .background(Color.red)
                        .clipShape(Capsule())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .frame(height: geometry.size.height / 2) // Yükseklik için geometry.size.height kullanın
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Merkezlemek için position kullanın
                }
            }
            
            .background(Color.black.opacity(0.25).edgesIgnoringSafeArea(.all))
                }
            }
        }
    }


struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
