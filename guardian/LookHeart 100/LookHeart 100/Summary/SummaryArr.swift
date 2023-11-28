import UIKit
import Foundation
import DGCharts
import SnapKit
import Then

let weekDays = ["Monday".localized(), "Tuesday".localized(), "Wednesday".localized(), "Thursday".localized(), "Friday".localized(), "Saturday".localized(), "Sunday".localized()]

class SummaryArr : BaseViewController, Refreshable {
    
    private let ARRDATA_FILENAME = "/calandDistanceData.csv"
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
    
    //    ----------------------------- arr Var -------------------    //
    private let dateFormatter = DateFormatter()
    
    private var arrCount = 0
    private var arrSum = 0
    private var fileDataExists = 0
    
    private var currentFlag = 0
    
    private var preDate = ""
    private var splitPreDate:[Substring] = []
    
    private var targetDate:String = ""
    private var targetYear:String = ""
    private var targetMonth:String = ""
    private var targetDay:String = ""
    
    private var arrCalendar = Calendar.current
    
    private var buttonList:[UIButton] = []
    
    private var earliestStartTime = ""
    private var latestEndTime = ""
    
    private var timeTable: [String] = []
    
    private var arrTimeCount = 0
    private var timeTableCount = 0
    
    private var targetArrData: [Double] = []
    private var targetArrTimeData: [String] = []
    
    //    ----------------------------- csv Var -------------------    //
    private var fileManager:FileManager = FileManager.default
    private var appendingPath = ""
    
    private lazy var documentsURL: URL = {
        return SummaryArr.initializeDocumentsURL()
    }()
    
    private var currentDirectoryURL: URL {
        return documentsURL.appendingPathComponent("\(appendingPath)")
    }
    
    private var arrDataFileURL: URL {
        return currentDirectoryURL.appendingPathComponent(ARRDATA_FILENAME)
    }
    
    //    ----------------------------- Chart -------------------    //
    lazy var arrChartView: BarChartView =  {
        let chartView = BarChartView()
        chartView.noDataText = ""
        chartView.xAxis.enabled = true
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.legend.font = .systemFont(ofSize: 15, weight: .bold)
        chartView.leftAxis.granularityEnabled = true
        chartView.leftAxis.granularity = 1.0
        chartView.leftAxis.axisMinimum = 0
        chartView.rightAxis.enabled = false
        chartView.drawMarkers = false
        chartView.dragEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = false
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
        let stackView = UIStackView(arrangedSubviews: [arrCntLabel, arrCnt])
        stackView.axis = .horizontal
//        stackView.alignment = .center
        stackView.distribution = .fillEqually // default
        stackView.alignment = .fill // default
        return stackView
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
    
    private lazy var yesterdayArrButton = UIButton().then {
        $0.setImage(leftArrow, for: UIControl.State.normal)
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    private lazy var tomorrowArrButton = UIButton().then {
        $0.setImage(rightArrow, for: UIControl.State.normal)
        $0.addTarget(self, action: #selector(shiftDate(_:)), for: .touchUpInside)
    }
    
    // MARK: - bottom Contents
    private let arrCntLabel: UILabel = {
        let label = UILabel()
        label.text = "arrTimes".localized()
        label.numberOfLines = 2
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let arrCnt: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
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

        dailyArrChart()
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
        
        setButtonColor(dayButton)
    }
    
    func refreshView() {
        initVar()
        initArray()
        addViews()
        dailyArrChart()
    }
    
    // MARK: - CHART
    func dailyArrChart() {
        
        setDisplayText(changeDateFormat("\(targetYear)-\(targetMonth)-\(targetDay)", YEAR_FORMAT))
        
        if fileExists() {
            
            getFileData(
                path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)",
                arrData: &targetArrData,
                timeData: &targetArrTimeData)
            
            var arrDataEntries = [BarChartDataEntry]()
            
            for i in 0 ..< targetArrData.count {
                let arrDataEntry = BarChartDataEntry(x: Double(i), y: targetArrData[i])
                arrDataEntries.append(arrDataEntry)
            }

            // set ChartData
            let arrChartDataSet = chartDataSet(color: NSUIColor.MY_RED, chartDataSet: BarChartDataSet(entries: arrDataEntries, label: "arr".localized()))
                        
            timeTable = targetArrTimeData
            setChart(chartData: BarChartData(dataSet: arrChartDataSet),
                     labelCnt: targetArrData.count)
            
            arrCnt.text = String(arrCount)
            
        } else {
            // 파일 없음
        }
    }

    func weeklyArrChart() {
        
        let monday = findMonday()
        
        dateCalculate(targetDate, monday, MINUS_DATE, .day)
        preDate = targetDate
        let mondayMonth = targetMonth
        let mondayDay = targetDay
        
        fetchDailyFileData(startDay: 0,
                      numDay: 6,
                      arrData: &targetArrData,
                      arrTimeData: &targetArrTimeData,
                      arrCnt: &arrSum,
                      noDataCheck: &fileDataExists)
        
        setDisplayText("\(changeDateFormat("\(mondayMonth).\(mondayDay)", MONTH_FORMAT)) ~ \(changeDateFormat("\(targetMonth).\(targetDay)", MONTH_FORMAT))")
        
        dateCalculate(preDate, monday, ADD_DATE, .day)
        
        if !(fileDataExists == 7) {
            displayChart()
        } else {
            // 파일 없음
        }
        arrCnt.text = String(arrSum)
    }
    
    func monthlyArrChart() {
        
        setDisplayText(changeDateFormat("\(targetYear).\(targetMonth)", MONTH_FORMAT))
        
        var numDay = 0 // 해당 월에 며칠인지 확인하는 변수
        let firstDay = findFirstDayOfMonth(targetDate)! // 1일까지 찾는 변수
        
        if compareMonth() { numDay = Int(currentDay)!   }
        else {  numDay = findNumDay(targetDate)!    }
        
        dateCalculate(targetDate, firstDay, MINUS_DATE, .day)
        preDate = targetDate
        
        fetchDailyFileData(startDay: 1,
                      numDay: numDay,
                      arrData: &targetArrData,
                      arrTimeData: &targetArrTimeData,
                      arrCnt: &arrSum,
                      noDataCheck: &fileDataExists)
        
        dateCalculate(preDate, firstDay, ADD_DATE, .day)
        
        if !(fileDataExists == numDay) {
            displayChart()
        } else {
            // 파일 없음
        }
        
        arrCnt.text = String(arrSum)
    }
    
    func yearlyArrChart() {
        
        setDisplayText(targetYear)
        
        var monthlyArrCnt = 0
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
                        monthlyArrCnt += arrCount
                        arrCount = 0
                    }
                    
                    if day != numberOfDaysInMonth {  dateCalculate(targetDate, 1, ADD_DATE, .day) }
                }
                
                arrSum += monthlyArrCnt
                targetArrData.append(Double(monthlyArrCnt))
                targetArrTimeData.append(String(month))
                
                monthlyArrCnt = 0
                
            } else {
                // 디렉토리 없음
                fileDataExists += 1
            }
            
            dateCalculate(targetDate, 1, ADD_DATE, .month)
        }
        
        if fileDataExists != 12 {
            displayChart()
        } else {
            // 데이터 없음
        }
        
        arrCnt.text = String(arrSum)
        
        targetDate = splitPreDate.joined(separator: "-")
        targetYear = String(splitPreDate[0])
        targetMonth = String(splitPreDate[1])
        targetDay = String(splitPreDate[2])
    }
    
    // MARK: - CHART FUNC
    func getFileData(path: String, arrData: inout [Double], timeData: inout [String]) {

//        print("arrData : \(path)")
        do {
            appendingPath = path
            let fileData = try String(contentsOf: arrDataFileURL)
            let separatedData = fileData.components(separatedBy: .newlines)
            
            for i in 0 ..< separatedData.count {
                let row = separatedData[i]
                let columns = row.components(separatedBy: ",")
                let arrCnt = Double(columns[6].trimmingCharacters(in: .whitespacesAndNewlines))
                
                sumArrCnt(Int(arrCnt ?? 0))
                
                arrData.append(arrCnt ?? 0.0)
                timeData.append(columns[0])
            }
        } catch  {
            print("Error reading CSV file")
        }
    }
    
    func getFileData(path: String) {

        do {
            appendingPath = path
            let fileData = try String(contentsOf: arrDataFileURL)
            let separatedData = fileData.components(separatedBy: .newlines)
            
            for i in 0 ..< separatedData.count {
                let row = separatedData[i]
                let columns = row.components(separatedBy: ",")
                let arrCnt = Double(columns[6].trimmingCharacters(in: .whitespacesAndNewlines))
                
                sumArrCnt(Int(arrCnt ?? 0))
            }
        } catch  {
            print("Error reading CSV file")
        }
    }
    
    func displayChart() {
        var arrDataEntries = [BarChartDataEntry]()
        for i in 0 ..< targetArrData.count {
            let arrDataEntry = BarChartDataEntry(x: Double(i), y: targetArrData[i])
            arrDataEntries.append(arrDataEntry)
        }
        
        // set ChartData
        let arrChartDataSet = chartDataSet(color: NSUIColor.MY_RED, chartDataSet: BarChartDataSet(entries: arrDataEntries, label: "arr".localized()))
                    
        timeTable = targetArrTimeData
        setChart(chartData: BarChartData(dataSet: arrChartDataSet),
                 labelCnt: targetArrData.count)
    }
    
    func fetchDailyFileData(startDay: Int, numDay: Int, arrData: inout [Double], arrTimeData: inout [String], arrCnt: inout Int, noDataCheck: inout Int) {
        
        for i in startDay...numDay {
            if fileExists() {
                getFileData(path: "\(email)/\(targetYear)/\(targetMonth)/\(targetDay)")
                arrData.append(Double(arrCount))
                currentFlag == WEEK_FLAG ? arrTimeData.append(weekDays[i]) : arrTimeData.append(String(i))
            } else {
                switch (currentFlag){
                case MONTH_FLAG:
                    noDataCheck += 1
                default: // WEEK_FLAG
                    arrData.append(0.0)
                    arrTimeData.append(weekDays[i])
                    noDataCheck += 1
                }
            }
            
            arrCnt += arrCount
            arrCount = 0
            if i != numDay {  dateCalculate(targetDate, 1, ADD_DATE, .day) }
        }
    }

    func chartDataSet(color: NSUIColor, chartDataSet: BarChartDataSet) -> BarChartDataSet {
        chartDataSet.setColor(color)
        chartDataSet.drawValuesEnabled = true
        chartDataSet.valueFormatter = IntegerValueFormatter()
        chartDataSet.valueFormatter = NonZeroValueFormatter()
        
        return chartDataSet
    }
    
    func setChart(chartData: BarChartData, labelCnt: Int) {
        arrChartView.data = chartData
        arrChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
        arrChartView.xAxis.setLabelCount(labelCnt, force: false)
        arrChartView.data?.notifyDataChanged()
        arrChartView.notifyDataSetChanged()
        arrChartView.moveViewToX(0)
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
            weeklyArrChart()
        case MONTH_FLAG:
            monthlyArrChart()
        case YEAR_FLAG:
            yearlyArrChart()
        default:
            dailyArrChart()
        }
    }
    
    func dateCalculate(_ date: String, _ day: Int, _ shouldAdd: Bool, _ type: Calendar.Component) {
        
        guard let inputDate = dateFormatter.date(from: date) else { return }
        let dayValue = shouldAdd ? day : -day
        if let arrTargetDate = arrCalendar.date(byAdding: type, value: dayValue, to: inputDate) {
            
            let components = arrCalendar.dateComponents([.year, .month, .day], from: arrTargetDate)
            
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
    
    func sumArrCnt(_ cnt: Int) {
        arrCount += cnt
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
        if let range = arrCalendar.range(of: .day, in: .month, for: inputDate) {
            return range.count
        } else {
            return nil
        }
    }
    
    func findFirstDayOfMonth(_ date: String) -> Int? {
        guard let inputDate = dateFormatter.date(from: date) else { return nil}
        let currentDayComponent = arrCalendar.component(.day, from: inputDate)
        return  currentDayComponent - 1
    }
    
    func compareMonth() -> Bool {
        return currentYear == targetYear && currentMonth == targetMonth ? true : false
    }
    
    func initArray() {
        
        arrChartView.clear()
        
        arrCount = 0
        arrSum = 0
        fileDataExists = 0
        
        earliestStartTime = ""
        latestEndTime = ""
        preDate = ""
        
        arrTimeCount = 0
        timeTableCount = 0
        
        timeTable.removeAll()
        
        targetArrData.removeAll()
        targetArrTimeData.removeAll()
        
        arrCnt.text = String(arrCount)
    }
    
    public static func initializeDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - addViews
    func addViews() {
        view.addSubview(arrChartView)

        view.addSubview(bottomLabel)
        bottomLabel.addSubview(topContents)
        bottomLabel.addSubview(middleContents)
        bottomLabel.addSubview(bottomContents)
        
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
        yesterdayArrButton.tag = YESTERDAY_BUTTON_FLAG
        tomorrowArrButton.tag = TOMORROW_BUTTON_FLAG
        
        middleContents.addSubview(yesterdayArrButton)
        middleContents.addSubview(tomorrowArrButton)
        middleContents.addSubview(todayDispalay)
        
        // --------------------- bottomContents --------------------- //
        
        setConstraints()
    }
    
    // MARK: - Constraints
    func setConstraints(){
        
        let totalMultiplier = 4.0 // 1.0, 1.0, 2.0
        let singlePortion = 1.0 / totalMultiplier
        
        let screenWidth = UIScreen.main.bounds.width // Screen width
        let oneFourthWidth = screenWidth / 4.0
        
        arrChartView.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topContents.translatesAutoresizingMaskIntoConstraints = false
        middleContents.translatesAutoresizingMaskIntoConstraints = false
        bottomContents.translatesAutoresizingMaskIntoConstraints = false
        
        dayButton.translatesAutoresizingMaskIntoConstraints = false
        weekButton.translatesAutoresizingMaskIntoConstraints = false
        monthButton.translatesAutoresizingMaskIntoConstraints = false
        yearButton.translatesAutoresizingMaskIntoConstraints = false
        
        yesterdayArrButton.translatesAutoresizingMaskIntoConstraints = false
        tomorrowArrButton.translatesAutoresizingMaskIntoConstraints = false
        todayDispalay.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            // --------------------- set Weight --------------------- //
            // chart
            arrChartView.topAnchor.constraint(equalTo: safeAreaView.topAnchor),
            arrChartView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            arrChartView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            arrChartView.heightAnchor.constraint(equalTo: safeAreaView.heightAnchor, multiplier: 5.5 / (5.5 + 4.5)),

            // bottomLabel
            bottomLabel.topAnchor.constraint(equalTo: arrChartView.bottomAnchor),
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
            yesterdayArrButton.topAnchor.constraint(equalTo: middleContents.topAnchor),
            yesterdayArrButton.leadingAnchor.constraint(equalTo: middleContents.leadingAnchor, constant: 10),
            yesterdayArrButton.bottomAnchor.constraint(equalTo: middleContents.bottomAnchor),
            
            // tomorrowButton
            tomorrowArrButton.topAnchor.constraint(equalTo: middleContents.topAnchor),
            tomorrowArrButton.trailingAnchor.constraint(equalTo: middleContents.trailingAnchor, constant: -10),
            tomorrowArrButton.bottomAnchor.constraint(equalTo: middleContents.bottomAnchor),
            
            // --------------------- bottom Contents --------------------- //

        ])
    }
}

// bar 상단에 보여지는 value 값을 정수로 표시
class IntegerValueFormatter: DefaultValueFormatter {
    override func stringForValue(_ value: Double,
                                 entry: ChartDataEntry,
                                 dataSetIndex: Int,
                                 viewPortHandler: ViewPortHandler?) -> String {
        return String(format: "%.0f", value)
    }
}
// bar 상단에 보여지는 value 값을 0이 아닌 경우에만 표시
class NonZeroValueFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return value == 0 ? "" : String(format: "%.0f", value)
    }
}
