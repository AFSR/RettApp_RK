import HealthKit
import UIKit
import CoreData

class HealthManager{
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    let readTypes:[HKObjectType?] = [HKObjectType.characteristicType(forIdentifier: .bloodType),HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!]
    let writeTypes: [HKSampleType?] = []
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

    var isAuthorized:Bool {
        for readType in readTypes where readType != nil {
            print(readType ?? "")
            let status = healthKitStore.authorizationStatus(for: readType!)
            switch status{
            case .notDetermined, .sharingDenied:
                return false
            case .sharingAuthorized:
                continue
            }
        }
        return true
    }
    
    func showHealthKitAlert() -> UIAlertController? {
        
        let alertController: UIAlertController?
        let title = NSLocalizedString("You changed HealthKit permissions", comment: "")
        let msg = NSLocalizedString("Please, go to the Health App and give permissions back manually", comment: "")
        alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController!.addAction(action)
        
        return alertController
    }
    
    func syncWithHK(){
        
        //retrieveSleepAnalysis(since: lastHKSyncDate)
        retrieveBodyTemperature(since: lastHKSyncDate)
        retrieveStepCount(since: lastHKSyncDate)
        lastHKSyncDate = Date()
    }
    
    func retrieveStepCount(since: Date){
        let stepsCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let predicate = HKQuery.predicateForSamples(withStart: lastHKSyncDate, end: Date(), options: .strictEndDate)
        let stepsSampleQuery = HKSampleQuery(sampleType: stepsCount!,
                                             predicate: predicate,
                                             limit: Int(HKObjectQueryNoLimit),
                                             sortDescriptors: nil)
        { [unowned self] (query, results, error) in
            if let results = results as? [HKQuantitySample] {
                print(results)
            }
        }
        
        // Don't forget to execute the Query!
        healthKitStore.execute(stepsSampleQuery)
    }
    
    func retrieveBodyTemperature(since: Date) {
        
        // first, we define the object type we want
        if let temperatureType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let predicate = HKQuery.predicateForSamples(withStart: lastHKSyncDate, end: Date(), options: .strictEndDate)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: temperatureType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // something happened
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    // do something with my data
                    for item in result {
                        var jsonString = ""
                        if let data = DSJSONSerializer.hkSampleQueryResultToJsonData(result){
                            jsonString = String(data: data as Data, encoding: String.Encoding.utf8)!
                            
//                            let data = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "TaskAnswer", in: self.context.viewContext)!, insertInto: self.context.viewContext)
//
//                            data.setValue("DSTemperatureTask", forKey: "taskName")
//                            data.setValue(jsonString, forKey: "json")
//                            do {
//                                try data.validateForInsert()
//                            } catch {
//                                print(error)
//                            }
//                            (UIApplication.shared.delegate as! AppDelegate).saveContext()
                            
                        }
                    }
                }
            }
            
            // finally, we execute our query
            healthKitStore.execute(query)
        }
    }
    
    func retrieveSleepAnalysis(since: Date) {
        
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let predicate = HKQuery.predicateForSamples(withStart: lastHKSyncDate, end: Date(), options: .strictEndDate)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // something happened
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    // do something with my data
                    for item in result {
                        var jsonString = ""
                        if let data = DSJSONSerializer.hkSampleQueryResultToJsonData(result){
                            jsonString = String(data: data as Data, encoding: String.Encoding.utf8)!
                            
//                            let data = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "TaskAnswer", in: self.context.viewContext)!, insertInto: self.context.viewContext)
//                            
//                            data.setValue("DSSleepTask", forKey: "taskName")
//                            data.setValue(jsonString, forKey: "json")
//                            do {
//                                try data.validateForInsert()
//                            } catch {
//                                print(error)
//                            }
//                            (UIApplication.shared.delegate as! AppDelegate).saveContext()
                            
                        }
                        
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                            
                        }
                    }
                }
            }
            
            // finally, we execute our query
            healthKitStore.execute(query)
        }
    }
    
    func authorizeHealthKit(_ completion: ((_ success: Bool, _ error: NSError?) -> Void)?) {
        
        
        // If the store is not available (for instance, iPad) return an error and don't go on.
        if HKHealthStore.isHealthDataAvailable(){
            var healthKitTypesToRead:Set<HKObjectType> = Set()
            for readType in self.readTypes where readType != nil {
                healthKitTypesToRead.insert(readType!)
            }
            
            var healthKitTypesToWrite: Set<HKSampleType> = Set()
            for writeType in self.writeTypes where writeType != nil {
                healthKitTypesToWrite.insert(writeType!)
            }
            
            //healthKitStore.
            healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success: Bool, error: Error?) -> Void in
                completion?(success, error as NSError?)
            }
        } else {
            debugPrint("Health data not available, iPad maybe?")
            let error = NSError(domain: "fr.afsr.RettApp", code: 2, userInfo: [NSLocalizedDescriptionKey:NSLocalizedString("HealthKit is not available", comment: "")])
            completion?(false, error)
        }
    }
    
    func getBloodType() -> HKBloodTypeObject?{
        do{
            let bloodType = try healthKitStore.bloodType()
            return bloodType
        }catch let error{
            print(error)
            return nil
        }
    }
    
    func readProfile() -> (dateOfBirth:Date?, biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?){
        var dateOfBirth: Date?
        var bio: HKBiologicalSexObject?
        var blood: HKBloodTypeObject?
        do{
            dateOfBirth = try healthKitStore.dateOfBirth() as Date
            bio = try healthKitStore.biologicalSex()
            blood = try healthKitStore.bloodType()
        }catch let error{
            print("Age, bio or blood are nil \(error)")
        }
        
        return (dateOfBirth, bio, blood)
    }
    
    func readBPM(_ completion: @escaping (_ sampleQuery: HKSampleQuery, _ sample: [HKSample]?, _ error: Error?) -> ()) {
        let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: Date(timeIntervalSince1970: 1.0), end: Date(), options: .strictEndDate)
       
        
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: 0, sortDescriptors: nil) { (sampleQuery, samples: [HKSample]?, error: Error?) in
            completion(sampleQuery, samples, error)
        }
        
        healthKitStore.execute(query)
    }
}
