import UIKit
import SnapKit
import CoreBluetooth
import DGCharts
import Then
import Foundation
import AVFoundation
import CoreLocation
import UserNotifications
import AVFoundation

// MARK: - date/time var
var currentDate:String = ""
var currentYear:String = ""
var currentMonth:String = ""
var currentDay:String = ""
var currentHour:Int = 0
var currentTime:String = ""
var targetDate:String = ""
var isHomeFlag:Bool = false

struct PathData {
    var pathYear: Int
    var pathMonth: Int
    var pathDay: Int
    var rawValue: String
}

class MainViewController: BaseViewController, CLLocationManagerDelegate{
    
    private let STATE_CAUT = true
    private let STATE_WARN = false
    
    private let BPM_GRAPH_MAX = 250
    private let ARR_BUTTON_TAG = 1
    private let CAL_BUTTON_TAG = 2
    private let STEP_BUTTON_TAG = 3
    private let TEMP_BUTTON_TAG = 4
    private let DISTANCE_BUTTON_TAG = 5
    
    private let BPMDATA_FILENAME = "/BpmData.csv"
    private let HOURLYDATA_FILENAME = "/calandDistanceData.csv"
    
    private var calendar = Calendar.current
    
    // notification
    private var hourCheck = ""
    // bodyState
    private lazy var bodyButtonList:[UIButton] = [restButton, activityButton, sleepButton]
    
    // MARK: - UserData
    private var email = ""
    private var activityBPM = 0
    private var bedTime = 0
    private var wakeUpTime = 0
    private var joinDate = ""
    
    // MARK: - Timer
    private let dateFormatter = DateFormatter()
    private let nextDateFormatter = DateFormatter()
    private var dateTimeString: String = ""
    private var splitDateTime: [Substring] = []
    private var splitDate: [Substring] = []
    
    
    // MARK: - Server TasK
    private var dataLoadFailFlag = false
    private var previousYear = 0
    private var previousMonth = 0
    private var previousDay = 0
    
    // MARK: - Dir & File path
    private var appendingPath = ""
    private let fileManager:FileManager = FileManager.default
    private lazy var documentsURL: URL = {
        return MainViewController.initializeDocumentsURL()
    }()
    
    private var currentDirectoryURL: URL {
        return documentsURL.appendingPathComponent(appendingPath)
    }
    
    private var bpmDataFileURL: URL {
        return currentDirectoryURL.appendingPathComponent(BPMDATA_FILENAME)
    }
    
    private var hourlyDataFileURL: URL {
        return currentDirectoryURL.appendingPathComponent(HOURLYDATA_FILENAME)
    }
    
    // MARK: - ARR
    private var arrCnt: Int = 0
    private var arrListCnt: Int = 0
    private var yesterdayArrCnt: Int = 0
    private var previousArrCnt: Int = 0     // hourly Arr Cnt
    private var emergencyFirstFlag: Bool = false
    private var emergencyList:[String] = []
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // MARK: - chart
    private var bpmLastLines: [Double] = []
    private lazy var chartView: LineChartView =  {
        let chartView = LineChartView()
        chartView.noDataText = ""
        chartView.xAxis.enabled = false
        chartView.legend.font = UIFont.boldSystemFont(ofSize: 15)
        chartView.setVisibleXRangeMaximum(500)
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.chartDescription.enabled = false
        chartView.leftAxis.axisMaximum = 200
        chartView.leftAxis.axisMinimum = 40
        chartView.rightAxis.enabled = false
        chartView.drawMarkers = false
        chartView.dragEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerDragEnabled = false
        chartView.legend.enabled = false
        chartView.isUserInteractionEnabled = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        return chartView
    }()
    
    // MARK: - Top var
    private let heartBackground: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.layer.borderColor = UIColor.MY_BLUE.cgColor
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 10
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let heartImg: UIImageView = {
        var imageView = UIImageView()
        let image =  UIImage(named: "summary_bpm")!
        let coloredImage = image.withRenderingMode(.alwaysTemplate)
        
        imageView.image = coloredImage
        imageView.tintColor = UIColor.MY_BLUE
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let bpmValue: UILabel = {
        let label = UILabel()
        
        label.text = "0"
        label.textColor = UIColor.MY_BLUE
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrBackground: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.layer.borderColor = UIColor.MY_RED.cgColor
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 10
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrImg: UIImageView = {
        var imageView = UIImageView()
        let image =  UIImage(named: "summary_arr")!
        let coloredImage = image.withRenderingMode(.alwaysTemplate)
                
        imageView.image = coloredImage
        imageView.tintColor = UIColor.MY_RED
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var arrHeartImg: UIImageView = {
        var imageView = UIImageView()
        let symbolConfig = UIImage.SymbolConfiguration(weight: .light) // 두께 설정
        let symbolImage = UIImage(systemName: "heart", withConfiguration: symbolConfig)
        let coloredImage = symbolImage!.withRenderingMode(.alwaysTemplate)
                
        imageView.image = coloredImage
        imageView.tintColor = UIColor.MY_GREEN_BORDER
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
    
        return imageView
    }()
    
    private var arrHeartFillImg: UIImageView = {
        var imageView = UIImageView()
        let symbolConfig = UIImage.SymbolConfiguration(weight: .light) // 두께 설정
        let symbolImage = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)
        let coloredImage = symbolImage!.withRenderingMode(.alwaysTemplate)
        
        imageView.image = coloredImage
        imageView.tintColor = UIColor.MY_GREEN
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private var arrState: UILabel = {
        let label = UILabel()
        label.text = "arrStatusGood".localized()
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = UIColor.MY_GREEN_TEXT
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let yesterdayImgBackground: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let yesterdayContentsBackground: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var yesterdayArrCntLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor.MY_RED
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let yesterdayEventUnitLabel: UILabel = {
        let label = UILabel()
        label.text = "time".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var yesterdayComparisonQualifierLabel: UILabel = {
        let label = UILabel()
        label.text = "lessArr".localized()
        label.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        label.textColor = UIColor.MY_BLUE
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var basedOnYesterday: UILabel = {
        let label = UILabel()
        label.text = "basedOn".localized()
        label.font = UIFont.systemFont(ofSize: 8, weight: .heavy)
        label.textColor = UIColor.MY_RED
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topViewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var arrButton: UIButton = {
        
        let button = UIButton()
       
        button.setTitle("arr".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 10
        
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        
        button.tag = ARR_BUTTON_TAG
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
   }()
    
    private var arrValue = UILabel().then {
        $0.text = "0"
        $0.textColor = .white
        $0.baselineAdjustment = .alignCenters
        $0.font = .boldSystemFont(ofSize: 16)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let arrTimeLabel = UILabel().then {
        $0.text = "time".localized()
        $0.textColor = .white
        $0.baselineAdjustment = .alignCenters
        $0.font = .boldSystemFont(ofSize: 14)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    // MARK: - BodyStatus var
    private lazy var restButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("rest".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(named: "state_rest"), for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = UIColor.MY_BODY_STATE
        button.layer.borderColor = UIColor.MY_LIGHT_GRAY_BORDER.cgColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 5
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.isEnabled = false
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(bodyStateEvent(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var activityButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("exercise".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.setImage(UIImage(named: "state_activity"), for: .normal)
        button.tintColor = .lightGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = UIColor.MY_LIGHT_GRAY_BORDER
        button.layer.borderColor = UIColor.MY_LIGHT_GRAY_BORDER.cgColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 5
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.isEnabled = false
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(bodyStateEvent(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
   }()
    
    private lazy var sleepButton: UIButton = {
        let button = UIButton()
       
        button.setTitle("sleep".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.setImage(UIImage(named: "state_sleep"), for: .normal)
        button.tintColor = .lightGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = UIColor.MY_LIGHT_GRAY_BORDER
        button.layer.borderColor = UIColor.MY_LIGHT_GRAY_BORDER.cgColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 5
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.isEnabled = false
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(bodyStateEvent(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
   }()
    
    private let bodyStatusBackground: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.MY_LIGHT_GRAY_BORDER
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
   }()
    
    @objc func bodyStateEvent(_ sender: UIButton) {
        for button in bodyButtonList {
            if button == sender {
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0)
                button.tintColor = .white
                
            } else {
                button.setTitleColor(.lightGray, for: .normal)
                button.backgroundColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0)
                button.tintColor = .lightGray
            }
        }
    }
    
    
    // MARK: - Bottom var
    let calLabel: UILabel = {
        let label = UILabel()
        
        label.text = "eCal".localized()
        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let calValue: UILabel = {
        let label = UILabel()
        
        label.text = "eCalValue".localized()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let stepLabel: UILabel = {
        let label = UILabel()
        
        label.text = "step".localized()
        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let stepValue: UILabel = {
        let label = UILabel()
        
        label.text = "stepValue".localized()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let temperatureLabel: UILabel = {
        let label = UILabel()
        
        label.text = "temperature".localized()
        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let temperatureValue: UILabel = {
        let label = UILabel()
        
        label.text = "temperatureValue".localized()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let distanceLabel: UILabel = {
        let label = UILabel()
        
        label.text = "distance".localized()
        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let distanceValue: UILabel = {
        let label = UILabel()
        
        label.text = "distanceValue".localized()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var calButton: UIButton = {
        let button = UIButton()
        
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = CAL_BUTTON_TAG
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var stepButton: UIButton = {
        let button = UIButton()

        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = STEP_BUTTON_TAG
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var calAndStepStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calButton, stepButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually // default
        stackView.alignment = .fill // default
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var temperatureButton: UIButton = {
        let button = UIButton()

        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = TEMP_BUTTON_TAG
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var distanceButton: UIButton = {
        let button = UIButton()
        
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.tag = DISTANCE_BUTTON_TAG
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var temperatureAndDistanceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [temperatureButton, distanceButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually // default
        stackView.alignment = .fill // default
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calAndStepStackView, temperatureAndDistanceStackView])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually // default
        stackView.alignment = .fill // default
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initVar()
        addViews()
        updateDateTime()
        loadUserData()
    }
    
    // MARK: - initVar
    func initVar() {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        nextDateFormatter.dateFormat = "yyyy-MM-dd"
        nextDate(Date())    // UpdateDateTime
    }
    
    public static func initializeDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func createDir(_ url: URL){
        if !fileManager.fileExists(atPath: url.path){
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("fail to create directory")
            }
        }
    }
    
    // MARK: - Loop
    func startLoop(){
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(secondTimerAction), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(tenSecondTimerAction), userInfo: nil, repeats: true)
    }
    
    @objc func secondTimerAction() {
        responseRealBPM()
        updateDateTime()
    }
    
    @objc func tenSecondTimerAction() {
        let path = "\(email)/\(currentYear)/\(currentMonth)/\(currentDay)"
        
        responseBpmData(startDate: currentDate,
                        endDate: targetDate,
                        path: path)
        
        responseHourlyData(startDate: currentDate, 
                           endDate: targetDate,
                           path: path)
    }
    
    // MARK: - Update Date/Time
    func updateDateTime() {
        let now = Date()
        
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let hour = calendar.component(.hour, from: now)
        
        currentYear = String(year)
        currentMonth = String(month)
        currentDay = String(day)
        currentHour = hour
        
        currentDate = String(format: "%04d-%02d-%02d", year, month, day)
        
        if( currentDate == targetDate) {
            nextDate(now)   // 다음 시간 업데이트
            NotificationManager.shared.resetToalArray() // 알림 초기화
        }
    }
    
    func nextDate(_ now: Date) {
        if let date = Calendar.current.date(byAdding: .day, value: 1, to: now) {
            targetDate = nextDateFormatter.string(from: date)
        }
    }
    
    func prevDate(_ now: Date) -> String{
        if let date = Calendar.current.date(byAdding: .day, value: -1, to: now) {
            return nextDateFormatter.string(from: date)
        }
        return "false"
    }
    
    // MARK: - RealBPM
    func responseRealBPM() {
        NetworkManager.shared.getRealBpmToServer(id: email) { [self] result in
            switch(result){
            case .success(let bpm):
                
                bpmChart(bpm)
                bpmValue.text = bpm
                
                if let intBpm = Int(bpm) {
                    updateBodyState(bpm: intBpm)
                }
            case .failure(let error):
                print("responseRealBPM error : \(error)")
            }
        }
    }
    
    func bpmChart(_ myBpm: String) {
        guard let bpmValue = Double(myBpm) else {
            return
        }
        
        bpmLastLines.append(bpmValue)
        if bpmLastLines.count > BPM_GRAPH_MAX {
            bpmLastLines.removeFirst()
        }
        
        var entries: [ChartDataEntry] = []
        
        for i in 0..<bpmLastLines.count {
            entries.append(ChartDataEntry(x: Double(i), y: bpmLastLines[i]))
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: "BPM")
        dataSet.drawCirclesEnabled = false
        dataSet.colors = [NSUIColor.blue]
        dataSet.lineWidth = 1.0
        dataSet.drawValuesEnabled = false

        chartView.data = LineChartData(dataSet: dataSet)
        chartView.notifyDataSetChanged()
        chartView.moveViewToX(0)
        
        chartView.setNeedsDisplay()
    }
    
    // MARK: - BPM Data
    func responseBpmData(startDate: String, endDate: String, path: String) {
        NetworkManager.shared.getBpmDataToServer(id: email, startDate: startDate, endDate: endDate){ [self] result in
            switch(result){
            case .success(let data):
                appendingPath = path
                createDir(currentDirectoryURL)
                writeBpmData(data)
            case .failure(let error):
                print("responseBpmData error : \(error)")
            }
        }
        
    }
    
    func writeBpmData(_ data: [BpmData]) {
    
        var dataArray:[String] = []
        var temp = 0.0
        
        for bpmData in data {
            let splitWriteTime = bpmData.writetime.split(separator: " ")
            
            dataArray.append("\(splitWriteTime[1]),\(bpmData.timezone), \(bpmData.bpm), \(bpmData.temp), \(bpmData.hrv)")
            temp = Double(bpmData.temp)!
        }
        
        let finalDataString = dataArray.joined(separator: "\n") // 문자열  배열을 하나의 문자열로 조합
        
        // 최종 문자열을 Data 객체로 변환
        guard let writeData = finalDataString.data(using: .utf8) else {
            print("Error encoding string.")
            return
        }
        
        // 파일에 쓰기
        if fileManager.fileExists(atPath: bpmDataFileURL.path) {
            do {
                try writeData.write(to: bpmDataFileURL, options: .atomic)
            } catch let error {
                print("Error writing to file: \(error.localizedDescription)")
            }
        } else {
            fileManager.createFile(atPath: bpmDataFileURL.path, contents: writeData, attributes: nil)
        }
        
        updateTempUI(temp: temp)
    }
        
    // MARK: - Hourly Data
    func responseHourlyData(startDate: String, endDate: String, path: String) {
        NetworkManager.shared.getHourlyDataToServer(id: email, startDate: startDate, endDate: endDate){ [self] result in
            switch(result){
            case .success(let data):
                appendingPath = path
                createDir(currentDirectoryURL)
                writeHourlyData(data)
            case .failure(let error):
                print("responseBpmData error : \(error)")
            }
        }
    }
    
    func writeHourlyData(_ data: [HourlyData]) {
        
        var dataArray:[String] = []
        var sumStep = 0, sumDistance = 0, sumActivityCal = 0, sumArr = 0
        
        for hourlyData in data {
            dataArray.append("\(hourlyData.hour),\(hourlyData.timezone), \(hourlyData.step), \(hourlyData.distance), \(hourlyData.cal), \(hourlyData.activityCal), \(hourlyData.arrCnt)")
            
            sumStep += Int(hourlyData.step)!
            sumDistance += Int(hourlyData.distance)!
            sumActivityCal += Int(hourlyData.activityCal)!
            sumArr += Int(hourlyData.arrCnt)!
    
        }
        
        if hourCheck != data.last?.hour {
            NotificationManager.shared.resetHourlyArray() // Noti 초기화 (시간별 알림)
        }
        
        if let hourlyArrCntString = data.last?.arrCnt,
           let hourlyArrCnt = Int(hourlyArrCntString) {
            NotificationManager.shared.hourlyArrCntAlert(hourlyArrCnt)  // Hourly Noti
        }
        
        let finalDataString = dataArray.joined(separator: "\n") // 문자열  배열을 하나의 문자열로 조합
        
        // 최종 문자열을 Data 객체로 변환
        guard let writeData = finalDataString.data(using: .utf8) else {
            print("Error encoding string.")
            return
        }

        // 파일에 쓰기
        if fileManager.fileExists(atPath: hourlyDataFileURL.path) {
            do {
                try writeData.write(to: hourlyDataFileURL, options: .atomic)
            } catch let error {
                print("Error writing to file: \(error.localizedDescription)")
            }
        } else {
            fileManager.createFile(atPath: hourlyDataFileURL.path, contents: writeData, attributes: nil)
        }
        
        hourCheck = data.last?.hour ?? "0"
        updateHourlyUI(step: sumStep, distance: sumDistance, aCal: sumActivityCal)
    }
 
    
    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool, changeYear: inout Int, changeMonth: inout Int, changeDay: inout Int) -> String {
        guard let inputDate = nextDateFormatter.date(from: date) else { return "false" }

        let dayValue = shouldAdd ? day : -day
        if let arrTargetDate = calendar.date(byAdding: .day, value: dayValue, to: inputDate) {
            
            let components = calendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                changeYear = Int(year)
                changeMonth = Int(month)
                changeDay = Int(day)
                
                let monthAndDay = String(format: "%02d-%02d", changeMonth, changeDay)
                
                return "\(currentYear)-\(monthAndDay)"
            }
        }
        
        return "false"
    }
    
    // MARK: - load Previous Data
    func loadPreviousData(year: inout Int, month: inout Int, day: inout Int) {
        var previousDate = UserDefaults.standard.string(forKey: "\(email) previousDate") ?? joinDate
        previousDate = dateCalculate(previousDate, 0, true,
                                        changeYear: &year,
                                        changeMonth: &month,
                                        changeDay: &day)   // set Year, Month, Day
        
        while !(previousDate == currentDate) {
            let tomorrow = dateCalculate(previousDate, 1, true, changeYear: &year, changeMonth: &month, changeDay: &day)

            responseBpmData(startDate: previousDate, endDate: tomorrow, path: "\(email)/\(year)/\(month)/\(day)")

            responseHourlyData(startDate: previousDate, endDate: tomorrow, path: "\(email)/\(year)/\(month)/\(day)")

            previousDate = dateCalculate(previousDate, 1, true, changeYear: &year, changeMonth: &month, changeDay: &day)
        }
        UserDefaults.standard.set(previousDate, forKey: "\(email) previousDate")
    }
    
    // MARK: - find yesterday arr Cnt
    func findYesterdayArrCnt(){
        let yesterday = prevDate(Date())
        NetworkManager.shared.getArrListToServer(id: email, startDate: yesterday, endDate: currentDate){ [self] result in
            switch(result){
            case .success(let arrDateList):
                for arrDate in arrDateList {
                    if arrDate.address == nil || arrDate.address == "" { // ARR
                        yesterdayArrCnt += 1
                    }
                }
                updateArrUI(updateArrCnt: arrCnt)
            case .failure(let error):
                print("getArrList error : \(error)")
            }
        }
        
    }
    
    // MARK: - Emergency Attack
    func checkEmergency() {
        NetworkManager.shared.getArrListToServer(id: email, startDate: currentDate, endDate: targetDate) { [self] result in
            
            arrCnt = 0
            
            switch(result){
            case .success(let arrDateList):
                if arrListCnt != arrDateList.count {
                    
                    var emergencyFlag = true   // 알림 중복 방지
                    for arrDate in arrDateList {
                        if arrDate.address == nil || arrDate.address == "" {
                            arrCnt += 1 // ARR
                        } else {
                            if !emergencyList.contains(arrDate.writetime) {
                             
                                if emergencyFlag && emergencyFirstFlag {
                                    if let arrLastDate = arrDateList.last {
                                        NotificationManager.shared.emergencyAlert(
                                            occurrenceTime: arrLastDate.writetime,
                                            location: arrLastDate.address ?? "응급상황")
                                    }
                                    emergencyFlag = false
                                }
                                emergencyList.append(arrDate.writetime)
                            }
                        }
                    }
                    
                    if emergencyFirstFlag { NotificationManager.shared.totalArrCntAlert(arrCnt) } // 최초 실행 시 알림 방지
                    updateArrUI(updateArrCnt: arrCnt)
                    arrListCnt = arrDateList.count
                    emergencyFirstFlag = true
                }
                
            case .failure(let error):
                print("getArrList error : \(error)")
            }
        }
    }
        
    // MARK: - UpdateUI
    func updateHourlyUI(step: Int, distance: Int, aCal: Int){
        let distanceInKm = Double(distance) / 1000
        
        stepValue.text = String(step) + " " + "summaryStep".localized()
        distanceValue.text = String(format: "%.3f", distanceInKm) + " " + "distanceValue2".localized()
        calValue.text = String(aCal) + " " + "kcalValue".localized()
    }
    
    func updateTempUI(temp: Double) {
        temperatureValue.text = String(format: "%.1f", temp) + " " + "temperatureValue2".localized()
    }
    
    func updateBodyState(bpm: Int) {
        if currentHour >= bedTime || currentHour < wakeUpTime {
            bodyStateEvent(sleepButton) // sleep
        } else {
            if bpm >= activityBPM {
                bodyStateEvent(activityButton) // activity
            } else {
                bodyStateEvent(restButton)  // rest
            }
        }
    }
    
    func updateArrUI(updateArrCnt: Int) {
        arrValue.text = String(updateArrCnt)
        
        // setText
        if yesterdayArrCnt < updateArrCnt {
            yesterdayComparisonQualifierLabel.text = "moreArr".localized()
            yesterdayComparisonQualifierLabel.textColor = UIColor.MY_RED
            yesterdayArrCntLabel.text = String(updateArrCnt - yesterdayArrCnt)
        } else {
            yesterdayComparisonQualifierLabel.text = "lessArr".localized()
            yesterdayComparisonQualifierLabel.textColor = UIColor.MY_BLUE
            yesterdayArrCntLabel.text = String(yesterdayArrCnt - updateArrCnt)
        }
        
        // setIMG
        if updateArrCnt < 50 {
            fillHeart(fill: Double(updateArrCnt * 2) / 100)
        } else if updateArrCnt < 100 {
            fillHeart(fill: Double(updateArrCnt - 50) / 100)
            setArrColor(arrText: "arrStatusCaution".localized(),
                        arrState: &arrState,
                        arrHeart: &arrHeartImg,
                        arrFillHeart: &arrHeartFillImg,
                        stateFlag: STATE_CAUT)
        } else {    // updateArrCnt > 100
            fillHeart(fill: Double(updateArrCnt - 100) / 100)
            setArrColor(arrText: "arrStatusWarning".localized(),
                        arrState: &arrState,
                        arrHeart: &arrHeartImg,
                        arrFillHeart: &arrHeartFillImg,
                        stateFlag: STATE_WARN)
        }
    }
    
    func setArrColor(arrText: String, arrState: inout UILabel, arrHeart: inout UIImageView, arrFillHeart: inout UIImageView, stateFlag: Bool) {
        arrState.text = arrText
        arrState.textColor = stateFlag == STATE_CAUT ? UIColor.MY_BLUE : UIColor.MY_RED
        arrHeart.tintColor = stateFlag == STATE_CAUT ? UIColor.MY_BLUE_BORDER : UIColor.MY_RED_BORDER
        arrFillHeart.tintColor = stateFlag == STATE_CAUT ? UIColor.MY_SKY : UIColor.MY_PINK
    }
    
    func fillHeart(fill: Double) {
        let maskHeight = arrHeartFillImg.frame.height * fill // fill height 설정
        let maskY = arrHeartFillImg.frame.height - maskHeight // 시작 y 위치
        
        let maskLayer = CAShapeLayer()  // 마스크 레이어 생성 및 설정
        maskLayer.path = UIBezierPath(
            rect: CGRect(x: 0,
                         y: maskY,
                         width: arrHeartFillImg.frame.width,
                         height: maskHeight)).cgPath
        maskLayer.fillColor = UIColor.white.cgColor // 마스킹 색상
        
        arrHeartFillImg.layer.mask = maskLayer  // 적용
    }
    
    // MARK: - getProfile
    func loadUserData() {

        ToastHelper.shared.showToast(self.view, "loadUserData".localized(), withDuration: 2.0, delay: 2.0)
        
        NetworkManager.shared.getProfileToServer(id: Keychain.shared.getString(forKey: "email") ?? "test"){ [self] result in
            switch(result){
            case .success(let userProfile):
                let splitJoinDate = userProfile.signupdate.split(separator: " ")   // 2023-10-17 17:28:40
                
                email = userProfile.email
                activityBPM = userProfile.bpm
                bedTime = userProfile.sleeptime
                wakeUpTime = userProfile.uptime
                joinDate = String(splitJoinDate[0])
                
                createDir(currentDirectoryURL)
                startLoop()    // BPM, hourly DATA
                
                findYesterdayArrCnt()
                checkEmergency()
                
                loadPreviousData(year: &previousYear, month: &previousMonth, day: &previousDay)
                
                isHomeFlag = true
                         
            case .failure(let error):
                ToastHelper.shared.showToast(self.view, "failLoadUserData".localized(), withDuration: 2.0, delay: 2.0)
                print("An error occurred: \(error)")
            }
        }
    }
    
    //MARK: - layout
    func addViews(){
        
        view.addSubview(chartView)
        
        // --------------------------- Top Contents --------------------------- //
        
        view.addSubview(heartBackground)
        view.addSubview(heartImg)
        view.addSubview(bpmValue)
        
        view.addSubview(arrBackground)
        view.addSubview(arrImg)
        
        view.addSubview(yesterdayImgBackground)
        view.addSubview(arrHeartImg)
        view.addSubview(arrHeartFillImg)
        view.addSubview(arrState)
        
        view.addSubview(yesterdayContentsBackground)
        view.addSubview(yesterdayArrCntLabel)
        view.addSubview(yesterdayEventUnitLabel)
        view.addSubview(yesterdayComparisonQualifierLabel)
        view.addSubview(basedOnYesterday)
        
        view.addSubview(topViewLabel)
        view.addSubview(arrButton)
        view.addSubview(arrValue)
        view.addSubview(arrTimeLabel)
        view.addSubview(bodyStatusBackground)
        view.addSubview(restButton)
        view.addSubview(activityButton)
        view.addSubview(sleepButton)
        
        // --------------------------- Bottom Contents --------------------------- //
        
        view.addSubview(bottomStackView)
        view.addSubview(calLabel)
        view.addSubview(calValue)
        
        view.addSubview(stepLabel)
        view.addSubview(stepValue)
        
        view.addSubview(temperatureLabel)
        view.addSubview(temperatureValue)
        
        view.addSubview(distanceLabel)
        view.addSubview(distanceValue)
        
        setConstraints()
        setStateLocation()
        
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            
            // --------------------------- Top Contents --------------------------- //
            
            heartBackground.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 15),
            heartBackground.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor, constant: 15),
            heartBackground.trailingAnchor.constraint(equalTo: safeAreaView.centerXAnchor, constant: -10),
            heartBackground.heightAnchor.constraint(equalToConstant: 80),
            
            heartImg.centerXAnchor.constraint(equalTo: heartBackground.centerXAnchor),
            heartImg.topAnchor.constraint(equalTo: heartBackground.topAnchor, constant: -8),
            heartImg.widthAnchor.constraint(equalToConstant: 30),
   
            bpmValue.centerXAnchor.constraint(equalTo: heartBackground.centerXAnchor),
            bpmValue.centerYAnchor.constraint(equalTo: heartBackground.centerYAnchor),
            
            arrBackground.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 15),
            arrBackground.leadingAnchor.constraint(equalTo: safeAreaView.centerXAnchor, constant: 10),
            arrBackground.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -15),
            arrBackground.heightAnchor.constraint(equalToConstant: 80),
            
            arrImg.centerXAnchor.constraint(equalTo: arrBackground.centerXAnchor),
            arrImg.topAnchor.constraint(equalTo: arrBackground.topAnchor, constant: -8),
            arrImg.widthAnchor.constraint(equalToConstant: 30),
            
            // --------------------------- yesterday ARR IMG --------------------------- //
            yesterdayImgBackground.topAnchor.constraint(equalTo: arrBackground.topAnchor),
            yesterdayImgBackground.leadingAnchor.constraint(equalTo: arrBackground.leadingAnchor),
            yesterdayImgBackground.trailingAnchor.constraint(equalTo: arrBackground.centerXAnchor),
            yesterdayImgBackground.bottomAnchor.constraint(equalTo: arrBackground.bottomAnchor),
            
            arrHeartImg.topAnchor.constraint(equalTo: yesterdayImgBackground.topAnchor, constant: 5),
            arrHeartImg.leadingAnchor.constraint(equalTo: yesterdayImgBackground.leadingAnchor, constant: 5),
            arrHeartImg.trailingAnchor.constraint(equalTo: yesterdayImgBackground.trailingAnchor, constant: -5),
            arrHeartImg.bottomAnchor.constraint(equalTo: yesterdayImgBackground.bottomAnchor, constant: -5),
            
            arrHeartFillImg.topAnchor.constraint(equalTo: arrHeartImg.topAnchor, constant: 4),
            arrHeartFillImg.leadingAnchor.constraint(equalTo: arrHeartImg.leadingAnchor, constant: 2),
            arrHeartFillImg.trailingAnchor.constraint(equalTo: arrHeartImg.trailingAnchor, constant: -2),
            arrHeartFillImg.bottomAnchor.constraint(equalTo: arrHeartImg.bottomAnchor, constant: -5.5),
            
            arrState.centerXAnchor.constraint(equalTo: arrHeartImg.centerXAnchor),
            arrState.centerYAnchor.constraint(equalTo: arrHeartImg.centerYAnchor),
            
            // --------------------------- yesterday ARR Contents --------------------------- //
            
            yesterdayContentsBackground.topAnchor.constraint(equalTo: arrBackground.topAnchor),
            yesterdayContentsBackground.leadingAnchor.constraint(equalTo: arrBackground.centerXAnchor),
            yesterdayContentsBackground.trailingAnchor.constraint(equalTo: arrBackground.trailingAnchor),
            yesterdayContentsBackground.bottomAnchor.constraint(equalTo: arrBackground.bottomAnchor),
            
            yesterdayArrCntLabel.centerXAnchor.constraint(equalTo: yesterdayContentsBackground.centerXAnchor, constant: 0),
            yesterdayArrCntLabel.centerYAnchor.constraint(equalTo: yesterdayContentsBackground.centerYAnchor, constant: -10),

            yesterdayEventUnitLabel.leadingAnchor.constraint(equalTo: yesterdayArrCntLabel.trailingAnchor, constant: 0),
            yesterdayEventUnitLabel.bottomAnchor.constraint(equalTo: yesterdayArrCntLabel.bottomAnchor, constant: 0),
            
            yesterdayComparisonQualifierLabel.centerXAnchor.constraint(equalTo: yesterdayArrCntLabel.centerXAnchor, constant: 5),
            yesterdayComparisonQualifierLabel.centerYAnchor.constraint(equalTo: yesterdayContentsBackground.centerYAnchor, constant: 10),
            
            basedOnYesterday.topAnchor.constraint(equalTo: yesterdayContentsBackground.bottomAnchor, constant: 2),
            basedOnYesterday.trailingAnchor.constraint(equalTo: yesterdayContentsBackground.trailingAnchor, constant: -5),
            
            // --------------------------- ARR Time --------------------------- //
            topViewLabel.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 5),
            topViewLabel.leadingAnchor.constraint(equalTo: safeAreaView.centerXAnchor),
            topViewLabel.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -15),
            topViewLabel.heightAnchor.constraint(equalToConstant: 80),
                        
            arrButton.topAnchor.constraint(equalTo: topViewLabel.bottomAnchor, constant: 35),
            arrButton.leadingAnchor.constraint(equalTo: topViewLabel.leadingAnchor, constant: 10),
            arrButton.trailingAnchor.constraint(equalTo: topViewLabel.trailingAnchor),
            arrButton.heightAnchor.constraint(equalToConstant: 30),
        
            arrTimeLabel.centerYAnchor.constraint(equalTo: arrButton.centerYAnchor),
            arrTimeLabel.trailingAnchor.constraint(equalTo: arrButton.trailingAnchor, constant: -10),
            
            arrValue.trailingAnchor.constraint(equalTo: arrTimeLabel.leadingAnchor, constant: -10),
            arrValue.centerYAnchor.constraint(equalTo: arrButton.centerYAnchor),
            
            // --------------------------- bodyState --------------------------- //
            bodyStatusBackground.centerYAnchor.constraint(equalTo: arrButton.centerYAnchor),
            bodyStatusBackground.leadingAnchor.constraint(equalTo: heartBackground.leadingAnchor),
            bodyStatusBackground.trailingAnchor.constraint(equalTo: heartBackground.trailingAnchor),
            bodyStatusBackground.heightAnchor.constraint(equalToConstant: 30),

            // --------------------------- chart --------------------------- //
            chartView.topAnchor.constraint(equalTo: arrButton.bottomAnchor),
            chartView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            chartView.heightAnchor.constraint(equalTo: safeAreaView.heightAnchor, multiplier: 4.5 / (4.5 + 5.5)),
            
            
            // --------------------------- Bottom Contents --------------------------- //
            
            bottomStackView.topAnchor.constraint(equalTo: chartView.bottomAnchor),
            bottomStackView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor,constant: 15),
            bottomStackView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -15),
            bottomStackView.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor, constant: -15),
            
            calLabel.topAnchor.constraint(equalTo: calButton.topAnchor, constant: 10),
            calLabel.leadingAnchor.constraint(equalTo: calButton.leadingAnchor, constant: 10),
            
            calValue.trailingAnchor.constraint(equalTo: calButton.trailingAnchor, constant: -10),
            calValue.bottomAnchor.constraint(equalTo: calButton.bottomAnchor, constant: -10),
            
            
            stepLabel.topAnchor.constraint(equalTo: stepButton.topAnchor, constant: 10),
            stepLabel.leadingAnchor.constraint(equalTo: stepButton.leadingAnchor, constant: 10),
            
            stepValue.trailingAnchor.constraint(equalTo: stepButton.trailingAnchor, constant: -10),
            stepValue.bottomAnchor.constraint(equalTo: stepButton.bottomAnchor, constant: -10),
            
            temperatureLabel.topAnchor.constraint(equalTo: temperatureButton.topAnchor, constant: 10),
            temperatureLabel.leadingAnchor.constraint(equalTo: temperatureButton.leadingAnchor, constant: 10),
            
            temperatureValue.trailingAnchor.constraint(equalTo: temperatureButton.trailingAnchor, constant: -10),
            temperatureValue.bottomAnchor.constraint(equalTo: temperatureButton.bottomAnchor, constant: -10),
            
            distanceLabel.topAnchor.constraint(equalTo: distanceButton.topAnchor, constant: 10),
            distanceLabel.leadingAnchor.constraint(equalTo: distanceButton.leadingAnchor, constant: 10),
            
            distanceValue.trailingAnchor.constraint(equalTo: distanceButton.trailingAnchor, constant: -10),
            distanceValue.bottomAnchor.constraint(equalTo: distanceButton.bottomAnchor, constant: -10),
            
        ])
    }
    
    func setStateLocation(){
        let heartBackgroundWidth = heartBackground.widthAnchor
        
        NSLayoutConstraint.activate([
            restButton.centerYAnchor.constraint(equalTo: arrButton.centerYAnchor),
            restButton.leadingAnchor.constraint(equalTo: heartBackground.leadingAnchor),
            restButton.heightAnchor.constraint(equalToConstant: 30),
            restButton.widthAnchor.constraint(equalTo: heartBackgroundWidth, multiplier: 1.0 / 3.0),
            
            activityButton.centerYAnchor.constraint(equalTo: arrButton.centerYAnchor),
            activityButton.centerXAnchor.constraint(equalTo: heartBackground.centerXAnchor),
            activityButton.heightAnchor.constraint(equalToConstant: 30),
            activityButton.widthAnchor.constraint(equalTo: heartBackgroundWidth, multiplier: 1.0 / 3.0),
            
            sleepButton.centerYAnchor.constraint(equalTo: arrButton.centerYAnchor),
            sleepButton.trailingAnchor.constraint(equalTo: heartBackground.trailingAnchor),
            sleepButton.heightAnchor.constraint(equalToConstant: 30),
            sleepButton.widthAnchor.constraint(equalTo: heartBackgroundWidth, multiplier: 1.0 / 3.0),
        ])
    }
}
