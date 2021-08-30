//
//  DataMemory+CoreDataProperties.swift
//  PhotoMemory
//
//  Created by Andres Marquez on 2021-08-15.
//
//

import Foundation
import CoreData


extension DataMemory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataMemory> {
        return NSFetchRequest<DataMemory>(entityName: "DataMemory")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

    var wrappedName: String {
        return name ?? ""
    }
}

extension DataMemory : Identifiable {

}
