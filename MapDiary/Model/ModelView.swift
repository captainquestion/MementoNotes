//
//  ModelView.swift
//  MapDiary
//
//  Created by canberk yılmaz on 2023-03-07.
//

//import Foundation
import CoreData
import UIKit

class ModelView {
    
    var itemsArray = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request : NSFetchRequest<Items> = Items.fetchRequest()

    
    func loadItems() {

        do{
            itemsArray = try context.fetch(request)
        } catch {
            print("Error loading items \(error)")
        }
        
    }
    
    
    func saveItems() {
        do {
            
            try context.save()
        } catch {
            print("Error saving items \(error)")
        }
    }

    // Delete entity from database according to its index
    func deleteItems(int: Int){
        
        do {
            context.delete(itemsArray[int])

            itemsArray.remove(at: int)
            saveItems()
            
            
        }
    }
    // Update database according to its index
    func updateDesc(currentText: String, currentIndex: Int){
         
        loadItems()
        itemsArray[currentIndex].desc = currentText
        saveItems()

    }
 
    // Getting images from core data as data to display as image
    func imagesFromCoreData(object: Data?) -> [UIImage]? {
        var retVal = [UIImage]()

        guard let object = object else { return nil }
        if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: object) {
            
            for data in dataArray {
                if let data = data as? Data, let image = UIImage(data: data) {
                    retVal.append(image)
                }
            }
        }
        
        return retVal
    }
    
    // Saving images into data for Core Data to utilize
    func coreDataObjectFromImages(images: [UIImage]) -> Data? {
        let dataArray = NSMutableArray()
        
        for img in images {
            if let data = img.jpegData(compressionQuality: 1) {
                dataArray.add(data)
            }
        }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
    }
}



