//
//  ViewController.swift
//  Pulling Apple Watch Data (needs a better name)
//
//  Created by John Smith V on 2/6/21.
//  Team members: Brain Siroka, Daniel Cruz, Nick Doolittle, Mutian Fan

/*
 Notes from meeting:
 May be able to use third-party watches through the Apple Health App
 This means we may not need to write 20 different plugins (exaggerated)
 We currently are able to pull heart rate data and any other data we need
 */

import UIKit
import HealthKitUI
import HealthKit

var dataType = ""
class ViewController: UIViewController {
    
    // All of the UI components
    @IBOutlet var appView: UIView!
    @IBOutlet weak var topTitle: UITextField!
    @IBOutlet weak var dataTypePicker: UIPickerView!
    @IBOutlet weak var result: UITextField!
    @IBOutlet weak var textBox: UILabel!
    @IBOutlet weak var dataTypeInfo: UILabel!
    @IBOutlet weak var heartAnimation: UIImageView!
    
    let dataTypeArray = ["Heart Rate", "Pulse"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataTypePicker.dataSource = self
        dataTypePicker.delegate = self
        appView.backgroundColor = UIColor .systemGray6
        // Do any additional setup after loading the view. | Other stuff too
    }
    
    // Left over function from the Tip Calculator; can be used to do other things
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }
    // This Stack Overflow post was helpful: https://stackoverflow.com/questions/28858667/heart-rate-data-on-apple-watch
    @IBAction func grabData(dataType: String){
        let healthStore = HKHealthStore()
        
        if(dataType == dataTypeArray[0]){
            // We are going to grab simulated heart rate data
            // The typesToRead is a set that contains all of the data types that are
            // going to be requested (currently only heart rate)
            let typesToRead = Set([
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
            
            // Asking authorization to read the data types in the set
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) -> Void in
                if success == false {
                    //NSLog("Error %d", error ?? <#default value#>)
                }
                
            }
            let sort: [NSSortDescriptor] = [.init(key: HKSampleSortIdentifierStartDate, ascending: false)]
            // Creating the query so we can get the data types
            let sampleQuery = HKSampleQuery(sampleType: typesToRead.first!, predicate: nil, limit: 25, sortDescriptors: sort, resultsHandler: resultsHandler)
            // Executing the query for the data
            healthStore.execute(sampleQuery)
        } else {

        }
    }
    
    func resultsHandler(query: HKSampleQuery, results: [HKSample]?, error: Error?) {

        guard error == nil else {
            print("Can't read the heart rate data", error!)
            return
        }
        
        // [HKQuanititySample] is the data type that results is going to become
        guard let sample = results as? [HKQuantitySample] else { return }
        /* A quick way to get the exact time the heart rate was taken
           For some reason when getting the raw startDate/endDate, the value
           is five hours later, so I subtract by 18000 seconds (5 hours) to get
           the exact time when the sample was taken
        */
        
        print(sample[0].startDate - 18000)
        print(sample[0].endDate - 18000)
        
        //let heartRateUnit: HKUnit = .init(from: "count/min")
        // This is how you get the integer values (from the first result)
        let finalHeartRate = Int(sample[0].quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))
        
        // Need to do this asynchronously for some reason (not too sure why)
        DispatchQueue.main.async {
            // Enables the little heart
            self.heartAnimation.isHidden = false
            self.dataTypeInfo.text = String(format: "Current %@: %d beats/min", dataType, finalHeartRate)
        }
        // Printing out all of the data (it works!)
        for data in sample {
            print("At", data.endDate - 18000, "your heart rate was", data.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())), "beats/minute.")
        }
        // The next step would be to then store that data in a data base specific to the user where it can be easily accessed, turned into a graph for them (Heart Rate vs. Time)
        // Measure HRV Data too
    }


}


extension ViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // The number so of rows in the picker corresponds to the number of elements in the array
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataTypeArray.count
    }
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataTypeArray[row]
    }
    // The point of this function is to be able to grab the number of people that the user picked and then recalculate the total per person
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dataType = String(dataTypeArray[row])
        print(dataType)
        grabData(dataType: dataType)
    }
}
