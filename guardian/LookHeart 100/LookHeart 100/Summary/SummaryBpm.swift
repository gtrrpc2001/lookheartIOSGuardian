import UIKit
import Foundation
import DGCharts
import SnapKit
import Then

let leftArrow =  UIImage(systemName: "arrow.left.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .light))?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
let rightArrow =  UIImage(systemName: "arrow.right.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .light))?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)

class SummaryBpm : BaseViewController, Refreshable {
    
    private let BPMDATA_FILENAME = "/BpmData.csv"
    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let TODAY_FLAG = 1
    private let TWO_DAYS_FLAG = 2
    private let THREE_DAYS_FLAG = 3
    
    private var email = ""
    
    //    ----------------------------- Bpm Var -------------------    //
    private let dateFormatter = DateFormatter()
    
    private var minBpm = 70
    private var maxBpm = 0
    private var avgBpm = 0
    private var avgBpmSum = 0
    private var avgBpmCnt = 0
    
    private var currentFlag = 0
    
    private var targetDate:String = ""
    private var targetYear:String = ""
    private var targetMonth:String = ""
    private var targetDay:String = ""
    
    private var twoDaysTargetDate:String = ""
    private var twoDaysTargetYear:String = ""
    private var twoDaysTargetMonth:String = ""
    private var twoDaysTargetDay:String = ""
    
    private var threeDaysTargetDate:String = ""
    private var threeDaysTargetYear:String = ""
    private var threeDaysTargetMonth:String = ""
    private var threeDaysTargetDay:String = ""
    
    private var bpmCalendar = Calendar.current
    
    private var buttonList:[UIButton] = []

    private var startBpmTime = [String]()
    private var endBpmTime = [String]()
    
    private var earliestStartTime = ""
    private var latestEndTime = ""
    
    private var xAxisTotal = 0
    private var startBpmTimeInMinutes = 0
    private var endBpmTimeInMinutes = 0
    
    private var timeTable: [String] = []
    
    private var bpmTimeCount = 0
    private var timeTableCount = 0
    
    private var targetBpmData: [Double] = []
    private var targetBpmTimeData: [String] = []
    
    private var twoDaysBpmData: [Double] = []
    private var twoDaysBpmTimeData: [String] = []
        
    private var threeDaysBpmData: [Double] = []
    private var threeDaysBpmTimeData: [String] = []
    
    private var targetBpmEntries = [ChartDataEntry]()
    private var twoDaysBpmEntries = [ChartDataEntry]()
    private var threeDaysBpmEntries = [ChartDataEntry]()
    
    //    ----------------------------- csv Var -------------------    //
    private var fileManager:FileManager = FileManager.default
    private var appendingPath = ""
    
    private lazy var documentsURL: URL = {
        return SummaryBpm.initializeDocumentsURL()
    }()
    
    private var currentDirectoryURL: URL {
        return documentsURL.appendingPathComponent("\(appendingPath)")
    }
    
    private var bpmDataFileURL: URL {
        return currentDirectoryURL.appendingPathComponent(BPMDATA_FILENAME)
    }
    
    //    ----------------------------- Chart -------------------    //
    lazy var bpmChartView: LineChartView =  {
        let bpmChartView = LineChartView()
        bpmChartView.noDataText = ""
        bpmChartView.xAxis.enabled = true
        bpmChartView.legend.font = .systemFont(ofSize: 15, weight: .bold)
        bpmChartView.xAxis.granularity = 1
        bpmChartView.xAxis.labelPosition = .bottom
        bpmChartView.xAxis.drawGridLinesEnabled = false
        bpmChartView.rightAxis.enabled = false
        bpmChartView.drawMarkers = false
        bpmChartView.dragEnabled = true
        bpmChartView.pinchZoomEnabled = false
        bpmChartView.doubleTapToZoomEnabled = false
        bpmChartView.highlightPerTapEnabled = false
        bpmChartView.translatesAutoresizingMaskIntoConstraints = false
        return bpmChartView
    }()
    
    //    ----------------------------- UILabel -------------------    //
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topContents: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let middleContents: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bottomContents: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - top Contents
    lazy var todayButton = UIButton().then {
        $0.setTitle ("today".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0), for: .normal)
        $0.setBackgroundColor(UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0), for: .selected)
        $0.setBackgroundColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0), for: .disabled)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.isSelected = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    lazy var twoDaysButton = UIButton().then {
        $0.setTitle ("twoDays".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0), for: .normal)
        $0.setBackgroundColor(UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0), for: .selected)
        $0.setBackgroundColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0), for: .disabled)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    lazy var threeDaysButton = UIButton().then {
        $0.setTitle ("threeDays".localized(), for: .normal )
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        $0.setBackgroundColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0), for: .normal)
        $0.setBackgroundColor(UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0), for: .selected)
        $0.setBackgroundColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0), for: .disabled)
        
        $0.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    
    // MARK: - middle Contents
    private lazy var todayDispalay = UILabel().then {
        $0.text = "\(currentYear)-\(currentMonth)-\(currentDay)"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.baselineAdjustment = .alignCenters
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var yesterdayBpmButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private lazy var tomorrowBpmButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - bottom Contents
    private let leftBpmContents: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rightBpmContents: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let centerBpmContents: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let maxBpmLabel: UILabel = {
        let label = UILabel()
        label.text = "home_maxBpm".localized()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let maxBpmValue: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let diffMaxBpm: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let minBpmLabel: UILabel = {
        let label = UILabel()
        label.text = "home_minBpm".localized()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let minBpmValue: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let diffMinBpm: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let avgBpmLabel: UILabel = {
        let label = UILabel()
        label.text = "avgBPM".localized()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let avgBpmValue: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let bpmLabel: UILabel = {
        let label = UILabel()
        label.text = "fragment_bpm".localized()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Alert
    let alertBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.layer.borderWidth = 3
        label.layer.borderColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0).cgColor
        label.layer.cornerRadius = 20
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let alertLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.isHidden = true
        label.numberOfLines = 4
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        addViews()
        initArray()
        todayBpmChart()
    }
    
    func refreshView() {
        initVar()
        addViews()
        initArray()
        todayBpmChart()
    }
    
    func initVar(){
        email = UserProfileManager.shared.getEmail()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        currentFlag = TODAY_FLAG
        
        buttonList = [todayButton, twoDaysButton, threeDaysButton]
        
        targetDate = currentDate
        targetYear = currentYear
        targetMonth = currentMonth
        targetDay = currentDay
        
        setButtonColor(todayButton)
        setDays(targetDate)
    }
    
    // MARK: - CHART
    func todayBpmChart() {
        setDisplayText(changeDateFormat("\(targetYear)-\(targetMonth)-\(targetDay)", false))
        
        if fileExists() {
            
            getFileData(
                path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)",
                bpmData: &targetBpmData,
                timeData: &targetBpmTimeData)
            
            var bpmDataEntries = [ChartDataEntry]()
            
            for i in 0 ..< targetBpmData.count - 1 {
                let bpmDataEntry = ChartDataEntry(x: Double(i), y: targetBpmData[i])
                bpmDataEntries.append(bpmDataEntry)
            }
            
            // set ChartData
            let bpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: LineChartDataSet(entries: bpmDataEntries, label: "fragment_bpm".localized()))
            
            removeSecond(targetBpmTimeData)
            
            setChart(chartData: LineChartData(dataSet: bpmChartDataSet),
                     maximum: 500,
                     axisMaximum: 200,
                     axisMinimum: 40)
            
            setBpmText()
            
        } else {
            // 파일 없음
        }
    }

    func twoDaysBpmChart() {
            
        setDisplayText("\(changeDateFormat("\(twoDaysTargetMonth)-\(twoDaysTargetDay)", true)) ~ \(changeDateFormat("\(targetMonth)-\(targetDay)", true))")
        
        if fileExists() {
            
            // TODAY Data
            getFileData(
                path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)",
                bpmData: &targetBpmData,
                timeData: &targetBpmTimeData)
            
            // 2 DAYS Data
            getFileData(
                path: "\(email)/\(twoDaysTargetYear)/\(twoDaysTargetMonth)/\(twoDaysTargetDay)",
                bpmData: &twoDaysBpmData,
                timeData: &twoDaysBpmTimeData)
            
            // find start Time & end Time
            guard let startOfToday = targetBpmTimeData.first,
                  let endOfToday = targetBpmTimeData.last,
                  let startOfYesterday = twoDaysBpmTimeData.first,
                  let endOfYesterday = twoDaysBpmTimeData.last else {
                return
            }
            
            earliestStartTime = earlierTime(startOfToday, startOfYesterday)
            latestEndTime = earlierTime(endOfToday, endOfYesterday) == endOfToday ? endOfYesterday : endOfToday

            startBpmTime = earliestStartTime.components(separatedBy: ":")
            endBpmTime = latestEndTime.components(separatedBy: ":")

            // find difference Minutes
            startBpmTimeInMinutes = Int(startBpmTime[0])! * 60 + Int(startBpmTime[1])!
            endBpmTimeInMinutes = Int(endBpmTime[0])! * 60 + Int(endBpmTime[1])!

            xAxisTotal = (endBpmTimeInMinutes - startBpmTimeInMinutes) * 6
            
            // set timeTable
            setTimeTable(startBpmTime, false)

            // find start point
            var todayStart = findStartPoint(startOfToday.components(separatedBy: ":"))
            var twoDaysStart = findStartPoint(startOfYesterday.components(separatedBy: ":"))
            
            // last value
            let endOfTodayInt = timeToInt(endOfToday.components(separatedBy: ":"))
            let endOfYesterdayInt = timeToInt(endOfYesterday.components(separatedBy: ":"))
            
            // today's data
            processBpmData(timeData: targetBpmTimeData,
                           bpmData: targetBpmData,
                           endTimeInt: endOfTodayInt,
                           entries: &targetBpmEntries,
                           startIndex: &todayStart)

            bpmTimeCount = 0    // Reset bpmTimeCount for yesterday's data

            // yesterday's data
            processBpmData(timeData: twoDaysBpmTimeData,
                           bpmData: twoDaysBpmData,
                           endTimeInt: endOfYesterdayInt,
                           entries: &twoDaysBpmEntries,
                           startIndex: &twoDaysStart)
                            
            // remove second
            setTimeTable(startBpmTime, true)
            
            // set Chart
            let todaysDate = changeDateFormat("\(targetMonth)-\(targetDay)", true)
            let twoDaysDate = changeDateFormat("\(twoDaysTargetMonth)-\(twoDaysTargetDay)", true)
            
            let todayBpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: LineChartDataSet(entries: targetBpmEntries, label: todaysDate))
            let twoDaysBpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: LineChartDataSet(entries: twoDaysBpmEntries, label: twoDaysDate))
                                                                
            let bpmChartDataSets: [LineChartDataSet] = [twoDaysBpmChartDataSet, todayBpmChartDataSet]
            
            setChart(chartData: LineChartData(dataSets: bpmChartDataSets),
                     maximum: 1000,
                     axisMaximum: 200,
                     axisMinimum: 40)
            
            setBpmText()
            
        } else {
            // 파일 없음
        }
    }
    
    func threeDaysBpmChart() {
        
        setDisplayText("\(changeDateFormat("\(threeDaysTargetMonth)-\(threeDaysTargetDay)", true)) ~ \(changeDateFormat("\(targetMonth)-\(targetDay)", true))")
        
        if fileExists() {
            // Today Data
            getFileData(
                path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)",
                bpmData: &targetBpmData,
                timeData: &targetBpmTimeData)
            
            // 2 DAYS Data
            getFileData(
                path: "\(email)/\(twoDaysTargetYear)/\(twoDaysTargetMonth)/\(twoDaysTargetDay)",
                bpmData: &twoDaysBpmData,
                timeData: &twoDaysBpmTimeData)
            
            // 3 DAYS Data
            getFileData(
                path: "\(email)/\(threeDaysTargetYear)/\(threeDaysTargetMonth)/\(threeDaysTargetDay)",
                bpmData: &threeDaysBpmData,
                timeData: &threeDaysBpmTimeData)
            
            // find start Time & end Time
            guard let startOfToday = targetBpmTimeData.first,
                  let endOfToday = targetBpmTimeData.last,
                  let startOfYesterday = twoDaysBpmTimeData.first,
                  let endOfYesterday = twoDaysBpmTimeData.last,
                  let startOfTwoDaysAgo = threeDaysBpmTimeData.first,
                  let endOfTwoDaysAgo = threeDaysBpmTimeData.last else {
                return
            }
            
            var compareDates = earlierTime(startOfToday, startOfYesterday)
            earliestStartTime = earlierTime(compareDates, startOfTwoDaysAgo)
            
            compareDates = earlierTime(endOfToday, endOfYesterday) == endOfToday ? endOfYesterday : endOfToday
            latestEndTime = earlierTime(compareDates, endOfTwoDaysAgo) == compareDates ? endOfTwoDaysAgo : compareDates
            
            startBpmTime = earliestStartTime.components(separatedBy: ":")
            endBpmTime = latestEndTime.components(separatedBy: ":")
            
            // find difference Minutes
            startBpmTimeInMinutes = Int(startBpmTime[0])! * 60 + Int(startBpmTime[1])!
            endBpmTimeInMinutes = Int(endBpmTime[0])! * 60 + Int(endBpmTime[1])!
            
            xAxisTotal = (endBpmTimeInMinutes - startBpmTimeInMinutes) * 6
            
            // set timeTable
            setTimeTable(startBpmTime, false)
            
            // find start point
            var todayStart = findStartPoint(startOfToday.components(separatedBy: ":"))
            var twoDaysStart = findStartPoint(startOfYesterday.components(separatedBy: ":"))
            var threeDaysStart = findStartPoint(startOfTwoDaysAgo.components(separatedBy: ":"))
            
            // last value
            let endOfTodayInt = timeToInt(endOfToday.components(separatedBy: ":"))
            let endOfYesterdayInt = timeToInt(endOfYesterday.components(separatedBy: ":"))
            let endOfTwoDaysAgoInt = timeToInt(endOfTwoDaysAgo.components(separatedBy: ":"))
            
            // today's data
            processBpmData(timeData: targetBpmTimeData,
                           bpmData: targetBpmData,
                           endTimeInt: endOfTodayInt,
                           entries: &targetBpmEntries,
                           startIndex: &todayStart)
            
            bpmTimeCount = 0    // Reset bpmTimeCount for yesterday's data
            
            // yesterday's data
            processBpmData(timeData: twoDaysBpmTimeData,
                           bpmData: twoDaysBpmData,
                           endTimeInt: endOfYesterdayInt,
                           entries: &twoDaysBpmEntries,
                           startIndex: &twoDaysStart)
            
            bpmTimeCount = 0
            
            // twoDaysAgo's data
            processBpmData(timeData: threeDaysBpmTimeData,
                           bpmData: threeDaysBpmData,
                           endTimeInt: endOfTwoDaysAgoInt,
                           entries: &threeDaysBpmEntries,
                           startIndex: &threeDaysStart)
            
            // remove second
            setTimeTable(startBpmTime, true)
            
            // set Chart
            let todaysDate = changeDateFormat("\(targetMonth)-\(targetDay)", true)
            let twoDaysDate = changeDateFormat("\(twoDaysTargetMonth)-\(twoDaysTargetDay)", true)
            let threeDaysDate = changeDateFormat("\(threeDaysTargetMonth)-\(threeDaysTargetDay)", true)
            
            let todayBpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: LineChartDataSet(entries: targetBpmEntries, label: todaysDate))
            let twoDaysBpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: LineChartDataSet(entries: twoDaysBpmEntries, label: twoDaysDate))
            let threeDaysBpmChartDataSet = chartDataSet(color: NSUIColor.GRAPH_GREEN, chartDataSet: LineChartDataSet(entries: threeDaysBpmEntries, label: threeDaysDate))
            
            let bpmChartDataSets: [LineChartDataSet] = [threeDaysBpmChartDataSet, twoDaysBpmChartDataSet, todayBpmChartDataSet]
            
            setChart(chartData: LineChartData(dataSets: bpmChartDataSets),
                     maximum: 1000,
                     axisMaximum: 200,
                     axisMinimum: 40)
            
            setBpmText()
            
        } else {
            // 파일 없음
        }
    }
    
    // MARK: - CHART FUNC
    func getFileData(path: String, bpmData: inout [Double], timeData: inout [String]) {

        do {
            appendingPath = path
            let fileData = try String(contentsOf: bpmDataFileURL)
            let separatedData = fileData.components(separatedBy: .newlines)
            
            for i in 0 ..< separatedData.count - 1 {
                let row = separatedData[i]
                let columns = row.components(separatedBy: ",")
                let bpm = Double(columns[2].trimmingCharacters(in: .whitespacesAndNewlines))
                
                let time = columns[0].components(separatedBy: ":")
                let bpmTime = time[0] + ":" + time[1] + ":" + (time[safe: 2] ?? "00")
                
                calcMinMax(Int(bpm ?? 70))
                bpmData.append(bpm ?? 0.0)
                timeData.append(bpmTime)
            }
        } catch  {
            print("Error reading CSV file")
        }
    }
    
    func setTimeTable(_ startBpmTime: [String], _ removeSecond: Bool){
        if removeSecond {   timeTable = []  }
        
        var bpmHour = Int(startBpmTime[0]) ?? 0
        var bpmMinutes = Int(startBpmTime[1]) ?? 0
        var seconds = 0
        
        for _ in 0 ..< xAxisTotal {
            var time = ""
            if removeSecond {
                time = String(format: "%02d:%02d", bpmHour, bpmMinutes)
            } else {
                time = String(format: "%02d:%02d:%d", bpmHour, bpmMinutes, seconds)
            }
            timeTable.append(time)
            seconds = (seconds + 1) % 6
            
            if seconds == 0 {
                incrementTime(hour: &bpmHour, minute: &bpmMinutes)
            }
        }
    }
    
    func removeSecond(_ startTime: [String]) {
        for time in startTime {
            let splitTime = time.split(separator: ":")
            timeTable.append("\(splitTime[0]):\(splitTime[1])")
        }
    }
    
    func incrementTime(hour: inout Int, minute: inout Int) {
        minute += 1
        if minute == 60 {
            hour += 1
            minute = 0
        }
    }
    
    func findStartPoint(_ startTime: [String]) -> Int {
        let startTimeInMinutes = Int(startTime[0])! * 60 + Int(startTime[1])!
        return (startTimeInMinutes - startBpmTimeInMinutes) * 6
    }
    
    func earlierTime(_ todayTime: String, _ yesterdayTime: String) -> String {
        let todayComponents = todayTime.components(separatedBy: ":")
        let yesterdayComponents = yesterdayTime.components(separatedBy: ":")

        let todayHour = Int(todayComponents[0])!
        let yesterdayHour = Int(yesterdayComponents[0])!
        let todayMinute = Int(todayComponents[1])!
        let yesterdayMinute = Int(yesterdayComponents[1])!

        if todayHour < yesterdayHour || (todayHour == yesterdayHour && todayMinute < yesterdayMinute) {
            return todayTime
        } else {
            return yesterdayTime
        }
    }
    
    func timeToInt(_ time: [String]) -> Int {
        let hour = Int(time[0]) ?? 0
        let minute = Int(time[1]) ?? 0
        let second = time[2].count == 2 ? Int(String(time[2].first!)) ?? 0 : Int(time[2]) ?? 0
        return hour * 3600 + minute * 60 + second
    }
    
    func processBpmData(timeData: [String], bpmData: [Double], endTimeInt: Int, entries: inout [ChartDataEntry], startIndex: inout Int) {
        var bpmTimeCount = 0
        for _ in 0 ..< xAxisTotal {
            if bpmTimeCount >= timeData.count || startIndex >= timeTable.count { break }
            
            var bpmTime = timeToInt(timeData[bpmTimeCount].components(separatedBy: ":"))
            let timePoint = timeToInt(timeTable[startIndex].components(separatedBy: ":"))
            
            if bpmTime == endTimeInt { break }
            
            if bpmTime == timePoint {
                entries.append(ChartDataEntry(x: Double(startIndex), y: bpmData[bpmTimeCount]))
                bpmTimeCount += 1
            } else if bpmTime < timePoint {
                entries.append(ChartDataEntry(x: Double(startIndex), y: bpmData[max(bpmTimeCount - 1, 0)]))
            }
            
            while bpmTimeCount < timeData.count && bpmTime == timePoint && bpmTime != endTimeInt {
                entries.append(ChartDataEntry(x: Double(startIndex), y: bpmData[bpmTimeCount]))
                bpmTimeCount += 1
                if bpmTimeCount < timeData.count {
                    bpmTime = timeToInt(timeData[bpmTimeCount].components(separatedBy: ":"))
                }
            }
            
            startIndex += 1
        }
    }
    
    func chartDataSet(color: NSUIColor, chartDataSet: LineChartDataSet) -> LineChartDataSet {
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(color)
        chartDataSet.mode = .linear
        chartDataSet.lineWidth = 0.7
        chartDataSet.drawValuesEnabled = true
        
        return chartDataSet
    }
    
    func setChart(chartData: LineChartData, maximum: Double, axisMaximum: Double, axisMinimum: Double) {
        bpmChartView.data = chartData
        bpmChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
        bpmChartView.setVisibleXRangeMaximum(maximum)
        bpmChartView.leftAxis.axisMaximum = axisMaximum
        bpmChartView.leftAxis.axisMinimum = axisMinimum
        bpmChartView.data?.notifyDataChanged()
        bpmChartView.notifyDataSetChanged()
        bpmChartView.moveViewToX(0)
    }
    
    func changeDateFormat(_ dateString: String, _ checkDate: Bool) -> String {
        var dateComponents = dateString.components(separatedBy: "-")
        
        if checkDate {
            dateComponents[0] = String(format: "%02d", Int(dateComponents[0])!)
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
        } else {
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            dateComponents[2] = String(format: "%02d", Int(dateComponents[2])!)
        }

        return dateComponents.joined(separator: "-")
    }
    
    // MARK: -
    @objc func shiftDate(_ sender: UIButton) {
        
        switch(sender.tag) {
        case YESTERDAY_BUTTON_FLAG:
            dateCalculate(targetDate, 1, false)
        default:    // TOMORROW_BUTTON_FLAG
            dateCalculate(targetDate, 1, true)
        }
        
        viewChart(currentFlag)
    }
    
    @objc func selectDayButton(_ sender: UIButton) {
        switch(sender.tag) {
        case TWO_DAYS_FLAG:
            currentFlag = TWO_DAYS_FLAG
        case THREE_DAYS_FLAG:
            currentFlag = THREE_DAYS_FLAG
        default:
            currentFlag = TODAY_FLAG
        }
        
        viewChart(currentFlag)
        setButtonColor(sender)
    }
     
    func viewChart(_ tag: Int) {
        
        initArray()
        
        switch(tag) {
        case TWO_DAYS_FLAG:
            twoDaysBpmChart()
        case THREE_DAYS_FLAG:
            threeDaysBpmChart()
        default:
            todayBpmChart()
        }
    }
    
    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool) {
        guard let inputDate = dateFormatter.date(from: date) else { return }

        let dayValue = shouldAdd ? day : -day
        if let arrTargetDate = bpmCalendar.date(byAdding: .day, value: dayValue, to: inputDate) {
            
            let components = bpmCalendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                targetYear = "\(year)"
                targetMonth = "\(month)"
                targetDay = "\(day)"
                
                targetDate = "\(targetYear)-\(targetMonth)-\(targetDay)"
                
                setDays(targetDate) // set twoDays, threeDays
            }
        }
    }
    
    func setDays(_ date: String) {
        guard let inputDate = dateFormatter.date(from: date) else { return }
        
        // twoDays
        if let arrTargetDate = bpmCalendar.date(byAdding: .day, value: -1, to: inputDate) {
            
            let components = bpmCalendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                twoDaysTargetYear = "\(year)"
                twoDaysTargetMonth = "\(month)"
                twoDaysTargetDay = "\(day)"
                
                twoDaysTargetDate = "\(twoDaysTargetYear)-\(twoDaysTargetMonth)-\(twoDaysTargetDay)"
            }
        }
        // threeDays
        if let arrTargetDate = bpmCalendar.date(byAdding: .day, value: -2, to: inputDate) {
            
            let components = bpmCalendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                threeDaysTargetYear = "\(year)"
                threeDaysTargetMonth = "\(month)"
                threeDaysTargetDay = "\(day)"
                
                threeDaysTargetDate = "\(threeDaysTargetYear)-\(threeDaysTargetMonth)-\(threeDaysTargetDay)"
            }
        }
        
//        print("today : \(targetDate)")
//        print("twodays : \(twoDaysTargetDate)")
//        print("threedays : \(threeDaysTargetDate)")
    }
    
    func setDisplayText(_ dateText: String) {
        todayDispalay.text = dateText
    }
    
    func pathForDate(year: String, month: String, day: String) -> String {
        return "\(email)/\(year)/\(month)/\(day)"
    }

    func fileExistsAtPath(_ path: String) -> Bool {
        appendingPath = path
        return fileManager.fileExists(atPath: bpmDataFileURL.path)
    }

    func fileExists() -> Bool {
        let paths: [String]
        
        switch currentFlag {
        case TWO_DAYS_FLAG:
            paths = [
                pathForDate(year: targetYear, month: targetMonth, day: targetDay),
                pathForDate(year: twoDaysTargetYear, month: twoDaysTargetMonth, day: twoDaysTargetDay)
            ]
        case THREE_DAYS_FLAG:
            paths = [
                pathForDate(year: targetYear, month: targetMonth, day: targetDay),
                pathForDate(year: twoDaysTargetYear, month: twoDaysTargetMonth, day: twoDaysTargetDay),
                pathForDate(year: threeDaysTargetYear, month: threeDaysTargetMonth, day: threeDaysTargetDay)
            ]
        default:
            paths = [pathForDate(year: targetYear, month: targetMonth, day: targetDay)]
        }
        
        for path in paths {
            if !fileExistsAtPath(path) {
                return false
            }
        }
        
        return true
    }
    
    func setBpmText() {
        maxBpmValue.text = String(maxBpm)
        minBpmValue.text = String(minBpm)
        avgBpmValue.text = String(avgBpm)
        diffMinBpm.text = "-\(avgBpm - minBpm)"
        diffMaxBpm.text = "+\(maxBpm - avgBpm)"
    }
    
    func setButtonColor(_ sender: UIButton) {
        for button in buttonList {
            if button == sender {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
    
    func calcMinMax(_ bpm: Int) {
        if (bpm != 0){
            if (minBpm > bpm){
                minBpm = bpm
            }
            if (maxBpm < bpm){
                maxBpm = bpm
            }

            avgBpmSum += bpm
            avgBpmCnt += 1
            avgBpm = avgBpmSum/avgBpmCnt
        }
    }
    
    func initArray() {
        
        bpmChartView.clear()
        
        minBpm = 70
        maxBpm = 0
        avgBpm = 0
        avgBpmCnt = 0
        avgBpmSum = 0
        
        earliestStartTime = ""
        latestEndTime = ""
        
        startBpmTimeInMinutes = 0
        endBpmTimeInMinutes = 0
        
        xAxisTotal = 0
        
        bpmTimeCount = 0
        timeTableCount = 0
        
        timeTable.removeAll()
        
        startBpmTime.removeAll()
        endBpmTime.removeAll()
        
        targetBpmData.removeAll()
        targetBpmTimeData.removeAll()
        
        twoDaysBpmData.removeAll()
        twoDaysBpmTimeData.removeAll()
        
        threeDaysBpmData.removeAll()
        threeDaysBpmTimeData.removeAll()
        
        targetBpmEntries.removeAll()
        twoDaysBpmEntries.removeAll()
        threeDaysBpmEntries.removeAll()
        
        maxBpmValue.text = "0"
        minBpmValue.text = "0"
        avgBpmValue.text = "0"
        diffMinBpm.text = "-0"
        diffMaxBpm.text = "+0"
        
    }
    
    public static func initializeDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - addViews
    func addViews() {
        view.addSubview(bpmChartView)

        view.addSubview(bottomLabel)
        bottomLabel.addSubview(topContents)
        bottomLabel.addSubview(middleContents)
        bottomLabel.addSubview(bottomContents)
        
        // --------------------- topContents --------------------- //
        todayButton.tag = TODAY_FLAG
        twoDaysButton.tag = TWO_DAYS_FLAG
        threeDaysButton.tag = THREE_DAYS_FLAG
        
        topContents.addSubview(todayButton)
        topContents.addSubview(twoDaysButton)
        topContents.addSubview(threeDaysButton)
        
        // --------------------- middleContents --------------------- //
        yesterdayBpmButton.tag = YESTERDAY_BUTTON_FLAG
        tomorrowBpmButton.tag = TOMORROW_BUTTON_FLAG
        
        middleContents.addSubview(yesterdayBpmButton)
        middleContents.addSubview(tomorrowBpmButton)
        middleContents.addSubview(todayDispalay)
        
        // --------------------- bottomContents --------------------- //
        bottomContents.addSubview(centerBpmContents)
        bottomContents.addSubview(leftBpmContents)
        bottomContents.addSubview(rightBpmContents)
        
        centerBpmContents.addSubview(avgBpmLabel)
        centerBpmContents.addSubview(avgBpmValue)
        centerBpmContents.addSubview(bpmLabel)
        
        leftBpmContents.addSubview(minBpmLabel)
        leftBpmContents.addSubview(minBpmValue)
        leftBpmContents.addSubview(diffMinBpm)
        
        rightBpmContents.addSubview(maxBpmLabel)
        rightBpmContents.addSubview(maxBpmValue)
        rightBpmContents.addSubview(diffMaxBpm)
        
        setConstraints()
    }
    
    // MARK: - Constraints
    func setConstraints(){
        
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneThirdWidth = screenWidth / 3.0
        
        NSLayoutConstraint.activate([
            
            // --------------------- set Weight --------------------- //
            // bpmChart
            bpmChartView.topAnchor.constraint(equalTo: safeAreaView.topAnchor),
            bpmChartView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            bpmChartView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            bpmChartView.heightAnchor.constraint(equalTo: safeAreaView.heightAnchor, multiplier: 5.5 / (5.5 + 4.5)),

            // bottomLabel
            bottomLabel.topAnchor.constraint(equalTo: bpmChartView.bottomAnchor),
            bottomLabel.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            bottomLabel.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor),
            
            // topContents
            topContents.topAnchor.constraint(equalTo: bottomLabel.topAnchor, constant: 10),
            topContents.leadingAnchor.constraint(equalTo: bottomLabel.leadingAnchor, constant: 10),
            topContents.trailingAnchor.constraint(equalTo: bottomLabel.trailingAnchor, constant: -10),
            topContents.heightAnchor.constraint(equalTo: bottomLabel.heightAnchor, multiplier: singlePortion),
            
            // middleContents
            middleContents.topAnchor.constraint(equalTo: topContents.bottomAnchor),
            middleContents.leadingAnchor.constraint(equalTo: bottomLabel.leadingAnchor),
            middleContents.trailingAnchor.constraint(equalTo: bottomLabel.trailingAnchor),
            middleContents.heightAnchor.constraint(equalTo: bottomLabel.heightAnchor, multiplier: singlePortion),
            
            // bottomContents
            bottomContents.topAnchor.constraint(equalTo: middleContents.bottomAnchor),
            bottomContents.leadingAnchor.constraint(equalTo: bottomLabel.leadingAnchor),
            bottomContents.trailingAnchor.constraint(equalTo: bottomLabel.trailingAnchor),
            bottomContents.bottomAnchor.constraint(equalTo: bottomLabel.bottomAnchor),
            
            // --------------------- top Contents --------------------- //
            // twoDaysButton
            twoDaysButton.topAnchor.constraint(equalTo: topContents.topAnchor),
            twoDaysButton.centerXAnchor.constraint(equalTo: topContents.centerXAnchor),
            twoDaysButton.bottomAnchor.constraint(equalTo: topContents.bottomAnchor, constant: -20),
            twoDaysButton.widthAnchor.constraint(equalToConstant: oneThirdWidth  - 30 ),
            
            // todayButton
            todayButton.topAnchor.constraint(equalTo: topContents.topAnchor),
            todayButton.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor, constant: 10),
            todayButton.bottomAnchor.constraint(equalTo: topContents.bottomAnchor, constant: -20),
            todayButton.widthAnchor.constraint(equalToConstant: oneThirdWidth  - 30 ),
            
            // threeDaysButton
            threeDaysButton.topAnchor.constraint(equalTo: topContents.topAnchor),
            threeDaysButton.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -10),
            threeDaysButton.bottomAnchor.constraint(equalTo: topContents.bottomAnchor, constant: -20),
            threeDaysButton.widthAnchor.constraint(equalToConstant: oneThirdWidth  - 30 ),

            
            // --------------------- middle Contents --------------------- //
            // todayDispalay
            todayDispalay.topAnchor.constraint(equalTo: middleContents.topAnchor),
            todayDispalay.centerXAnchor.constraint(equalTo: middleContents.centerXAnchor),
            todayDispalay.bottomAnchor.constraint(equalTo: middleContents.bottomAnchor),
            
            // yesterdayBpmButton
            yesterdayBpmButton.topAnchor.constraint(equalTo: middleContents.topAnchor),
            yesterdayBpmButton.leadingAnchor.constraint(equalTo: middleContents.leadingAnchor, constant: 10),
            yesterdayBpmButton.bottomAnchor.constraint(equalTo: middleContents.bottomAnchor),
            
            // tomorrowBpmButton
            tomorrowBpmButton.topAnchor.constraint(equalTo: middleContents.topAnchor),
            tomorrowBpmButton.trailingAnchor.constraint(equalTo: middleContents.trailingAnchor, constant: -10),
            tomorrowBpmButton.bottomAnchor.constraint(equalTo: middleContents.bottomAnchor),
            
            // --------------------- bottom Contents --------------------- //
            // centerBpmContents
            centerBpmContents.topAnchor.constraint(equalTo: bottomContents.topAnchor),
            centerBpmContents.centerXAnchor.constraint(equalTo: bottomContents.centerXAnchor),
            centerBpmContents.bottomAnchor.constraint(equalTo: bottomContents.bottomAnchor),
            centerBpmContents.widthAnchor.constraint(equalToConstant: oneThirdWidth ),
            
            // leftBpmContents
            leftBpmContents.topAnchor.constraint(equalTo: bottomContents.topAnchor),
            leftBpmContents.leadingAnchor.constraint(equalTo: bottomContents.leadingAnchor),
            leftBpmContents.bottomAnchor.constraint(equalTo: bottomContents.bottomAnchor),
            leftBpmContents.widthAnchor.constraint(equalToConstant: oneThirdWidth ),
            
            // rightBpmContents
            rightBpmContents.topAnchor.constraint(equalTo: bottomContents.topAnchor),
            rightBpmContents.trailingAnchor.constraint(equalTo: bottomContents.trailingAnchor),
            rightBpmContents.bottomAnchor.constraint(equalTo: bottomContents.bottomAnchor),
            rightBpmContents.widthAnchor.constraint(equalToConstant: oneThirdWidth ),
            
            // --------------------- centerBpmContents --------------------- //
            avgBpmValue.centerXAnchor.constraint(equalTo: centerBpmContents.centerXAnchor),
            avgBpmValue.centerYAnchor.constraint(equalTo: centerBpmContents.centerYAnchor),
                        
            avgBpmLabel.bottomAnchor.constraint(equalTo: avgBpmValue.topAnchor, constant: -10),
            avgBpmLabel.centerXAnchor.constraint(equalTo: centerBpmContents.centerXAnchor),
            
            bpmLabel.topAnchor.constraint(equalTo: avgBpmValue.bottomAnchor, constant: 10),
            bpmLabel.centerXAnchor.constraint(equalTo: centerBpmContents.centerXAnchor),
            
            // --------------------- leftBpmContents --------------------- //
            minBpmValue.centerXAnchor.constraint(equalTo: leftBpmContents.centerXAnchor),
            minBpmValue.centerYAnchor.constraint(equalTo: avgBpmValue.centerYAnchor),
                        
            minBpmLabel.centerYAnchor.constraint(equalTo: avgBpmLabel.centerYAnchor),
            minBpmLabel.centerXAnchor.constraint(equalTo: leftBpmContents.centerXAnchor),
            
            diffMinBpm.centerYAnchor.constraint(equalTo: bpmLabel.centerYAnchor),
            diffMinBpm.centerXAnchor.constraint(equalTo: leftBpmContents.centerXAnchor),
            
            // --------------------- rightBpmContents --------------------- //
            maxBpmValue.centerXAnchor.constraint(equalTo: rightBpmContents.centerXAnchor),
            maxBpmValue.centerYAnchor.constraint(equalTo: avgBpmValue.centerYAnchor),
                        
            maxBpmLabel.centerYAnchor.constraint(equalTo: avgBpmLabel.centerYAnchor),
            maxBpmLabel.centerXAnchor.constraint(equalTo: rightBpmContents.centerXAnchor),
            
            diffMaxBpm.centerYAnchor.constraint(equalTo: bpmLabel.centerYAnchor),
            diffMaxBpm.centerXAnchor.constraint(equalTo: rightBpmContents.centerXAnchor),
            
        ])
    }
}
