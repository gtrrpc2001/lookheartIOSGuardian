import UIKit
import Foundation
import DGCharts
import SnapKit
import Then

class SummaryCal : BaseViewController, Refreshable {

    private let CALDATA_FILENAME = "/calandDistanceData.csv"
    private let YESTERDAY_BUTTON_FLAG = 1
    private let TOMORROW_BUTTON_FLAG = 2
    
    private let MONTH_FORMAT = true
    private let YEAR_FORMAT = false
    
    private let PATH_DAY = true
    private let PATH_MONTH = false
    
    private let ADD_DATE = true
    private let MINUS_DATE = false
    
    private let DAY_FLAG = 1
    private let WEEK_FLAG = 2
    private let MONTH_FLAG = 3
    private let YEAR_FLAG = 4
    private var email = ""
    
    enum DateChangeType: Int {
        case day = 1
        case week = 2
        case month = 3
        case year = 4
    }
    
    //    ----------------------------- cal Var -------------------    //
    private let dateFormatter = DateFormatter()
    
    private var fileDataExists = 0
    
    private var tCalSum = 0
    private var aCalSum = 0
    
    private var resultTCalSum = 0
    private var resultACalSum = 0
    
    private var currentFlag = 0
    
    private var preDate = ""
    private var splitPreDate:[Substring] = []
    
    private var targetDate:String = ""
    private var targetYear:String = ""
    private var targetMonth:String = ""
    private var targetDay:String = ""
    
    private var calCalendar = Calendar.current
    
    private var buttonList:[UIButton] = []

    private var startCalTime = [String]()
    private var endCalTime = [String]()
    
    private var earliestStartTime = ""
    private var latestEndTime = ""
    

    private var startCalTimeInMinutes = 0
    private var endCalTimeInMinutes = 0
    
    private var timeTable: [String] = []
    private var timeTableCount = 0
    
    private var targetTCalData: [Double] = []
    private var targetACalData: [Double] = []
    private var targetCalTimeData: [String] = []
    
    //    ----------------------------- csv Var -------------------    //
    private var fileManager:FileManager = FileManager.default
    private var appendingPath = ""
    
    private lazy var documentsURL: URL = {
        return SummaryCal.initializeDocumentsURL()
    }()
    
    private var currentDirectoryURL: URL {
        return documentsURL.appendingPathComponent("\(appendingPath)")
    }
    
    private var calDataFileURL: URL {
        return currentDirectoryURL.appendingPathComponent(CALDATA_FILENAME)
    }
    
    //    ----------------------------- Chart -------------------    //
    lazy var calChartView: BarChartView =  {
        let chartView = BarChartView()
        chartView.noDataText = ""
        return chartView
    }()
    
    //    ----------------------------- UILabel -------------------    //
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let topContents: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let middleContents: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var bottomContents: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tCalBackground, aCalBackground])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually // default
        stackView.alignment = .fill // default
        stackView.spacing = 5
        
        return stackView
    }()
    
    private let calValueContents: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: - top Contents
    lazy var dayButton = UIButton().then {
        $0.setTitle ("fragment_day".localized(), for: .normal )
        
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
        
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    lazy var weekButton = UIButton().then {
        $0.setTitle ("fragment_week".localized(), for: .normal )
        
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .selected)
        $0.setTitleColor(.lightGray, for: .disabled)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        $0.setBackgroundColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0), for: .normal)
        $0.setBackgroundColor(UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0), for: .selected)
        $0.setBackgroundColor(UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0), for: .disabled)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    lazy var monthButton = UIButton().then {
        $0.setTitle ("fragment_month".localized(), for: .normal )
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
        
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    lazy var yearButton = UIButton().then {
        $0.setTitle ("fragment_year".localized(), for: .normal )
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
        
        $0.addTarget(self, action: #selector(selectDayButton(_:)), for: .touchUpInside)
    }
    
    // MARK: - middle Contents
    private lazy var todayDispalay = UILabel().then {
        $0.text = "\(currentYear)-\(currentMonth)-\(currentDay)"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.baselineAdjustment = .alignCenters
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private lazy var yesterdayCalButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    private lazy var tomorrowCalButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    // MARK: - bottom Contents
    private lazy var tCalBackground: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [totalCalLabel, tCalProgress])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        return stackView
    }()
    
    private lazy var aCalBackground: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [activityCalLabel, aCalProgress])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        return stackView
    }()
    
    private let tCalProgress: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackTintColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0)
        progressView.progressTintColor = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
        
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 10
        progressView.layer.masksToBounds = true
        
        return progressView
    }()
    
    private let aCalProgress: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackTintColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0)
        progressView.progressTintColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
        
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 10
        progressView.layer.masksToBounds = true
        
        return progressView
    }()
    
    private let totalCalLabel:UILabel = {
        let label = UILabel()
        label.text = "tCalTitle".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let activityCalLabel:UILabel = {
        let label = UILabel()
        label.text = "eCalTitle".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let targetTotalCalories:UILabel = {
        let label = UILabel()
        label.text = "eCalValue".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let targetActivityCalories:UILabel = {
        let label = UILabel()
        label.text = "eCalValue".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let burntTotalCalories:UILabel = {
        let label = UILabel()
        label.text = "eCalValue".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let burntActivityCalories:UILabel = {
        let label = UILabel()
        label.text = "eCalValue".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let bottomLine:UILabel = {
        let label = UILabel()
        label.backgroundColor = .lightGray
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
        return label
    }()
    
    let alertLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.isHidden = true
        label.numberOfLines = 4
        label.textAlignment = .center
        return label
    }()
        
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initVar()
        addViews()
        dailyCalChart()
    }
    
    func refreshView() {
        initVar()
        initArray()
        addViews()
        dailyCalChart()
    }
    
    func initVar(){
        email = UserProfileManager.shared.getEmail()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        currentFlag = DAY_FLAG
        
        buttonList = [dayButton, weekButton, monthButton, yearButton]
        
        targetDate = currentDate
        targetYear = currentYear
        targetMonth = currentMonth
        targetDay = currentDay
        
        targetTotalCalories.text = "\(UserProfileManager.shared.getTCal()) \("kcalValue".localized())"
        targetActivityCalories.text = "\(UserProfileManager.shared.getACal()) \("kcalValue".localized())"
        
        setButtonColor(dayButton)
    }
    
    // MARK: - CHART
    func dailyCalChart() {
        
        setDisplayText(changeDateFormat("\(targetYear)-\(targetMonth)-\(targetDay)", YEAR_FORMAT))
        
        if fileExists() {
            
            getFileData(path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)")
            displayChart()
            setUI(day: 1, tCalSum: tCalSum, aCalSum: aCalSum)
            
        } else {
            // 파일 없음
        }
    }

    func weeklyCalChart() {
        
        let monday = findMonday()
        
        dateCalculate(targetDate, monday, MINUS_DATE, .day)
        preDate = targetDate
        let mondayMonth = targetMonth
        let mondayDay = targetDay
        
        fetchDailyFileData(startDay: 0, numDay: 6)
        
        setDisplayText("\(changeDateFormat("\(mondayMonth).\(mondayDay)", MONTH_FORMAT)) ~ \(changeDateFormat("\(targetMonth).\(targetDay)", MONTH_FORMAT))")
        
        dateCalculate(preDate, monday, ADD_DATE, .day)
        
        if !(fileDataExists == 7) {
            displayChart()
            setUI(day: 7 - fileDataExists, tCalSum: resultTCalSum, aCalSum: resultACalSum)
        } else {
            // 파일 없음
        }
    }
    
    func monthlyCalChart() {
        
        setDisplayText(changeDateFormat("\(targetYear).\(targetMonth)", MONTH_FORMAT))
        
        var numDay = 0 // 해당 월에 며칠인지 확인하는 변수
        let firstDay = findFirstDayOfMonth(targetDate)! // 1일까지 찾는 변수
        
        if compareMonth() { numDay = Int(currentDay)!   }
        else {  numDay = findNumDay(targetDate)!    }
        
        dateCalculate(targetDate, firstDay, MINUS_DATE, .day)
        preDate = targetDate
        
        fetchDailyFileData(startDay: 1, numDay: numDay)
        
        dateCalculate(preDate, firstDay, ADD_DATE, .day)
        
        if !(fileDataExists == numDay) {
            displayChart()
            setUI(day: numDay - fileDataExists, tCalSum: resultTCalSum, aCalSum: resultACalSum)
        } else {
            // 파일 없음
        }
    }
    
    func yearlyCalChart() {
        
        setDisplayText(targetYear)
        
        var monthlyTCal = 0
        var monthlyACal = 0
        var fileExistsCheck = 0
        
        splitPreDate = targetDate.split(separator: "-")
        targetDate = "\(targetYear)-1-1"
        targetMonth = "1"
        targetDay = "1"
                
        for month in 1...12 {
            if monthDirExists() {
                
                let numberOfDaysInMonth = findNumDay(targetDate)!
                for day in 1...numberOfDaysInMonth {
                    
                    targetDate = "\(targetYear)-\(month)-\(day)"
                    if fileExists(){
                        getFileData(path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)")
                        monthlyTCal += tCalSum
                        monthlyACal += aCalSum
                        tCalSum = 0
                        aCalSum = 0
                        
                        fileExistsCheck += 1
                    }
                    
                    if day != numberOfDaysInMonth {  dateCalculate(targetDate, 1, ADD_DATE, .day) }
                }
                
                resultTCalSum += monthlyTCal
                resultACalSum += monthlyACal
                
                targetTCalData.append(Double(monthlyTCal))
                targetACalData.append(Double(monthlyACal))
                targetCalTimeData.append(String(month))
                
                monthlyTCal = 0
                monthlyACal = 0
                
            } else {
                // 디렉토리 없음
                fileDataExists += 1
            }
            
            dateCalculate(targetDate, 1, ADD_DATE, .month)
        }
        
        if fileDataExists != 12 {
            displayChart()
            setUI(day: fileExistsCheck, tCalSum: resultTCalSum, aCalSum: resultACalSum)
        } else {
            // 데이터 없음
        }
        
        targetDate = splitPreDate.joined(separator: "-")
        targetYear = String(splitPreDate[0])
        targetMonth = String(splitPreDate[1])
        targetDay = String(splitPreDate[2])
    }
    
    // MARK: - CHART FUNC
    func getFileData(path: String) {

        do {
            appendingPath = path
            let fileData = try String(contentsOf: calDataFileURL)
            let separatedData = fileData.components(separatedBy: .newlines)
            
            for i in 0 ..< separatedData.count {
                let row = separatedData[i]
                let columns = row.components(separatedBy: ",")
                
                let totalCalorie = Double(columns[4].trimmingCharacters(in: .whitespacesAndNewlines))
                let activityCalorie = Double(columns[5].trimmingCharacters(in: .whitespacesAndNewlines))
                
                sumCalories(Int(totalCalorie ?? 0), Int(activityCalorie ?? 0))

                if currentFlag == DAY_FLAG {
                    targetTCalData.append(totalCalorie ?? 0.0)
                    targetACalData.append(activityCalorie ?? 0.0)
                    targetCalTimeData.append(columns[0])
                }
            }
        } catch  {
            print("Error reading CSV file")
        }
    }
        
    func setUI(day: Int, tCalSum: Int, aCalSum: Int){
        let totalCalorieeGoal = UserProfileManager.shared.getTCal()
        let activityCalorieGaol = UserProfileManager.shared.getACal()
        
        // Progress
        let dailyTotalCalorieRatio = Double(tCalSum) / Double(totalCalorieeGoal * day)
        tCalProgress.progress = Float(dailyTotalCalorieRatio)
        
        let dailyActiveCalorieRatio = Double(aCalSum) / Double(activityCalorieGaol * day)
        aCalProgress.progress = Float(dailyActiveCalorieRatio)
        
        // text
        targetTotalCalories.text = "\(totalCalorieeGoal) \("kcalValue".localized())"
        burntTotalCalories.text = "\(tCalSum) \("kcalValue".localized())"
        targetActivityCalories.text = "\(activityCalorieGaol) \("kcalValue".localized())"
        burntActivityCalories.text = "\(aCalSum) \("kcalValue".localized())"
    }
    
    func displayChart() {
        var totalCalEntry = [BarChartDataEntry]()
        var activityCalEntry = [BarChartDataEntry]()
        
        for i in 0 ..< targetTCalData.count {
            let tCalDataEntry = BarChartDataEntry(x: Double(i), y: targetTCalData[i])
            let aCalDataEntry = BarChartDataEntry(x: Double(i), y: targetACalData[i])
            totalCalEntry.append(tCalDataEntry)
            activityCalEntry.append(aCalDataEntry)
        }

        // set ChartData
        let tCalChartDataSet = chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: BarChartDataSet(entries: totalCalEntry, label: "summaryTCal".localized()))
        let aCalChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: BarChartDataSet(entries: activityCalEntry, label: "summaryECal".localized()))
        
        let dataSets: [BarChartDataSet] = [tCalChartDataSet, aCalChartDataSet]
        
        setChart(chartData: BarChartData(dataSets: dataSets),
                 labelCnt: targetTCalData.count)
    }
    
    func fetchDailyFileData(startDay: Int, numDay: Int) {
        
        for i in startDay...numDay {
            if fileExists() {
                getFileData(path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)")
                targetTCalData.append(Double(tCalSum))
                targetACalData.append(Double(aCalSum))
                currentFlag == WEEK_FLAG ? targetCalTimeData.append(weekDays[i]) : targetCalTimeData.append(String(i))
            } else {
                switch (currentFlag){
                case MONTH_FLAG:
                    fileDataExists += 1
                default: // WEEK_FLAG
                    targetTCalData.append(0.0)
                    targetACalData.append(0.0)
                    targetCalTimeData.append(weekDays[i])
                    fileDataExists += 1
                }
            }
            
            resultTCalSum += tCalSum
            resultACalSum += aCalSum
            
            tCalSum = 0
            aCalSum = 0

            if i != numDay {  dateCalculate(targetDate, 1, ADD_DATE, .day) }
        }
    }

    
    func chartDataSet(color: NSUIColor, chartDataSet: BarChartDataSet) -> BarChartDataSet {
        chartDataSet.setColor(color)
        chartDataSet.drawValuesEnabled = false
        
        return chartDataSet
    }
    
    func setChart(chartData: BarChartData, labelCnt: Int) {
        
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        
        chartData.barWidth = barWidth
        
        calChartView.xAxis.axisMinimum = Double(0)
        calChartView.xAxis.axisMaximum = Double(0) + chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(targetTCalData.count)  // group count : 2
        chartData.groupBars(fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
        
        calChartView.legend.font = .systemFont(ofSize: 15, weight: .bold)
        
        calChartView.data = chartData
        calChartView.xAxis.enabled = true
        calChartView.xAxis.centerAxisLabelsEnabled = true
        calChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: targetCalTimeData)
        calChartView.xAxis.granularity = 1
        calChartView.xAxis.setLabelCount(targetTCalData.count, force: false)
        calChartView.xAxis.labelPosition = .bottom
        calChartView.xAxis.drawGridLinesEnabled = false
        
        calChartView.leftAxis.granularityEnabled = true
        calChartView.leftAxis.granularity = 1.0
        
        calChartView.leftAxis.axisMinimum = 0
        calChartView.rightAxis.enabled = false
        calChartView.drawMarkers = false
        calChartView.dragEnabled = false
        calChartView.pinchZoomEnabled = false
        calChartView.doubleTapToZoomEnabled = false
        calChartView.highlightPerTapEnabled = false
        
        calChartView.data?.notifyDataChanged()
        calChartView.notifyDataSetChanged()
        calChartView.moveViewToX(0)
    }
    
    func changeDateFormat(_ dateString: String, _ checkDate: Bool) -> String {
        var dateComponents = checkDate == YEAR_FORMAT ? dateString.components(separatedBy: "-") : dateString.components(separatedBy: ".")
        
        if checkDate {  // month.day
            if !(dateComponents[0].count > 2) { // year.month check
                dateComponents[0] = String(format: "%02d", Int(dateComponents[0])!)
            }
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            return dateComponents.joined(separator: ".")
        } else {    // year-month-day
            dateComponents[1] = String(format: "%02d", Int(dateComponents[1])!)
            dateComponents[2] = String(format: "%02d", Int(dateComponents[2])!)
            
        }
        return checkDate == YEAR_FORMAT ? dateComponents.joined(separator: "-") : dateComponents.joined(separator: ".")
    }
    
    // MARK: -
    @objc func shiftDate(_ sender: UIButton) {
        let dateChangeType = DateChangeType(rawValue: currentFlag) ?? .day
        let dateDirection = sender.tag == YESTERDAY_BUTTON_FLAG ? MINUS_DATE : ADD_DATE
        
        switch dateChangeType {
        case .day:
            dateCalculate(targetDate, 1, dateDirection, .day)
        case .week:
            dateCalculate(targetDate, 7, dateDirection, .day)
        case .month:
            dateCalculate(targetDate, 1, dateDirection, .month)
        case .year:
            dateCalculate(targetDate, 1, dateDirection, .year)
        }
        
        viewChart(currentFlag)
    }
    
    @objc func selectDayButton(_ sender: UIButton) {
        switch(sender.tag) {
        case WEEK_FLAG:
            currentFlag = WEEK_FLAG
        case MONTH_FLAG:
            currentFlag = MONTH_FLAG
        case YEAR_FLAG:
            currentFlag = YEAR_FLAG
        default:
            currentFlag = DAY_FLAG
        }
        
        viewChart(currentFlag)
        setButtonColor(sender)
    }
     
    func viewChart(_ tag: Int) {
        
        initArray()
        
        switch(tag) {
        case WEEK_FLAG:
            weeklyCalChart()
        case MONTH_FLAG:
            monthlyCalChart()
        case YEAR_FLAG:
            yearlyCalChart()
        default:
            dailyCalChart()
        }
    }
    
    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool, _ type: Calendar.Component) {
        
        guard let inputDate = dateFormatter.date(from: date) else { return }
        let dayValue = shouldAdd ? day : -day
        if let calTargetDate = calCalendar.date(byAdding: type, value: dayValue, to: inputDate) {
            
            let components = calCalendar.dateComponents([.year, .month, .day], from: calTargetDate)
            
            if let year = components.year, let month = components.month, let day = components.day {
                targetYear = "\(year)"
                targetMonth = "\(month)"
                targetDay = "\(day)"
                
                targetDate = "\(targetYear)-\(targetMonth)-\(targetDay)"
            }
        }
    }
    
    func setDisplayText(_ dateText: String) {
        todayDispalay.text = dateText
    }
    
    func pathForDate(year: String, month: String, day: String) -> String {
        return "\(email)/\(year)/\(month)/\(day)"
    }
    
    func fileExistsAtPath(_ path: String) -> Bool {
        appendingPath = path
        return fileManager.fileExists(atPath: calDataFileURL.path)
    }

    func fileExists() -> Bool {
        let path = pathForDate(year: targetYear, month: targetMonth, day: targetDay)
        
        if !fileExistsAtPath(path) {
            return false
        }
        return true
    }
    
    func monthDirExists() -> Bool {
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(email)/\(targetYear)/\(targetMonth)")
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDir) {
            if isDir.boolValue {    // 디렉토리 존재
                return true
            } else {    // 파일은 있지만 디렉토리가 아님
                return false
            }
        } else {    // 디렉토리 없음
            return false
        }
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
    
    func sumCalories(_ tCal: Int, _ aCal: Int) {
        tCalSum += tCal
        aCalSum += aCal
    }
    
    func findWeekday() -> String? {
        var dateComponents = DateComponents()
        dateComponents.year = Int(targetYear)
        dateComponents.month = Int(targetMonth)
        dateComponents.day = Int(targetDay)
        
        let calendar = Calendar.current
        
        if let specificDate = calendar.date(from: dateComponents) {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 로케일 설정
            dateFormatter.dateFormat = "EEEE" // 요일의 전체 이름
            let weekdayName = dateFormatter.string(from: specificDate)

            return weekdayName
        } else {
            return nil
        }
    }
    
    func findMonday() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let weekdaySymbols = calendar.weekdaySymbols
        
        guard let weekdayName = findWeekday(),
              let weekdayIndex = weekdaySymbols.firstIndex(of: weekdayName) else {
            return 0
        }
        // 'calendar.firstWeekday'로 주의 시작 요일을 고려해 인덱스 조정
        // 그레고리안 캘린더에서 'firstWeekday'는 일반적으로 1(일요일)
        // 월요일을 0으로 만들기 위해, 인덱스에서 1을 빼고, 7로 나눈 나머지를 계산
        let mondayIndex = (weekdayIndex + 7 - calendar.firstWeekday) % 7
        return mondayIndex
    }
    
    func findNumDay(_ date: String) -> Int? {
        guard let inputDate = dateFormatter.date(from: date) else { return nil}
        if let range = calCalendar.range(of: .day, in: .month, for: inputDate) {
            return range.count
        } else {
            return nil
        }
    }
    
    func findFirstDayOfMonth(_ date: String) -> Int? {
        guard let inputDate = dateFormatter.date(from: date) else { return nil}
        let currentDayComponent = calCalendar.component(.day, from: inputDate)
        return  currentDayComponent - 1
    }
    
    func compareMonth() -> Bool {
        return currentYear == targetYear && currentMonth == targetMonth ? true : false
    }
    
    func initArray() {
        
        calChartView.clear()
        
        tCalSum = 0
        aCalSum = 0
        
        resultTCalSum = 0
        resultACalSum = 0
        
        fileDataExists = 0
        
        earliestStartTime = ""
        latestEndTime = ""
        preDate = ""
        
        startCalTimeInMinutes = 0
        endCalTimeInMinutes = 0
        
        timeTableCount = 0
        
        timeTable.removeAll()
        
        startCalTime.removeAll()
        endCalTime.removeAll()
        
        targetTCalData.removeAll()
        targetACalData.removeAll()
        targetCalTimeData.removeAll()
        
        setUI(day: 1, tCalSum: tCalSum, aCalSum: aCalSum)
    }
    
    public static func initializeDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - addViews
    func addViews() {
        view.addSubview(calChartView)

        view.addSubview(bottomLabel)
        bottomLabel.addSubview(topContents)
        bottomLabel.addSubview(middleContents)
        bottomLabel.addSubview(bottomContents)
        bottomLabel.addSubview(calValueContents)
        
        // --------------------- topContents --------------------- //
        dayButton.tag = DAY_FLAG
        weekButton.tag = WEEK_FLAG
        monthButton.tag = MONTH_FLAG
        yearButton.tag = YEAR_FLAG
        
        topContents.addSubview(dayButton)
        topContents.addSubview(weekButton)
        topContents.addSubview(monthButton)
        topContents.addSubview(yearButton)
        
        // --------------------- middleContents --------------------- //
        yesterdayCalButton.tag = YESTERDAY_BUTTON_FLAG
        tomorrowCalButton.tag = TOMORROW_BUTTON_FLAG
        
        middleContents.addSubview(yesterdayCalButton)
        middleContents.addSubview(tomorrowCalButton)
        middleContents.addSubview(todayDispalay)
        
        // --------------------- bottomContents --------------------- //
        calValueContents.addSubview(targetTotalCalories)
        calValueContents.addSubview(targetActivityCalories)
        
        calValueContents.addSubview(burntTotalCalories)
        calValueContents.addSubview(burntActivityCalories)
        
        calValueContents.addSubview(bottomLine)
        
        setConstraints()
    }
    
    // MARK: - Constraints
    func setConstraints(){
        
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneFourthWidth = screenWidth / 4.0
        
        calChartView.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topContents.translatesAutoresizingMaskIntoConstraints = false
        middleContents.translatesAutoresizingMaskIntoConstraints = false
        bottomContents.translatesAutoresizingMaskIntoConstraints = false
        
        dayButton.translatesAutoresizingMaskIntoConstraints = false
        weekButton.translatesAutoresizingMaskIntoConstraints = false
        monthButton.translatesAutoresizingMaskIntoConstraints = false
        yearButton.translatesAutoresizingMaskIntoConstraints = false
        
        yesterdayCalButton.translatesAutoresizingMaskIntoConstraints = false
        tomorrowCalButton.translatesAutoresizingMaskIntoConstraints = false
        todayDispalay.translatesAutoresizingMaskIntoConstraints = false
        
        calValueContents.translatesAutoresizingMaskIntoConstraints = false
        
        burntTotalCalories.translatesAutoresizingMaskIntoConstraints = false
        burntActivityCalories.translatesAutoresizingMaskIntoConstraints = false
        
        targetTotalCalories.translatesAutoresizingMaskIntoConstraints = false
        targetActivityCalories.translatesAutoresizingMaskIntoConstraints = false
        
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            // --------------------- set Weight --------------------- //
            // chart
            calChartView.topAnchor.constraint(equalTo: safeAreaView.topAnchor),
            calChartView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            calChartView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            calChartView.heightAnchor.constraint(equalTo: safeAreaView.heightAnchor, multiplier: 5.5 / (5.5 + 4.5)),

            // bottomLabel
            bottomLabel.topAnchor.constraint(equalTo: calChartView.bottomAnchor),
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
            bottomContents.leadingAnchor.constraint(equalTo: bottomLabel.leadingAnchor, constant: 20),
            bottomContents.trailingAnchor.constraint(equalTo: safeAreaView.centerXAnchor, constant: 40),
            bottomContents.bottomAnchor.constraint(equalTo: bottomLabel.bottomAnchor, constant: -5),
            
            // --------------------- top Contents --------------------- //
            // Week
            weekButton.topAnchor.constraint(equalTo: topContents.topAnchor),
            weekButton.trailingAnchor.constraint(equalTo: topContents.centerXAnchor, constant: -10),
            weekButton.bottomAnchor.constraint(equalTo: topContents.bottomAnchor, constant: -20),
            weekButton.widthAnchor.constraint(equalToConstant: oneFourthWidth  - 20 ),
            
            // Month
            monthButton.topAnchor.constraint(equalTo: topContents.topAnchor),
            monthButton.leadingAnchor.constraint(equalTo: topContents.centerXAnchor, constant: 10),
            monthButton.bottomAnchor.constraint(equalTo: topContents.bottomAnchor, constant: -20),
            monthButton.widthAnchor.constraint(equalToConstant: oneFourthWidth  - 20 ),
            
            // Day
            dayButton.topAnchor.constraint(equalTo: topContents.topAnchor),
            dayButton.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor, constant: 10),
            dayButton.bottomAnchor.constraint(equalTo: topContents.bottomAnchor, constant: -20),
            dayButton.widthAnchor.constraint(equalToConstant: oneFourthWidth  - 20 ),
            
            // Year
            yearButton.topAnchor.constraint(equalTo: topContents.topAnchor),
            yearButton.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -10),
            yearButton.bottomAnchor.constraint(equalTo: topContents.bottomAnchor, constant: -20),
            yearButton.widthAnchor.constraint(equalToConstant: oneFourthWidth  - 20 ),
            

            // --------------------- middle Contents --------------------- //
            // todayDispalay
            todayDispalay.topAnchor.constraint(equalTo: middleContents.topAnchor),
            todayDispalay.centerXAnchor.constraint(equalTo: middleContents.centerXAnchor),
            todayDispalay.bottomAnchor.constraint(equalTo: middleContents.bottomAnchor),
            
            // yesterdayButton
            yesterdayCalButton.topAnchor.constraint(equalTo: middleContents.topAnchor),
            yesterdayCalButton.leadingAnchor.constraint(equalTo: middleContents.leadingAnchor, constant: 10),
            yesterdayCalButton.bottomAnchor.constraint(equalTo: middleContents.bottomAnchor),
            
            // tomorrowButton
            tomorrowCalButton.topAnchor.constraint(equalTo: middleContents.topAnchor),
            tomorrowCalButton.trailingAnchor.constraint(equalTo: middleContents.trailingAnchor, constant: -10),
            tomorrowCalButton.bottomAnchor.constraint(equalTo: middleContents.bottomAnchor),
            
            // --------------------- bottom Contents --------------------- //
            
            calValueContents.topAnchor.constraint(equalTo: bottomContents.topAnchor),
            calValueContents.leadingAnchor.constraint(equalTo: bottomContents.trailingAnchor),
            calValueContents.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            calValueContents.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor),
            
            burntTotalCalories.centerXAnchor.constraint(equalTo: calValueContents.centerXAnchor),
            burntTotalCalories.centerYAnchor.constraint(equalTo: totalCalLabel.centerYAnchor),
            
            targetTotalCalories.centerXAnchor.constraint(equalTo: calValueContents.centerXAnchor),
            targetTotalCalories.centerYAnchor.constraint(equalTo: tCalProgress.centerYAnchor),
            
            burntActivityCalories.centerXAnchor.constraint(equalTo: calValueContents.centerXAnchor),
            burntActivityCalories.centerYAnchor.constraint(equalTo: activityCalLabel.centerYAnchor),
            
            targetActivityCalories.centerXAnchor.constraint(equalTo: calValueContents.centerXAnchor),
            targetActivityCalories.centerYAnchor.constraint(equalTo: aCalProgress.centerYAnchor),
            
            bottomLine.centerYAnchor.constraint(equalTo: calValueContents.centerYAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor, constant: 10),
            bottomLine.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -10),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}
