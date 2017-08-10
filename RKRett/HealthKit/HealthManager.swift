import HealthKit

class HealthManager{
    
    private let healthKitStore:HKHealthStore = HKHealthStore()
    private let readTypes:[HKObjectType?] = [HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)]
    private let writeTypes: [HKSampleType?] = []
    
    var isAuthorized:Bool {
        for readType in readTypes where readType != nil {
            print(readType)
            let status = healthKitStore.authorizationStatusForType(readType!)
            switch status{
            case .NotDetermined, .SharingDenied:
                return false
            case .SharingAuthorized:
                continue
            }
        }
        return true
    }
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!){
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
            healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success: Bool, error: NSError?) -> Void in
                if( completion != nil ){
                    completion(success: success, error: error)
                }else{
                    print("Completion block nil")
                }
            }
        }else{
            debugPrint("Health data not available, iPad maybe?")
            let error = NSError(domain: "io.darkshine.RettSyndrome", code: 2, userInfo: [NSLocalizedDescriptionKey:NSLocalizedString("HealthKit is not available", comment: "")])
            if( completion != nil ){
                completion(success: false, error: error)
            }else{
                debugPrint("Completion block nil")
            }
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
    
    func readProfile() -> (dateOfBirth:NSDate?, biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?){
        var dateOfBirth: NSDate?
        var bio: HKBiologicalSexObject?
        var blood: HKBloodTypeObject?
        do{
            dateOfBirth = try healthKitStore.dateOfBirth()
            bio = try healthKitStore.biologicalSex()
            blood = try healthKitStore.bloodType()
        }catch let error{
            print("Age, bio or blood are nil \(error)")
        }
        
        return (dateOfBirth, bio, blood)
    }
    
    func readBPM(completion: (sampleQuery: HKSampleQuery, sample: [HKSample]?, error: NSError?) -> ()) {
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        let predicate = HKQuery.predicateForSamplesWithStartDate(NSDate(timeIntervalSince1970: 10.0), endDate: NSDate(), options: .None)
        
        //        let count = NSSortDescriptor(key: "count", ascending: true)
        
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: 0, sortDescriptors: nil) { (sampleQuery: HKSampleQuery, sample: [HKSample]?, error: NSError?) -> Void in
            completion(sampleQuery: sampleQuery, sample: sample, error: error)
        }
        healthKitStore.executeQuery(query)
    }
}