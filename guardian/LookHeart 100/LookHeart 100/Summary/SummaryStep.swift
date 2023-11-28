import UIKit
import Foundation
import DGCharts
import SnapKit
import Then

class SummaryStep : BaseViewController, Refreshable {
    
    private let STEPDATA_FILENAME = "/calandDistanceData.csv"
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
    
    //    ----------------------------- step Var -------------------    //
    private let dateFormatter = DateFormatter()

    private var fileDataExists = 0
    
    private var stepSum = 0
    private var distanceSum = 0
    
    private var resultStepSum = 0
    private var resultDistanceSum = 0
    
    private var currentFlag = 0
    
    private var preDate = ""
    private var splitPreDate:[Substring] = []
    
    private var targetDate:String = ""
    private var targetYear:String = ""
    private var targetMonth:String = ""
    private var targetDay:String = ""
    
    private var calendar = Calendar.current
    
    private var buttonList:[UIButton] = []

    private var timeTable: [String] = []

    private var targetStepData: [Double] = []
    private var targetDistanceData: [Double] = []
    private var targetTimeData: [String] = []
    
    //    ----------------------------- csv Var -------------------    //
    private var fileManager:FileManager = FileManager.default
    private var appendingPath = ""
    
    private lazy var documentsURL: URL = {
        return SummaryStep.initializeDocumentsURL()
    }()
    
    private var currentDirectoryURL: URL {
        return documentsURL.appendingPathComponent("\(appendingPath)")
    }
    
    private var arrDataFileURL: URL {
        return currentDirectoryURL.appendingPathComponent(STEPDATA_FILENAME)
    }
    
    //    ----------------------------- Chart -------------------    //
    lazy var stepChartView: BarChartView =  {
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
        let stackView = UIStackView(arrangedSubviews: [stepBackground, distanceBackground])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually // default
        stackView.alignment = .fill // default
        stackView.spacing = 5
        
        return stackView
    }()
    
    private let stepValueContents: UILabel = {
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
    
    private lazy var yesterdayButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    private lazy var tomorrowButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    // MARK: - bottom Contents
    private lazy var stepBackground: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stepLabel, stepProgress])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        return stackView
    }()
    
    private lazy var distanceBackground: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [distanceLabel, distanceProgress])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        return stackView
    }()
    
    private let stepProgress: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackTintColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0)
        progressView.progressTintColor = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
        
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 10
        progressView.layer.masksToBounds = true
        
        return progressView
    }()
    
    private let distanceProgress: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackTintColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0)
        progressView.progressTintColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
        
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 10
        progressView.layer.masksToBounds = true
        
        return progressView
    }()
    
    private let stepLabel:UILabel = {
        let label = UILabel()
        label.text = "summaryStep".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let distanceLabel:UILabel = {
        let label = UILabel()
        label.text = "distance".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let targetStep:UILabel = {
        let label = UILabel()
        label.text = "stepValue".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let targetDistance:UILabel = {
        let label = UILabel()
        label.text = "distanceValue3".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let walkCount:UILabel = {
        let label = UILabel()
        label.text = "stepValue".localized()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let walkDistance:UILabel = {
        let label = UILabel()
        label.text = "distanceValue3".localized()
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
        dailyStepChart()
    }
    
    func refreshView() {
        initVar()
        initArray()
        addViews()
        dailyStepChart()
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
        
        targetStep.text = "\(UserProfileManager.shared.getStep()) \("stepValue2".localized())"
        targetDistance.text = "\(UserProfileManager.shared.getDistance()) \("distanceValue2".localized())"
        
        setButtonColor(dayButton)
    }
    
    // MARK: - CHART
    func dailyStepChart() {
        
        setDisplayText(changeDateFormat("\(targetYear)-\(targetMonth)-\(targetDay)", YEAR_FORMAT))
        
        if fileExists() {
            
            getFileData(path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)")
            displayChart()
            
            setUI(day: 1, stepSum: stepSum, distanceSum: distanceSum)
            
        } else {
            // 파일 없음
        }
    }

    func weeklyStepChart() {
        
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
            setUI(day: 7 - fileDataExists, stepSum: resultStepSum, distanceSum: resultDistanceSum)
        } else {
            // 파일 없음
        }
    }
    
    func monthlyStepChart() {
        
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
            setUI(day: numDay - fileDataExists, stepSum: resultStepSum, distanceSum: resultDistanceSum)
        } else {
            // 파일 없음
        }
    }
    
    func yearlyStepChart() {
        
        setDisplayText(targetYear)
        
        var monthlyStep = 0
        var monthlyDistance = 0
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
                        monthlyStep += stepSum
                        monthlyDistance += distanceSum
                        stepSum = 0
                        distanceSum = 0
                        
                        fileExistsCheck += 1
                    }
                    
                    if day != numberOfDaysInMonth {  dateCalculate(targetDate, 1, ADD_DATE, .day) }
                }
                
                resultStepSum += monthlyStep
                resultDistanceSum += monthlyDistance
                
                targetStepData.append(Double(monthlyStep))
                targetDistanceData.append(Double(monthlyDistance))
                targetTimeData.append(String(month))
                
                monthlyStep = 0
                monthlyDistance = 0
                
            } else {
                // 디렉토리 없음
                fileDataExists += 1
            }
            
            dateCalculate(targetDate, 1, ADD_DATE, .month)
        }
        
        if fileDataExists != 12 {
            displayChart()
            setUI(day: fileExistsCheck, stepSum: resultStepSum, distanceSum: resultDistanceSum)
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
            let fileData = try String(contentsOf: arrDataFileURL)
            let separatedData = fileData.components(separatedBy: .newlines)
            
            for i in 0 ..< separatedData.count {
                let row = separatedData[i]
                let columns = row.components(separatedBy: ",")
                
                let step = Double(columns[2].trimmingCharacters(in: .whitespacesAndNewlines))
                let distance = Double(columns[3].trimmingCharacters(in: .whitespacesAndNewlines))
                
                sumStepAndDistance(Int(step ?? 0), Int(distance ?? 0))

                if currentFlag == DAY_FLAG {
                    targetStepData.append(step ?? 0.0)
                    targetDistanceData.append(distance ?? 0.0)
                    targetTimeData.append(columns[0])
                }
            }
        } catch  {
            print("Error reading CSV file")
        }
    }
        
    func setUI(day: Int, stepSum: Int, distanceSum: Int){
        let stepGoal = UserProfileManager.shared.getStep()
        let distanceGaol = UserProfileManager.shared.getDistance()
        
        // Progress
        let dailyStepRatio = Double(stepSum) / Double(stepGoal * day)
        stepProgress.progress = Float(dailyStepRatio)
        
        let dailyDistanceRatio = (Double(distanceSum) / 1000.0) / Double(distanceGaol * day)
        distanceProgress.progress = Float(dailyDistanceRatio)
        
        // text
        targetStep.text = "\(stepGoal) \("stepValue2".localized())"
        walkCount.text = "\(stepSum) \("stepValue2".localized())"
        targetDistance.text = "\(distanceGaol) \("distanceValue2".localized())"
        walkDistance.text = "\(distanceSum) \("distanceM2".localized())"
    }
    
    func displayChart() {
        var stepEntry = [BarChartDataEntry]()
        var distanceEntry = [BarChartDataEntry]()
        
        for i in 0 ..< targetStepData.count {
            let stepDataEntry = BarChartDataEntry(x: Double(i), y: targetStepData[i])
            let distanceDataEntry = BarChartDataEntry(x: Double(i), y: targetDistanceData[i])
            stepEntry.append(stepDataEntry)
            distanceEntry.append(distanceDataEntry)
        }

        // set ChartData
        let stepChartDataSet = chartDataSet(color: NSUIColor.GRAPH_RED, chartDataSet: BarChartDataSet(entries: stepEntry, label: "step".localized()))
        let distanceChartDataSet = chartDataSet(color: NSUIColor.GRAPH_BLUE, chartDataSet: BarChartDataSet(entries: distanceEntry, label: "distanceM".localized()))
        
        let dataSets: [BarChartDataSet] = [stepChartDataSet, distanceChartDataSet]
        
        setChart(chartData: BarChartData(dataSets: dataSets),
                 labelCnt: targetStepData.count)
    }
    
    func fetchDailyFileData(startDay: Int, numDay: Int) {
        
        for i in startDay...numDay {
            if fileExists() {
                getFileData(path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)")
                targetStepData.append(Double(stepSum))
                targetDistanceData.append(Double(distanceSum))
                currentFlag == WEEK_FLAG ? targetTimeData.append(weekDays[i]) : targetTimeData.append(String(i))
            } else {
                switch (currentFlag){
                case MONTH_FLAG:
                    fileDataExists += 1
                default: // WEEK_FLAG
                    targetStepData.append(0.0)
                    targetDistanceData.append(0.0)
                    targetTimeData.append(weekDays[i])
                    fileDataExists += 1
                }
            }
            
            resultStepSum += stepSum
            resultDistanceSum += distanceSum
            
            stepSum = 0
            distanceSum = 0

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
        
        stepChartView.xAxis.axisMinimum = Double(0)
        stepChartView.xAxis.axisMaximum = Double(0) + chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(targetStepData.count)  // group count : 2
        chartData.groupBars(fromX: Double(0), groupSpace: groupSpace, barSpace: barSpace)
        
        stepChartView.legend.font = .systemFont(ofSize: 15, weight: .bold)
        
        stepChartView.data = chartData
        stepChartView.xAxis.enabled = true
        stepChartView.xAxis.centerAxisLabelsEnabled = true
        stepChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: targetTimeData)
        stepChartView.xAxis.granularity = 1
        stepChartView.xAxis.setLabelCount(targetStepData.count, force: false)
        stepChartView.xAxis.labelPosition = .bottom
        stepChartView.xAxis.drawGridLinesEnabled = false
        
        stepChartView.leftAxis.granularityEnabled = true
        stepChartView.leftAxis.granularity = 1.0
        
        stepChartView.leftAxis.axisMinimum = 0
        stepChartView.rightAxis.enabled = false
        stepChartView.drawMarkers = false
        stepChartView.dragEnabled = false
        stepChartView.pinchZoomEnabled = false
        stepChartView.doubleTapToZoomEnabled = false
        stepChartView.highlightPerTapEnabled = false
        
        stepChartView.data?.notifyDataChanged()
        stepChartView.notifyDataSetChanged()
        stepChartView.moveViewToX(0)
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
            weeklyStepChart()
        case MONTH_FLAG:
            monthlyStepChart()
        case YEAR_FLAG:
            yearlyStepChart()
        default:
            dailyStepChart()
        }
    }
    
    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool, _ type: Calendar.Component) {
        
        guard let inputDate = dateFormatter.date(from: date) else { return }
        let dayValue = shouldAdd ? day : -day
        if let stepTargetDate = calendar.date(byAdding: type, value: dayValue, to: inputDate) {
            
            let components = calendar.dateComponents([.year, .month, .day], from: stepTargetDate)
            
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
        return fileManager.fileExists(atPath: arrDataFileURL.path)
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
    
    func sumStepAndDistance(_ step: Int, _ distance: Int) {
        stepSum += step
        distanceSum += distance
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
        if let range = calendar.range(of: .day, in: .month, for: inputDate) {
            return range.count
        } else {
            return nil
        }
    }
    
    func findFirstDayOfMonth(_ date: String) -> Int? {
        guard let inputDate = dateFormatter.date(from: date) else { return nil}
        let currentDayComponent = calendar.component(.day, from: inputDate)
        return  currentDayComponent - 1
    }
    
    func compareMonth() -> Bool {
        return currentYear == targetYear && currentMonth == targetMonth ? true : false
    }
    
    func initArray() {
        stepChartView.clear()

        stepSum = 0
        distanceSum = 0
        
        resultStepSum = 0
        resultDistanceSum = 0
        
        fileDataExists = 0
        
        preDate = ""
        
        timeTable.removeAll()

        targetStepData.removeAll()
        targetDistanceData.removeAll()
        targetTimeData.removeAll()
        
        setUI(day: 1, stepSum: stepSum, distanceSum: distanceSum)
    }
    
    public static func initializeDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - addViews
    func addViews() {
        view.addSubview(stepChartView)

        view.addSubview(bottomLabel)
        bottomLabel.addSubview(topContents)
        bottomLabel.addSubview(middleContents)
        bottomLabel.addSubview(bottomContents)
        bottomLabel.addSubview(stepValueContents)
        
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
        yesterdayButton.tag = YESTERDAY_BUTTON_FLAG
        tomorrowButton.tag = TOMORROW_BUTTON_FLAG
        
        middleContents.addSubview(yesterdayButton)
        middleContents.addSubview(tomorrowButton)
        middleContents.addSubview(todayDispalay)
        
        // --------------------- bottomContents --------------------- //
        stepValueContents.addSubview(targetStep)
        stepValueContents.addSubview(targetDistance)
        
        stepValueContents.addSubview(walkCount)
        stepValueContents.addSubview(walkDistance)
        
        stepValueContents.addSubview(bottomLine)
        
        setConstraints()
    }
    
    // MARK: - Constraints
    func setConstraints(){
        
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneFourthWidth = screenWidth / 4.0
        
        stepChartView.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topContents.translatesAutoresizingMaskIntoConstraints = false
        middleContents.translatesAutoresizingMaskIntoConstraints = false
        bottomContents.translatesAutoresizingMaskIntoConstraints = false
        
        dayButton.translatesAutoresizingMaskIntoConstraints = false
        weekButton.translatesAutoresizingMaskIntoConstraints = false
        monthButton.translatesAutoresizingMaskIntoConstraints = false
        yearButton.translatesAutoresizingMaskIntoConstraints = false
        
        yesterdayButton.translatesAutoresizingMaskIntoConstraints = false
        tomorrowButton.translatesAutoresizingMaskIntoConstraints = false
        todayDispalay.translatesAutoresizingMaskIntoConstraints = false
        
        stepValueContents.translatesAutoresizingMaskIntoConstraints = false
        
        walkCount.translatesAutoresizingMaskIntoConstraints = false
        walkDistance.translatesAutoresizingMaskIntoConstraints = false
        
        targetStep.translatesAutoresizingMaskIntoConstraints = false
        targetDistance.translatesAutoresizingMaskIntoConstraints = false
        
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            // --------------------- set Weight --------------------- //
            // chart
            stepChartView.topAnchor.constraint(equalTo: safeAreaView.topAnchor),
            stepChartView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            stepChartView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            stepChartView.heightAnchor.constraint(equalTo: safeAreaView.heightAnchor, multiplier: 5.5 / (5.5 + 4.5)),

            // bottomLabel
            bottomLabel.topAnchor.constraint(equalTo: stepChartView.bottomAnchor),
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
            yesterdayButton.topAnchor.constraint(equalTo: middleContents.topAnchor),
            yesterdayButton.leadingAnchor.constraint(equalTo: middleContents.leadingAnchor, constant: 10),
            yesterdayButton.bottomAnchor.constraint(equalTo: middleContents.bottomAnchor),
            
            // tomorrowButton
            tomorrowButton.topAnchor.constraint(equalTo: middleContents.topAnchor),
            tomorrowButton.trailingAnchor.constraint(equalTo: middleContents.trailingAnchor, constant: -10),
            tomorrowButton.bottomAnchor.constraint(equalTo: middleContents.bottomAnchor),
            
            // --------------------- bottom Contents --------------------- //
            
            stepValueContents.topAnchor.constraint(equalTo: bottomContents.topAnchor),
            stepValueContents.leadingAnchor.constraint(equalTo: bottomContents.trailingAnchor),
            stepValueContents.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            stepValueContents.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor),
            
            walkCount.centerXAnchor.constraint(equalTo: stepValueContents.centerXAnchor),
            walkCount.centerYAnchor.constraint(equalTo: stepLabel.centerYAnchor),
            
            targetStep.centerXAnchor.constraint(equalTo: stepValueContents.centerXAnchor),
            targetStep.centerYAnchor.constraint(equalTo: stepProgress.centerYAnchor),
            
            walkDistance.centerXAnchor.constraint(equalTo: stepValueContents.centerXAnchor),
            walkDistance.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor),
            
            targetDistance.centerXAnchor.constraint(equalTo: stepValueContents.centerXAnchor),
            targetDistance.centerYAnchor.constraint(equalTo: distanceProgress.centerYAnchor),
            
            bottomLine.centerYAnchor.constraint(equalTo: stepValueContents.centerYAnchor),
            bottomLine.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor, constant: 10),
            bottomLine.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -10),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}
