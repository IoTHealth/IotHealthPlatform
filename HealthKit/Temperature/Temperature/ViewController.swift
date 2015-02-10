import UIKit
import HealthKit

class ViewController: UIViewController, UITextFieldDelegate  {
    
    var myHealthStore : HKHealthStore!
    var myReadField: UITextField!
    var myWriteField: UITextField!
    var myReadButton: UIButton!
    var myWriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // HealthStoreの生成
        myHealthStore = HKHealthStore()
        
        // HealthStoreへの許可を申請
        requestAuthorization()
        
        // Write用
        myWriteField = UITextField(frame: CGRectMake(0,0,300,30))
        myWriteField.placeholder = "値を入力してください(c)"
        myWriteField.delegate = self
        myWriteField.borderStyle = UITextBorderStyle.RoundedRect
        myWriteField.layer.position = CGPoint(x:self.view.bounds.width/2,y:50);
        self.view.addSubview(myWriteField)
        
        // Read用
        myReadField = UITextField(frame: CGRectMake(0,0,300,30))
        myReadField.placeholder = "平均値(c)"
        myReadField.enabled = false
        myReadField.delegate = self
        myReadField.borderStyle = UITextBorderStyle.RoundedRect
        myReadField.layer.position = CGPoint(x:self.view.bounds.width/2,y:100);
        self.view.addSubview(myReadField)
        
        // 読み込みボタン
        myReadButton = UIButton()
        myReadButton.frame = CGRectMake(0,0,300,40)
        myReadButton.backgroundColor = UIColor.redColor();
        myReadButton.layer.masksToBounds = true
        myReadButton.setTitle("温度読み込み", forState: UIControlState.Normal)
        myReadButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myReadButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        myReadButton.layer.cornerRadius = 20.0
        myReadButton.layer.position = CGPoint(x: self.view.frame.width/2, y:200)
        myReadButton.tag = 1
        myReadButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myReadButton);
        
        // 書き込みボタン
        myWriteButton = UIButton()
        myWriteButton.frame = CGRectMake(0,0,300,40)
        myWriteButton.backgroundColor = UIColor.blueColor();
        myWriteButton.layer.masksToBounds = true
        myWriteButton.setTitle("温度書き込み", forState: UIControlState.Normal)
        myWriteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myWriteButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        myWriteButton.layer.cornerRadius = 20.0
        myWriteButton.layer.position = CGPoint(x: self.view.frame.width/2, y:250)
        myWriteButton.tag = 2
        myWriteButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myWriteButton);
    }
    
    //
    // ボタンイベント
    //
    func onClickMyButton(sender: UIButton){
        if(sender.tag == 1){
            readData()
        }
        else if(sender.tag == 2){
            let myTemperatureStr: NSString = myWriteField.text
            writeData(myTemperatureStr.doubleValue)
        }
    }
    
    private func requestAuthorization() {
        
        //読み込みを許可する型
        let typeOfRead = [
            //HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyTemperature)
            /HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        ]
        let typeOfReads = NSSet(array: typeOfRead)
        
        //書き込みを許可する型
        let typeOfWrite = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyTemperature)
        ]
        let typeOfWrites = NSSet(array: typeOfWrite)
        
        // HealthStoreへのアクセス承認をおこなう
        self.myHealthStore.requestAuthorizationToShareTypes(typeOfWrites, readTypes: typeOfReads, completion: {
            (success: Bool, error: NSError!) in
            if success {
                println("Healthkit Success!")
            } else {
                println("Healthkit Error!")
            }
        })
    }
    
    //
    // 体温を呼び出す
    // nutritionは平均、最大、最小の値は取れない
    private func readData() {
        var error: NSError?
        
        let typeOfTemperature = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyTemperature)
        
        let calendar: NSCalendar! = NSCalendar.currentCalendar()
        let now: NSDate = NSDate()
        let startDate: NSDate = calendar.startOfDayForDate(now)
        let endDate: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: 1, toDate: startDate, options: nil)!
        
        let predicate: NSPredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: HKQueryOptions.StrictStartDate)
        
        let statsOptions: HKStatisticsOptions = (HKStatisticsOptions.None)
        
        let query: HKStatisticsQuery = HKStatisticsQuery(quantityType: typeOfTemperature,
            quantitySamplePredicate: predicate, options: statsOptions, completionHandler: {
                (query: HKStatisticsQuery!, result: HKStatistics!, error: NSError!) in
                dispatch_async(dispatch_get_main_queue(),{
                    self.myReadField.text = "最小:\(result.minimumQuantity()) 最大:\(result.maximumQuantity())"
                })
                
                if let error = error {
                    println("Read error: \(error.localizedDescription)")
                } else {
                    println("Read success!")
                }
        })
        
        self.myHealthStore.executeQuery(query)
    }
    
    /*
    体温データを保存.
    */
    private func writeData(myTemperature: Double){
        
        // 体温のタイプ.
        let typeOfTemperature = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyTemperature)
        // 体温データを作成.
        let myTemperature = HKQuantity(unit: HKUnit.degreeCelsiusUnit(), doubleValue: myTemperature)
        // StoreKit保存用データを作成.
        let myTemperatureData = HKQuantitySample(type: typeOfTemperature, quantity: myTemperature, startDate: NSDate(), endDate: NSDate())
        
        // データの保存.
        self.myHealthStore.saveObject(myTemperatureData, withCompletion: {
            (success: Bool, error: NSError!) in
            if success {
                println("Write Success!")
            } else {
                println("Write Error!")
            }
        })
        
    }
}