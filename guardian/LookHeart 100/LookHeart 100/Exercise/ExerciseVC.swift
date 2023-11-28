import UIKit
import Charts

var decimalSec = 0
var sec = 0.0
var min = 0.0

var  workoutTimer = 0

var baseAllstep = 0
var baseDistanceKM = 0.0
var baseDCal = 0.0
var baseDExeCal = 0.0

class ExerciseVC: UIViewController {
    
    private let safeAreaView = UIView()
    
    var timer1 = Timer()
    var timer2 = Timer()
    
    
    // 데이터 저장 변수
    var exerciseDate = ""
    var exerciseStartTime = ""
    var exerciseEndTime = ""
    var exerciseMinBpm = 100
    var exerciseMaxBpm = 0
    var bpmCount = 0
    var exerciseStep = ""
    var exerciseDistance = ""
    var exerciseECal = ""
    
    var dataEntries = [ChartDataEntry]()
    
    var startStopFlag:Bool = false
    
    var xValue: Double = 600
    
    let arrowImage =  UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .light))?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
    
    /*
     ---------------------------- Navigationbar ----------------------------
     */
    // Navigation title Label
    let titleLabel: UILabel = {
        let label = UILabel()

        label.text = "LOOKHEART"
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .black
        
        return label
    }()
    
    lazy var batteryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold) // 크기, 굵음 정도 설정
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataReceived(_:)), name: Notification.Name("Battery"), object: nil)
        
        return label
    }()
    
    @objc func dataReceived(_ notification: Notification){
        if let text = notification.object as? String {
            batteryLabel.text = text
            
            let progressString = text.trimmingCharacters(in: ["%"])
            let progressFloat = Float(progressString)!
            let max = 100
            batProgress.setProgress(progressFloat/Float(max), animated: false)
        }
    }
    
    // Navigation battery prograss
    lazy var batProgress: UIProgressView = {
        let battery = UIProgressView()

        let intBattery = UserDefaults.standard.integer(forKey: "MyBattery")
        let max = 100
        
        let batteryLevel: Float = Float(intBattery) / Float(max)// 프로그래스 바 값 설정
        
        battery.setProgress(batteryLevel, animated: false)
        battery.progressViewStyle = .default
        battery.progressTintColor = UIColor.red
        battery.trackTintColor = UIColor.lightGray
        battery.layer.cornerRadius = 8
        battery.frame = CGRect(x: 0, y: 0, width: 50, height: 0)
        battery.clipsToBounds = true
        // height 높이 설정
        battery.transform = battery.transform.scaledBy(x: 1, y: 3)

        return battery
    }()
    
    let customView: UIView = {
        let customView = UIView()
        customView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        return customView
    }()
    
    /*
     ---------------------------- chartView ----------------------------
     */
    
    lazy var chartView: LineChartView =  {
        let chartView = LineChartView()
        return chartView
        
    }()
    
    /*
     ---------------------------- Label ----------------------------
     */


    let workoutTimeBackground: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
//        view.layer.borderColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0).cgColor
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.cornerRadius = 20
        return view
    }()
    
    var workoutTimeLabel: UIButton = {
        let label = UIButton()
        label.setTitle("운동기록", for: .normal)
        label.setTitleColor(.darkGray, for: .normal)
        label.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label.backgroundColor = .white
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: -10, right: 10)
        label.isEnabled = false
        
        return label
    }()
    
    let stopWatch: UILabel = {
        let label = UILabel()

        label.text = "00:00"
        label.font = UIFont.systemFont(ofSize: 24, weight: .heavy) // 크기, 굵음 정도 설정
//        label.textColor = UIColor(red: 120/255, green: 163/255, blue: 43/255, alpha: 1.0)
        label.textColor = .darkGray
        
        return label
    }()


    /*
     ---------------------------- StackView ----------------------------
     */
    
    let bpmBackground: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.layer.borderWidth = 3
        label.layer.borderColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0).cgColor
        label.layer.cornerRadius = 20
        return label
    }()
    let myBpmLabel: UILabel = {
        let label = UILabel()

        label.text = "맥박"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()

    let workBpmValue: UILabel = {
        let label = UILabel()

        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()
    
    let myAverageBpmLabel: UILabel = {
        let label = UILabel()

        label.text = "평균맥박"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()

    let workAverageBpmValue: UILabel = {
        let label = UILabel()

        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()
    
    let stepAndDistanceBackground: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.layer.borderWidth = 3
        label.layer.borderColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0).cgColor
        label.layer.cornerRadius = 20
        return label
    }()
    
    let myStepLabel: UILabel = {
        let label = UILabel()

        label.text = "걸음"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()

    let workStepValue: UILabel = {
        let label = UILabel()

        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()
    
    let myDistanceLabel: UILabel = {
        let label = UILabel()

        label.text = "거리(Km)"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()
    
    let workdistanceValue: UILabel = {
        let label = UILabel()

        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()
    
    let calBackground: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.layer.borderWidth = 3
        label.layer.borderColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0).cgColor
        label.layer.cornerRadius = 20
        return label
    }()
    
    let myACalLabel: UILabel = {
        let label = UILabel()

        label.text = "활동칼로리"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()

    let workeCalValue: UILabel = {
        let label = UILabel()

        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()
    
    let myTCalLabel: UILabel = {
        let label = UILabel()

        label.text = "총칼로리"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()

    let worktCalValue: UILabel = {
        let label = UILabel()

        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [bpmBackground, stepAndDistanceBackground, calBackground])
        
        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        return stackView
    }()
    
    lazy var bpmStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [myBpmLabel, workBpmValue])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        
        return stackView
    }()
    lazy var averageBpmstackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [myAverageBpmLabel, workAverageBpmValue])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        
        return stackView
    }()
    
    lazy var stepStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [myStepLabel, workStepValue])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        
        return stackView
    }()
    lazy var distanceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [myDistanceLabel, workdistanceValue])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        
        return stackView
    }()
    
    lazy var aCalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [myACalLabel, workeCalValue])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        
        return stackView
    }()
    lazy var tCalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [myTCalLabel, worktCalValue])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        
        return stackView
    }()
    
    /*
     ---------------------------- viewDidLoad ----------------------------
     */
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 시작과 동시에 타이머 시작
        workoutStart()
        
        // navi, view, constraints 설정
        setNavigation()
        setup()
        Constraints()
        
        setupInitialDataEntries()
        setupChartData()
        
        chartView.noDataText = ""
    }
    
    // 현재 뷰를 벗어남
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let items = tabBarController?.tabBar.items {
            items[3].isEnabled = true
        }
    }
    // 현재 뷰로 이동함
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 운동 중 Tarchycardia 알림 안울리게 flag 설정
        defaults.set(true, forKey: "exerciseTarchycardiaFlag")
        
        // 운동 중 workout 탭을 다시 누를 수 없게 비활성화
        if let items = tabBarController?.tabBar.items {
            items[3].isEnabled = false
        }
    }
    
    func workoutStart(){
        dataEntries.removeAll()
        initialWorkoutReset()
        
        exerciseTimeSave(true)
        
        timer1 = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(exedidUpdatedChartView), userInfo: nil, repeats: true)
        timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(workout), userInfo: nil, repeats: true)
    }
    

    @objc func exedidUpdatedChartView() {
        var newDataEntry:ChartDataEntry
        // 연결이 된 상태에서만 bpm 찍기
        if connectionFlag == 1{
            newDataEntry = ChartDataEntry(x: xValue, y: Double(real_bpm))
        }
        else {
            newDataEntry = ChartDataEntry(x: xValue, y: Double(0))
        }
        
        updateChartView(with: newDataEntry, dataEntries: &dataEntries)
        xValue += 1
    }
    
    
    func setupInitialDataEntries() {
        (0..<Int(xValue)).forEach {
            let dataEntry = ChartDataEntry(x: Double($0), y: 60)
            dataEntries.append(dataEntry)
        }
    }
    
    func setupChartData() {
        // 1
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "BPM")
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(NSUIColor.red)
        chartDataSet.mode = .linear
        chartDataSet.drawValuesEnabled = false
        // 2
        let chartData = LineChartData(dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.drawMarkers = false
        chartView.leftAxis.axisMinimum = 60
        chartView.leftAxis.axisMaximum = 180
        chartView.xAxis.labelPosition = .bottom
        
    }
    
    func updateChartView(with newDataEntry: ChartDataEntry, dataEntries: inout [ChartDataEntry]) {
        if let oldEntry = dataEntries.first {
            dataEntries.removeFirst()
            chartView.data?.removeEntry(oldEntry, dataSetIndex: 0)
        }
        
        dataEntries.append(newDataEntry)
        chartView.data?.addEntry(newDataEntry, dataSetIndex: 0)
        
        chartView.notifyDataSetChanged()
        chartView.moveViewToX(newDataEntry.x)
    }
    
    @objc func workoutReset(_ sender: UIButton!){
        // 정지
        if startStopFlag == false{
            startStopFlag = true
            
            exerciseTimeSave(false) // 종료 시간 체크
            
            let alert = UIAlertController(title: "알림", message: "운동을 기록하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "확인", style: .destructive, handler: { [self] Action in
                exerciseDataSave()
                resentDataSave()
            })
            let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: { [self] Action in
                resentDataSave()
            })
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: false)
            
            wdCal = 0.0
            wdExeCal = 0.0
            wallstep = 0
            wdistance = 0.0
            
            workoutTimer = 0
            decimalSec = 0
            sec = 0.0
            min = 0.0
     
            worktCalValue.text = String(0)
            workeCalValue.text = String(0)
            workStepValue.text = String(0)
            workdistanceValue.text = String(0.000)
            stopWatch.text = "00:00"
            workBpmValue.text = String(0)
            workAverageBpmValue.text = String(0)
            timer1.invalidate()
            timer2.invalidate()
            chartView.clear()
            
            // 기존 버튼의 액션과 타겟 가져오기
            let existingButton = navigationItem.rightBarButtonItem
            let target = existingButton?.target
            let action = existingButton?.action

            // 새로운 이미지로 버튼 생성
            let newImage = UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .light))?.withTintColor(.blue, renderingMode: .alwaysOriginal)
            let newButton = UIBarButtonItem(image: newImage, style: .plain, target: target, action: action)

            // 네비게이션 바 버튼 이미지 업데이트
            navigationItem.rightBarButtonItem = newButton
            
            defaults.set(false, forKey: "exerciseTarchycardiaFlag")
            
        }
        // 시작
        else{
            // 기존 버튼의 액션과 타겟 가져오기
            let existingButton = navigationItem.rightBarButtonItem
            let target = existingButton?.target
            let action = existingButton?.action

            // 새로운 이미지로 버튼 생성
            let newImage = UIImage(systemName: "stop.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .light))?.withTintColor(.red, renderingMode: .alwaysOriginal)
            let newButton = UIBarButtonItem(image: newImage, style: .plain, target: target, action: action)

            // 네비게이션 바 버튼 이미지 업데이트
            navigationItem.rightBarButtonItem = newButton
            
            startStopFlag = false
            workoutStart()
            setupInitialDataEntries()
            setupChartData()
            
            defaults.set(true, forKey: "exerciseTarchycardiaFlag")
            
        }
    }
 
    
 func initialWorkoutReset(){
        wdCal = 0.0
        wdExeCal = 0.0
        wallstep = 0
        wdistance = 0.0
        
        workoutTimer = 0
        decimalSec = 0
        sec = 0.0
        min = 0.0
        
        baseAllstep = defaults.integer(forKey: "allstep")
        baseDistanceKM = defaults.double(forKey: "distanceKM")
        baseDCal = defaults.double(forKey: "dCal")
        baseDExeCal = defaults.double(forKey: "dExeCal")

        
        worktCalValue.text = String(0)
        workeCalValue.text = String(0)
        workStepValue.text = String(0)
        workdistanceValue.text = String(0.000)
        stopWatch.text = "00:00"
        workBpmValue.text = String(0)
        workAverageBpmValue.text = String(0)
        timer1.invalidate()
        timer2.invalidate()
        chartView.clear()
    }
    
    @objc func workout(_ sender: UIButton!){
        
        workoutTimer += 1
       
        let sec = ((workoutTimer) % 60)
        let min = (workoutTimer) / 60
        
        
        let sec_string = "\(sec)".count == 1 ? "0\(sec)" : "\(sec)"
        let min_string = "\(min)".count == 1 ? "0\(min)" : "\(min)"

        stopWatch.text = String(min_string)+":"+String(sec_string)
        
//        workBpmValue.text = String(real_bpm)
        // 연결이 되었을 경우에만 값 설정
        if connectionFlag == 1 {
            workBpmValue.text = String(real_bpm)
            workAverageBpmValue.text = String(tenMinutelVAvg)
            // 최소 bpm, 최대 bpm 저장
            if exerciseMinBpm > real_bpm{ exerciseMinBpm = real_bpm }
            if exerciseMaxBpm < real_bpm{ exerciseMaxBpm = real_bpm }
        }
        else {
            workBpmValue.text = "0"
            workAverageBpmValue.text = "0"
        }
        
        wdCal = dCal - baseDCal
        wdExeCal = dExeCal - baseDExeCal
        wallstep = allstep - baseAllstep
        wdistance = distanceKM - baseDistanceKM
        
        let   widCal = Int(wdCal)
        let  widExeCal = Int(wdExeCal)

        worktCalValue.text = String(widCal)
        workeCalValue.text = String(widExeCal)
        workStepValue.text = String(wallstep)

        // 데이터 저장용 변수
        exerciseStep = String(wallstep)
        exerciseECal = String(widExeCal)
        
        if wdistance < 0 {
            workdistanceValue.text = String(format: "%.3f", 0.000)
            exerciseDistance = String(format: "%.3f", 0.000)
        }
        else {
            workdistanceValue.text = String(format: "%.3f", wdistance)
            exerciseDistance = String(format: "%.3f", wdistance)
        }
    }
    
    
    // MARK: - csv Data
    // 운동 정보 저장
    func exerciseDataSave() {
//        let widCal = Int(wdCal)
        let widExeCal = Int(wdExeCal)
        
        
        let exerciseName = UserDefaults.standard.string(forKey: "ExerciseName")!

//        let eCal = String(widExeCal)
//        let distance = String(format: "%.3f", wdistance)
        
        
//        print(workeCalValue.text as Any)
//        print(workStepValue.text as Any)
//        print(workdistanceValue.text as Any)

        
        let fileManager = FileManager.default
        
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentsURL.appendingPathComponent("exerciseData")
        
        if !fileManager.fileExists(atPath: directoryURL.path){            
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("fail to create directory")
            }
        }
        
        let fileURL = directoryURL.appendingPathComponent("/myExerciseData.csv")
        
        // 운동 이름, 시작 날짜, 시작 시간, 종료 시간, 평균 맥박, 걸음, 걸음거리, 활동칼로리, 최소bpm, 최대bpm
        guard let exerciseData = ("\(exerciseName),\(exerciseDate),\(exerciseStartTime),\(exerciseEndTime),\(tenMinutelVAvg),\(exerciseStep),\(exerciseDistance),\(exerciseECal), \(exerciseMinBpm),\(exerciseMaxBpm)\n").data(using: String.Encoding.utf8) else { return }
        
//        guard let exerciseData = ("\(exerciseName),2023-07-09,18:00:00,\(exerciseEndTime),\(tenMinutelVAvg),\(exerciseStep),\(exerciseDistance),\(exerciseECal), \(exerciseMinBpm),\(exerciseMaxBpm)\n").data(using: String.Encoding.utf8) else { return }
        
        // 파일이 있는 경우
        if fileManager.fileExists(atPath: fileURL.path){
            if let fileHandle = try? FileHandle(forWritingTo: fileURL){
                fileHandle.seekToEndOfFile() // 쓰기 위치를 마지막으로 설정
                fileHandle.write(exerciseData) // 쓰기
                fileHandle.closeFile() // 파일 닫기
            }
        }
        // 기존 파일이 없는 경우 실행
        else {
            let text = NSString(string: "\(exerciseName),\(exerciseDate),\(exerciseStartTime),\(exerciseEndTime),\(tenMinutelVAvg),\(exerciseStep),\(exerciseDistance),\(exerciseECal), \(exerciseMinBpm),\(exerciseMaxBpm)\n")
            do {
                try text.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8.rawValue)
                
            } catch let e {
                print(e.localizedDescription)
            }
        }
        
    } // exerciseDataSave()
    
    
    // 최근 일주일간의 운동 정보 저장
    func resentDataSave() {
//        let widCal = Int(wdCal)
        let widExeCal = Int(wdExeCal)
        
        let exerciseName = UserDefaults.standard.string(forKey: "ExerciseName")!
//        let tCal = String(widCal)
//        let eCal = String(widExeCal)
//        let distance = String(format: "%.3f", wdistance)
        
        
        let fileManager = FileManager.default
        
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentsURL.appendingPathComponent("exerciseData")
        
        if !fileManager.fileExists(atPath: directoryURL.path){
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("fail to create directory")
            }
        }
        
        let fileURL = directoryURL.appendingPathComponent("/resentData.csv")
        
        // 운동 이름, 시작 날짜, 시작 시간, 종료 시간, 평균 맥박, 걸음, 걸음거리, 활동칼로리, 최소bpm, 최대bpm
        guard let exerciseData = ("\(exerciseName),\(exerciseDate),\(exerciseStartTime),\(exerciseEndTime),\(tenMinutelVAvg),\(exerciseStep),\(exerciseDistance),\(exerciseECal),\(exerciseMinBpm),\(exerciseMaxBpm)\n").data(using: String.Encoding.utf8) else { return }
         // test
//        guard let exerciseData = ("\(exerciseName),2023-07-10,16:27:00,16:39:00,\(tenMinutelVAvg),\(exerciseStep),\(exerciseDistance),\(exerciseECal), \(exerciseMinBpm),\(exerciseMaxBpm)\n").data(using: String.Encoding.utf8) else { return }
        
        // 파일이 있는 경우
        if fileManager.fileExists(atPath: fileURL.path){
            if let fileHandle = try? FileHandle(forWritingTo: fileURL){
                fileHandle.seekToEndOfFile() // 쓰기 위치를 마지막으로 설정
                fileHandle.write(exerciseData) // 쓰기
                fileHandle.closeFile() // 파일 닫기
            }
        }
        // 기존 파일이 없는 경우 실행
        else {
            let text = NSString(string: "\(exerciseName),\(exerciseDate),\(exerciseStartTime),\(exerciseEndTime),\(tenMinutelVAvg),\(exerciseStep),\(exerciseDistance),\(exerciseECal), \(exerciseMinBpm),\(exerciseMaxBpm)\n")
            do {
                try text.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8.rawValue)
                
            } catch let e {
                print(e.localizedDescription)
            }
        }
        
    } // exerciseDataSave()
    
    // 시작, 종료 시간 저장
    func exerciseTimeSave(_ check: Bool){
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let time = dateFormatter.string(from: now)
        
        dateFormatter.dateFormat = "HH:mm:ss"
        let time2 = dateFormatter.string(from: now)
        
        // 시작 시간
        if check {
            exerciseDate = time
            exerciseStartTime = time2
        }
        // 종료 시간
        else{
            exerciseEndTime = time2
        }
    }
    
    // MARK: - constraints, view, navi
    func setup(){
        view.backgroundColor = .white
        addViews()
        setSafeAreaView()
    }
    
    func addViews(){
        view.addSubview(safeAreaView)
            
        view.addSubview(stopWatch)
        view.addSubview(workoutTimeBackground)
        view.addSubview(workoutTimeLabel)
        
        view.addSubview(chartView)
        
        view.addSubview(stackView)
        
        view.addSubview(bpmStackView)
        view.addSubview(averageBpmstackView)
        
        view.addSubview(stepStackView)
        view.addSubview(distanceStackView)

        view.addSubview(aCalStackView)
        view.addSubview(tCalStackView)
    }
    
    func Constraints(){
        
        
        workoutTimeBackground.translatesAutoresizingMaskIntoConstraints = false
        workoutTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        stopWatch.translatesAutoresizingMaskIntoConstraints = false
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        bpmStackView.translatesAutoresizingMaskIntoConstraints = false
        averageBpmstackView.translatesAutoresizingMaskIntoConstraints = false
        
        stepStackView.translatesAutoresizingMaskIntoConstraints = false
        distanceStackView.translatesAutoresizingMaskIntoConstraints = false
        
        aCalStackView.translatesAutoresizingMaskIntoConstraints = false
        tCalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            workoutTimeLabel.topAnchor.constraint(equalTo: workoutTimeBackground.topAnchor, constant: -10),
            workoutTimeLabel.centerXAnchor.constraint(equalTo: safeAreaView.centerXAnchor),
            
            stopWatch.topAnchor.constraint(equalTo: workoutTimeLabel.bottomAnchor, constant: 20),
            stopWatch.centerXAnchor.constraint(equalTo: workoutTimeLabel.centerXAnchor),
            
            workoutTimeBackground.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 10),
            workoutTimeBackground.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor, constant:  50),
            workoutTimeBackground.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -50),
            workoutTimeBackground.heightAnchor.constraint(equalToConstant: 70),
            
//            workoutTimeBackground.topAnchor.constraint(equalTo: workoutTimeLabel.topAnchor, constant: -10),
//            workoutTimeBackground.leadingAnchor.constraint(equalTo: workoutTimeLabel.leadingAnchor, constant:  -20),
//            workoutTimeBackground.trailingAnchor.constraint(equalTo: workoutTimeLabel.trailingAnchor, constant: 20),
////            workoutTimeBackground.bottomAnchor.constraint(equalTo: stopWatch.bottomAnchor, constant: 10),
//            workoutTimeBackground.heightAnchor.constraint(equalToConstant: 70),
            
            chartView.topAnchor.constraint(equalTo: workoutTimeBackground.bottomAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            chartView.heightAnchor.constraint(equalToConstant: 180),
            
            stackView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor, constant: 0),
            
            bpmStackView.topAnchor.constraint(equalTo: bpmBackground.topAnchor),
            bpmStackView.leadingAnchor.constraint(equalTo: bpmBackground.leadingAnchor),
            bpmStackView.trailingAnchor.constraint(equalTo: bpmBackground.centerXAnchor, constant: 10),
            bpmStackView.bottomAnchor.constraint(equalTo: bpmBackground.bottomAnchor),

            averageBpmstackView.topAnchor.constraint(equalTo: bpmBackground.topAnchor),
            averageBpmstackView.leadingAnchor.constraint(equalTo: bpmBackground.centerXAnchor, constant: -10),
            averageBpmstackView.trailingAnchor.constraint(equalTo: bpmBackground.trailingAnchor),
            averageBpmstackView.bottomAnchor.constraint(equalTo: bpmBackground.bottomAnchor),

            // step
            stepStackView.topAnchor.constraint(equalTo: stepAndDistanceBackground.topAnchor),
            stepStackView.leadingAnchor.constraint(equalTo: stepAndDistanceBackground.leadingAnchor),
            stepStackView.trailingAnchor.constraint(equalTo: stepAndDistanceBackground.centerXAnchor, constant: 10),
            stepStackView.bottomAnchor.constraint(equalTo: stepAndDistanceBackground.bottomAnchor),
            
            // distance
            distanceStackView.topAnchor.constraint(equalTo: stepAndDistanceBackground.topAnchor),
            distanceStackView.leadingAnchor.constraint(equalTo: stepAndDistanceBackground.centerXAnchor),
            distanceStackView.trailingAnchor.constraint(equalTo: stepAndDistanceBackground.trailingAnchor, constant: -10),
            distanceStackView.bottomAnchor.constraint(equalTo: stepAndDistanceBackground.bottomAnchor),

            // aCal
            aCalStackView.topAnchor.constraint(equalTo: calBackground.topAnchor),
            aCalStackView.leadingAnchor.constraint(equalTo: calBackground.leadingAnchor),
            aCalStackView.trailingAnchor.constraint(equalTo: calBackground.centerXAnchor, constant: 10),
            aCalStackView.bottomAnchor.constraint(equalTo: calBackground.bottomAnchor),
            // tCal
            tCalStackView.topAnchor.constraint(equalTo: calBackground.topAnchor),
            tCalStackView.leadingAnchor.constraint(equalTo: calBackground.centerXAnchor),
            tCalStackView.trailingAnchor.constraint(equalTo: calBackground.trailingAnchor, constant: -10),
            tCalStackView.bottomAnchor.constraint(equalTo: calBackground.bottomAnchor),
        ])
    }
    
    
    // navigation 설정
    func setNavigation() {
        self.navigationItem.title = UserDefaults.standard.string(forKey: "ExerciseName")
        
        let backButton = UIBarButtonItem(image: arrowImage, style: .plain, target: self, action: #selector(backButtonTapped))
        
        // 네비게이션 바 왼쪽에 백버튼 설정
        navigationItem.leftBarButtonItem = backButton
        
        let image = UIImage(systemName: "stop.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .light))?.withTintColor(.red, renderingMode: .alwaysOriginal)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(workoutReset))
        
        navigationItem.rightBarButtonItem = button
        
        //Programatically
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica Bold", size: 25)!]
        
    }
    
    @objc func backButtonTapped() {
        
        // 운동을 하지 않음
        if startStopFlag == true {
            defaults.set(false, forKey: "exerciseTarchycardiaFlag")
            navigationController?.popViewController(animated: true)
        }
        else {
            let alert = UIAlertController(title: "알림", message: "운동을 기록하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
            let save = UIAlertAction(title: "저장하기", style: .destructive, handler: { [self] Action in
                
                initialWorkoutReset()
                if let items = tabBarController?.tabBar.items {
                    items[3].isEnabled = true
                }
                defaults.set(false, forKey: "exerciseTarchycardiaFlag")
                
                exerciseTimeSave(false)
                exerciseDataSave()
                resentDataSave()
                
                navigationController?.popViewController(animated: true)
                
            })
            let exerciseContinue = UIAlertAction(title: "계속하기", style: .destructive, handler: nil)
            
            let cancel = UIAlertAction(title: "뒤로가기", style: UIAlertAction.Style.cancel, handler: { [self] Action in
                
                initialWorkoutReset()
                if let items = tabBarController?.tabBar.items {
                    items[3].isEnabled = true
                }
                defaults.set(false, forKey: "exerciseTarchycardiaFlag")
                
                exerciseTimeSave(false)
                resentDataSave()
                
                navigationController?.popViewController(animated: true)
            })
            
            alert.addAction(cancel)
            alert.addAction(exerciseContinue)
            alert.addAction(save)
            self.present(alert, animated: false)
        }
    }
    
    // safeAreaView 설정
    func setSafeAreaView(){
        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                safeAreaView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                guide.bottomAnchor.constraint(equalToSystemSpacingBelow: safeAreaView.bottomAnchor, multiplier: 1.0),
                safeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                safeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                safeAreaView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                bottomLayoutGuide.topAnchor.constraint(equalTo: safeAreaView.bottomAnchor, constant: standardSpacing),
                safeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                safeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }
    
}
