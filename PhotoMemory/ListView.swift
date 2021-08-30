//
//  ListView.swift
//  PhotoMemory
//
//  Created by Andres Marquez on 2021-08-13.
//

import SwiftUI
import CoreData
import MapKit

struct ListView: View {
    @State private var memories = [Memory]()
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: DataMemory.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DataMemory.name, ascending: true)]) var results: FetchedResults<DataMemory>
    
    init(){
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .gray
        //UITableView.appearance().backgroundColor = .gray
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(AngularGradient(gradient: Gradient(colors: [.gray, .gray, .black, .gray, .white]), center: .bottom)).ignoresSafeArea()
            
            List {
                ForEach(memories, id: \.id) { memory in
                    NavigationLink(destination: MapView(annotation: memory.location!)) {
                        HStack {
                            memory.image?
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            Text(memory.name)
                                .padding()
                                .font(.title2)
                        }
                    }
                } .onDelete(perform: deleteMemory)
            }
            .onAppear(perform: loadList)
            .toolbar {
                EditButton()
        }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func loadList() {
        //Empty the memories array to get rid off repetition
        memories = []
        
        for content in results {
            //finds url matching unique id from CoreData
            let url = self.getDocumentsDirectory().appendingPathComponent("\(content.id!).jpeg").path
           //Gets and loads the image from that url
            guard let uiImage = UIImage(contentsOfFile: url) else {
                print("Image could not be loaded from filemanager")
                return
            }
            let newImage = Image(uiImage: uiImage)
            let location = MKPointAnnotation()
            location.title = content.wrappedName
            location.subtitle = ""
            location.coordinate = CLLocationCoordinate2D(latitude: content.latitude, longitude: content.longitude)
            
            //reloads our data into the memories array
            memories.append(Memory(id: content.id!, name: content.wrappedName, image: newImage, location: location))
        }
    }
    
    func deleteMemory(at offsets: IndexSet) {
        //Delete from CoreData
        for offset in offsets {
            // find the selected value in our fetch request
            let memory = results[offset]
            let id = memory.id
            
            //Delete from documents directory
            let url = self.getDocumentsDirectory().appendingPathComponent("\(id!).jpeg").path
            
            do {
                try FileManager.default.removeItem(atPath: url)
            } catch let error {
                print("Could not delete image. \(error)")
            }

            // delete it from the context
            moc.delete(memory)
        }
        // save the context
        try? moc.save()
        
        //reload view
        loadList()
    }
}
