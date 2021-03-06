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
import Charts

var dataType = ""
class ViewController: UIViewController, ChartViewDelegate {
    
    var barChart = BarChartView()
    var lineChart = LineChartView()
    var pieChart = PieChartView()
    
    // All of the UI components
    @IBOutlet var appView: UIView!
    @IBOutlet weak var topTitle: UITextField!
    @IBOutlet weak var dataTypePicker: UIPickerView!
    @IBOutlet weak var result: UITextField!
    @IBOutlet weak var textBox: UILabel!
    @IBOutlet weak var dataTypeInfo: UILabel!
    @IBOutlet weak var heartAnimation: UIImageView!
    @IBOutlet weak var dataTypeDisplay: UITableView!
    
    let dataTypeArray = ["Heart Rate", "Pulse"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataTypePicker.dataSource = self
        dataTypePicker.delegate = self
        barChart.delegate = self
        lineChart.delegate = self
        pieChart.delegate = self
        appView.backgroundColor = UIColor .systemGray6
        dataTypeDisplay.isHidden = true
        // Do any additional setup after loading the view. | Other stuff too
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /*All of the Bar Chart Stuff!
        barChart.frame = CGRect(x: dataTypeInfo.frame.origin.x + 300, y: dataTypeInfo.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height - 600)
        barChart.center = view.center

        view.addSubview(barChart)

        let set = BarChartDataSet(entries: [BarChartDataEntry(x: 1, y: 1),
                                            BarChartDataEntry(x: 2, y: 2)])
        set.colors = ChartColorTemplates.joyful()
        let data = BarChartData(dataSet: set)

        barChart.data = data
        */
        
        /* Pie Chart Stuff!
        pieChart.frame = CGRect(x: dataTypeInfo.frame.origin.x + 300, y: dataTypeInfo.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height - 600)
        pieChart.center = view.center

        view.addSubview(pieChart)
        // The data entries (will contain heart rate data
        var entries = [ChartDataEntry]()

        // Filling in the entries array with a for loop and entering it as ChartDataEntry
        for x in 0..<10 {
            entries.append(ChartDataEntry(x: Double(x), y: Double(x)))
        }

        // Adding the data to the LineChartDataSet
        let set = PieChartDataSet(entries: entries)
        // Different types of color schemes
        set.colors = ChartColorTemplates.joyful()
        let data = PieChartData(dataSet: set)

        pieChart.data = data
        */
        
        // Line Chart Stuff!!!!
        lineChart.frame = CGRect(x: dataTypeInfo.frame.origin.x + 300, y: dataTypeInfo.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height - 600)
        lineChart.center = view.center
        
        view.addSubview(lineChart)
        // The data entries (will contain heart rate data
        var entries = [ChartDataEntry]()
        
        // Filling in the entries array with a for loop and entering it as ChartDataEntry
        for x in 0..<10 {
            entries.append(ChartDataEntry(x: Double(x), y: Double(x)))
        }
        
        // Adding the data to the LineChartDataSet
        let set = LineChartDataSet(entries: entries)
        // Different types of color schemes
        set.colors = ChartColorTemplates.joyful()
        let data = LineChartData(dataSet: set)
        
        lineChart.data = data
    }
    
    // Left over function from the Tip Calculator; can be used to do other things
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
        //Timer.scheduledTimerWithTimeInterval(0.010, target:self, selector: #selector(ViewController.updateCounter), userInfo: nil, repeats: true)
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
            self.dataTypeDisplay.isHidden = false
        }
        // Printing out all of the data (it works!)
        
        //dataTypeDisplay.insertRows(at: <#T##[IndexPath]#>, with: <#T##UITableView.RowAnimation#>)
        var entries = [ChartDataEntry]()
        var temp = 0
        for data in sample {
            
            print("At", data.endDate - 18000, "your heart rate was", data.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())), "beats/minute.")
            entries.append(ChartDataEntry(x: Double(temp), y: Double(data.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))))
            temp += 1
        }
        // The next step would be to then store that data in a data base specific to the user where it can be easily accessed, turned into a graph for them (Heart Rate vs. Time)
        // Measure HRV Data too
        
        // Adding the data to the LineChartDataSet
        let set = LineChartDataSet(entries: entries)
        // Different types of color schemes
        set.colors = ChartColorTemplates.joyful()
        let data = LineChartData(dataSet: set)
        
        lineChart.data = data
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView,cellsForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "dataTypeDisplayCell", for: indexPath)
//        return cell
//    }

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
