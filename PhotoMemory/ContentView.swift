//
//  ContentView.swift
//  PhotoMemory
//
//  Created by Andres Marquez on 2021-08-12.
//

import SwiftUI
import CoreData
import MapKit

struct Memory: Identifiable {
    var id: UUID
    var name: String
    var image: Image?
    var location: MKPointAnnotation?
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    
    @State private var image: Image?
    @State private var inputImage: UIImage?
    
    @State private var imageName = ""
    
    @State private var showingImagePicker = false
    @State private var showingSavedImage = false
    
    let locationFetcher = LocationFetcher()
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Rectangle()
                        .fill(AngularGradient(gradient: Gradient(colors: [.gray, .gray, .black, .white, .gray, .white]), center: .bottom)).ignoresSafeArea()
                    
                    if image != nil {
                        VStack {
                            image?
                                .resizable()
                                .scaledToFit()
                                .onTapGesture {
                                    self.showingImagePicker = true
                                }
                            
                            TextField("Image Name", text: $imageName)
                                .foregroundColor(.black)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .frame(width: geo.size.width, height: 75, alignment: .center)
                                
                            Button("Save") {
                                saveImage(image: inputImage!, name: imageName)
                                showingSavedImage = true
                            }
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 50, alignment: .center)
                            .background(Color.black)
                            .clipShape(Capsule())
                            
                        }
                    } else {
                        Text("Tap to select picture")
                            .foregroundColor(.white)
                            .font(.title)
                            .frame(width: geo.size.width * 0.85, height: 100, alignment: .center)
                            .background(Color.black)
                            .clipShape(Capsule())
                            .onTapGesture {
                                self.showingImagePicker = true
                            }
                    }
                }
            }
            .navigationBarTitle("PhotoMemory")
            .navigationBarItems(trailing: NavigationLink("List", destination: ListView())
                .foregroundColor(.black)
                .font(.title2)
            
            )
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage, sourceType: .camera)
        }
        
        .alert(isPresented: $showingSavedImage) {
            Alert(title: Text("Saved successfully"), message: nil, dismissButton: .default(Text("OK")))
        }
        .onAppear(perform: getLocation)
    }
    
    func getLocation() {
        self.locationFetcher.start()
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
            image = Image(uiImage: inputImage)
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func saveImage(image: UIImage, name: String) {
        //Creates unique identifier
        let id = UUID()
        
        //Creates file named after previous id
        let url = self.getDocumentsDirectory().appendingPathComponent("\(id).jpeg")
        
        //Saves image in file
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: url, options: [.atomicWrite, .completeFileProtection])
        } else {
            print("Could not save image")
        }
        
        //Stores name and id in CoreData entity
        let entity = DataMemory(context: moc)
        entity.name = name
        entity.id = id
        
        if let location = self.locationFetcher.lastKnownLocation {
            entity.latitude = location.latitude
            entity.longitude = location.longitude
            //print("\(location)")
        } else {
            print("Your location is unknown")
        }
        
        do {
            try moc.save()
        } catch {
            print(error.localizedDescription)
        }
        print("Saved")
    }
}

/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 */
