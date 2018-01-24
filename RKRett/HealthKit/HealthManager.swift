import HealthKit

class HealthManager{
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    let readTypes:[HKObjectType?] = [HKObjectType.characteristicType(forIdentifier: .bloodType),HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!]
    let writeTypes: [HKSampleType?] = []
    
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
        alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController!.addAction(action)
        
        return alertController
    }
    
    func authorizeHealthKit(_ completion: ((_ success: Bool, _ error: NSError?) -> Void)?) {
        // If the store is not available (for instance, iPad) return an error and don't go on.
        if HKHealthStore.isHealthDataAvailable(){
            var healthKitTypesToRead:Set<HKObjectType> = Set()
            for readType in self.readTypes where readType != nil {
                healthKitTypesToRead.insert(readType!)
            }
            print(healthKitTypesToRead)
            
            var healthKitTypesToWrite: Set<HKSampleType> = Set()
            for writeType in self.writeTypes where writeType != nil {
                healthKitTypesToWrite.insert(writeType!)
            }
            print(healthKitTypesToWrite)
            
            
            //            healthKitStore.
            healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success: Bool, error: Error?) -> Void in
                completion?(success, error as NSError?)
            }
        } else {
            debugPrint("Health data not available, iPad maybe?")
            let error = NSError(domain: "io.darkshine.RettSyndrome", code: 2, userInfo: [NSLocalizedDescriptionKey:NSLocalizedString("HealthKit is not available", comment: "")])
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
        
        //        let count = NSSortDescriptor(key: "count", ascending: true)
        
        
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: 0, sortDescriptors: nil) { (sampleQuery, samples: [HKSample]?, error: Error?) in
            completion(sampleQuery, samples, error)
        }
        
        healthKitStore.execute(query)
    }
}
