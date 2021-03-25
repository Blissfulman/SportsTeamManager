//
//  CoreDataManager.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 18.01.2021.
//

import CoreData

final class CoreDataManager {
    
    // MARK: - Properties
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private let modelName: String
    
    // MARK: - Initializers
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // MARK: - Public methods
    
    func getContext() -> NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createObject<T: NSManagedObject> (from entity: T.Type) -> T {
        let context = getContext()
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity),
                                                         into: context) as! T
        return object
    }
    
    func delete(object: NSManagedObject) {
        let context = getContext()
        context.delete(object)
        save(context: context)
    }
    
    func fetchDataWithController<T: NSManagedObject>(
        for entity: T.Type, sectionNameKeyPath: String? = nil, predicate: NSCompoundPredicate? = nil
    ) -> NSFetchedResultsController<T> {
        
        let context = getContext()
        let request: NSFetchRequest<T>
        
        if #available(iOS 10.0, *) {
            request = entity.fetchRequest() as! NSFetchRequest<T>
        } else {
            let entityName = String(describing: entity)
            request = NSFetchRequest(entityName: entityName)
        }
        
        let sortDescriptor = NSSortDescriptor(key: sectionNameKeyPath, ascending: true)
        
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: sectionNameKeyPath,
                                                    cacheName: nil)
        do {
            try controller.performFetch()
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
        }
        return controller
    }
}
