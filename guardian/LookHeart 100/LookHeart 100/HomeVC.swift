import UIKit
import LookheartPackage
import DGCharts
import Foundation
import AVFoundation
import UserNotifications

protocol AppDelegateDelegate: AnyObject {
    func startLoop()
    func stopLoop()
}

var guardianTime:String = propCurrentDate
var appStart = false

class MainViewController: BaseViewController, AppDelegateDelegate {
        
    private let STATE_CAUT = true
    private let STATE_WARN = false
    
    private let TEN_SECOND = 10
    private let BPM_GRAPH_MAX = 250

    private var isBpmTimeRequest = false, isTotalHealthDataRequest = false
    
    private var bpmLastLines: [Double] = []
    
    private var bpmTimer: Timer?
    private var preWriteTime = ""
    private var activityCnt = 0 // 사용자 앱 사용 유무 확인
    private var secondCnt = 0
    
    private var temp = 0.0
    private var arrCnt = 0
    private var yesterdayArrCnt = 0
    
    // MARK: -
    private var chartView: LineChartView?
    private var bpmValue: UILabel?
    
    private var arrHeartImg: UIImageView?, arrHeartFillImg: UIImageView?
    private var arrValue: UILabel?, arrState: UILabel?
    
    private var yesterdayCntLabel: UILabel?, yesterdayComparison: UILabel?
    
    private var restButton: UIButton?, activityButton: UIButton?, sleepButton: UIButton?

    private var calValue: UILabel?, stepValue: UILabel?, temperatureValue: UILabel?, distanceValue: UILabel?
    
    
    // MARK: - Button Event
    @objc func bodyStateEvent(_ sender: UIButton) {
        let buttons = [restButton!, activityButton!, sleepButton!]
        
        for button in buttons {
            if button == sender {
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = UIColor.MY_BODY_STATE
                button.tintColor = .white
            } else {
                button.setTitleColor(.lightGray, for: .normal)
                button.backgroundColor = UIColor.MY_LIGHT_GRAY_BORDER
                button.tintColor = .lightGray
            }
        }
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.delegate = self
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.delegate = self
        }
        
        addViews()
        loadUserData()
        
    }
    
    // MARK: - Delegate
    func startLoop() {
        startBpmLoop()
    }
    
    func stopLoop() {
        stopBpmLoop()
    }
    
    // MARK: - Loop
    private func startBpmLoop() {
        if bpmTimer != nil {
            stopBpmLoop()
        }
        
        bpmTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(secondAction), userInfo: nil, repeats: true)
    }
    
    public func stopBpmLoop() {
        bpmTimer?.invalidate()
        bpmTimer = nil
    }
    
    @objc func secondAction() {
        
        secondCnt += 1
        responseBpmTime()
        
        if secondCnt == TEN_SECOND {
            secondCnt = 0
            responseHourlyData()
        }
    }
        
    // MARK: -
    private func checkUserActivity(bpm: Int) {
        
        if preWriteTime == guardianTime {
            activityCnt += 1
            
            if activityCnt == 5 {
                activityCnt = 0
                
                stopTask()
            }
        } else {
            activityCnt = 0
            
            preWriteTime = guardianTime
            
            updateBpmChart(bpm: bpm)
        }
    }
    
    private func stopTask() {
        
        stopBpmLoop()
        
        propAlert.basicAlert(title: "noti".localized(), message: "\("BleDisconnected".localized()) \(preWriteTime)", ok: "ok".localized(), viewController: self)
    }
    
    // MARK: - Response
    private func responseBpmTime() {
        guard !isBpmTimeRequest else {   return  } // 순차실행 Flag
        isBpmTimeRequest = true

        NetworkManager.shared.getBpmTime(id: propEmail) { [self] result in
            isBpmTimeRequest = false
            
            switch(result){
            case .success(let bpmTime):
                
                temp = bpmTime.temp
                guardianTime = bpmTime.writetime
                
                checkUserActivity(bpm: bpmTime.bpm)
                
            case .failure(let error):
                print("responseRealBPM error : \(error)")
            }
        }
    }
    
    private func responseHourlyData() {
        guard !isTotalHealthDataRequest else {   return  } // 순차실행 Flag
        isTotalHealthDataRequest = true
        
        let date = getDate(flag: true)
        let startDate = date.0
        let endDate = date.1
        
        NetworkManager.shared.getTotalHealthData(startDate: startDate, endDate: endDate) { [self] result in
            isTotalHealthDataRequest = false
            
            switch(result){
            case .success(let data):
                
                arrCnt = data.arrCnt
                updateHourlyUI(step: data.step, distance: data.distance, aCal: data.activityCal)
                
            case .failure(let error):
                print("responseBpmData error : \(error)")
            }
        }

    }
    
    private func getDate(flag: Bool) -> (String, String) {
        let startDate = String(guardianTime.split(separator: " ")[0])
        let endDate = MyDateTime.shared.dateCalculate(startDate, 1, flag)
        return (startDate, endDate)
    }
    
    // MARK: - UpdateUI
    private func updateBpmChart(bpm: Int) {
        DispatchQueue.main.async { [self] in
            bpmValue?.text = String(bpm)
            
            let doubleBpm = Double(bpm)
            
            if bpmLastLines.count > BPM_GRAPH_MAX {
                bpmLastLines.removeFirst()
            }
            
            bpmLastLines.append(doubleBpm)
                    
            var entries: [ChartDataEntry] = []
            for i in 0..<bpmLastLines.count {
                entries.append(ChartDataEntry(x: Double(i), y: bpmLastLines[i]))
            }
            
            let dataSet = LineChartDataSet(entries: entries, label: "BPM")
            dataSet.drawCirclesEnabled = false
            dataSet.colors = [NSUIColor.blue]
            dataSet.lineWidth = 1.0
            dataSet.drawValuesEnabled = false

            chartView!.data = LineChartData(dataSet: dataSet)
            chartView!.notifyDataSetChanged()
            
            updateBodyState(bpm: bpm)
        }
    }
    
    private func updateBodyState(bpm: Int) {
        
        func isInSleepTime(_ hour: Int) -> Bool {
            // Check Sleep
            let bedTime = propProfil.bedTime
            let wakeUpTime = propProfil.wakeUpTime
            return hour >= bedTime || hour < wakeUpTime
        }
        
        func setBodyStateBasedOnBpm(_ bpm: Int) {
            let targetBpm = UserProfileManager.shared.targetBpm
            
            if bpm >= targetBpm {
                // Active
                bodyStateEvent(activityButton!)
            } else {
                // Rest
                bodyStateEvent(restButton!)
            }
        }
        
        let currentHour = Int(MyDateTime.shared.getSplitDateTime(.TIME)[0])
        
        if isInSleepTime(currentHour!) {
            bodyStateEvent(sleepButton!)
        } else {
            setBodyStateBasedOnBpm(bpm)
        }
    }
    
    
    private func updateHourlyUI(step: Int, distance: Int, aCal: Int) {
        let distanceKM = Double(distance) / 1000.0
        
        stepValue!.text = String(step) + " " + "summaryStep".localized()
        distanceValue!.text = String(format: "%.3f", distanceKM) + " " + "distanceValue2".localized()
        calValue!.text = String(aCal) + " " + "kcalValue".localized()
        arrValue!.text = String(arrCnt)
        temperatureValue!.text = String(format: "%.1f", temp) + " " + "temperatureValue2".localized()
        
        updateArrUI()
    }
    
    func updateArrUI() {
        
        func fillHeart(fill: Double) {
            let maskHeight = arrHeartFillImg!.frame.height * fill // fill height 설정
            let maskY = arrHeartFillImg!.frame.height - maskHeight // 시작 y 위치
            
            let maskLayer = CAShapeLayer()  // 마스크 레이어 생성 및 설정
            maskLayer.path = UIBezierPath(
                rect: CGRect(x: 0,
                             y: maskY,
                             width: arrHeartFillImg!.frame.width,
                             height: maskHeight)).cgPath
            maskLayer.fillColor = UIColor.white.cgColor // 마스킹 색상
            
            arrHeartFillImg!.layer.mask = maskLayer  // 적용
        }
        
        func setArrColor(text: String, stateFlag: Bool) {
            arrState!.text = text
            arrState!.textColor = stateFlag == STATE_CAUT ? UIColor.MY_BLUE : UIColor.MY_RED
            arrHeartImg!.tintColor = stateFlag == STATE_CAUT ? UIColor.MY_BLUE_BORDER : UIColor.MY_RED_BORDER
            arrHeartFillImg!.tintColor = stateFlag == STATE_CAUT ? UIColor.MY_SKY : UIColor.MY_PINK
        }
        
        func setFill() -> Double {
            if arrCnt < 50 {
                return Double(arrCnt * 2) / 100
            } else if arrCnt < 100 {
                setArrColor(text: "arrStatusCaution".localized(), stateFlag: STATE_CAUT)
                return Double(arrCnt - 50) / 100
            } else {
                setArrColor(text: "arrStatusWarning".localized(), stateFlag: STATE_WARN)
                return Double(arrCnt - 100) / 100
            }
        }
        
        let arrCntCheck = yesterdayArrCnt < arrCnt
        yesterdayComparison!.text = arrCntCheck ? "moreArr".localized() : "lessArr".localized()
        yesterdayComparison!.textColor = arrCntCheck ? UIColor.MY_RED : UIColor.MY_BLUE
        yesterdayCntLabel!.text = String(arrCntCheck ? arrCnt - yesterdayArrCnt : yesterdayArrCnt - arrCnt)

        
        fillHeart(fill: setFill())

    }
    
    
    // MARK: - load User Profile
    private func getYesterdayArrCnt() {
        let date = getDate(flag: false)
        let startDate = date.1
        let endDate = date.0
                
        ArrEmergencyManager.shared.getArrCnt(startDate: startDate, endDate: endDate) { [self] arrCnt, error in
            if let error = error {
                print(error)
                yesterdayArrCnt = 0
            } else if let arrCnt = arrCnt {
                appStart = true
                yesterdayArrCnt = arrCnt
                updateArrUI()
            }
        }
    }
    
    private func getGuardianTime() {
        NetworkManager.shared.getBpmTime(id: propEmail) { [self] result in
            switch(result){
            case .success(let bpmTime):
                
                guardianTime = bpmTime.writetime
                preWriteTime = bpmTime.writetime
                
                getYesterdayArrCnt()
                
                startBpmLoop()
                
                responseHourlyData()

                let date = getDate(flag: true)
                let startDate = date.0
                let endDate = date.1
                
                ArrEmergencyManager.shared.checkEmergency(startDate: startDate, endDate: endDate)
                                
                ToastHelper.shared.showToast(self.view, "loadUserData".localized())
                
            case .failure(let error):
                print("getGuardianTime error : \(error)")
                ToastHelper.shared.showToast(self.view, "failLoadUserData".localized())
            }
        }
    }
    
    private func loadUserData() {

        let identification = Keychain.shared.getString(forKey: "email") ?? "test"
        
        NetworkManager.shared.getProfileToServer(id: identification) { [self] result in
            switch(result){
            case .success(let user):
                
                propProfil.profile = user
                
                getGuardianTime()
                
                // Log
                if let guardian = Keychain.shared.getString(forKey: "phone") {
                    let isLogged = defaults.bool(forKey: "autoLoginFlag")
                    NetworkManager.shared.sendLog(id: propEmail, userType: .Guardian, action: isLogged ? .AutoLogin : .Login, phone: guardian)
                }                
                
            case .failure(let error):
                print("loadUserData error: \(error)")
            }
        }
    }
    
    //MARK: - AddViews
    func addViews() {
        
        /*------------------------- HeartRate Start ------------------------*/
        // Create
        let heartBackground = propCreateUI.backgroundLabel(backgroundColor: .clear, borderColor: UIColor.MY_BLUE.cgColor, borderWidth: 3, cornerRadius: 10)
        
        let heartImg = propCreateUI.imageView(tintColor: UIColor.MY_BLUE, backgroundColor: .white, contentMode: .scaleAspectFit).then {
            let image =  UIImage(named: "summary_bpm")!
            let coloredImage = image.withRenderingMode(.alwaysTemplate)
            $0.image = coloredImage
        }
        
        bpmValue = propCreateUI.label(text: "0", color: UIColor.MY_BLUE, size: 30, weight: .bold).then {
            $0.baselineAdjustment = .alignCenters
        }
        
        // AddSubview
        view.addSubview(heartBackground)
        view.addSubview(heartImg)
        
        // Constraints
        heartBackground.snp.makeConstraints { make in
            make.top.equalTo(safeAreaView.snp.top).offset(10)
            make.left.equalTo(safeAreaView).offset(10)
            make.right.equalTo(safeAreaView.snp.centerX).offset(-10)
            make.height.equalTo(80)
        }
        
        heartImg.snp.makeConstraints { make in
            make.top.equalTo(heartBackground).offset(-8)
            make.centerX.equalTo(heartBackground)
            make.width.equalTo(30)
        }
        
        if let bpmValue = bpmValue {
            view.addSubview(bpmValue)
            bpmValue.snp.makeConstraints { make in
                make.centerX.centerY.equalTo(heartBackground)
            }
        }
        /*------------------------- HeartRate End ------------------------*/
        
        
        /*------------------------- ARR Background Start ------------------------*/
        // Create
        let arrBackground = propCreateUI.backgroundLabel(backgroundColor: .clear, borderColor: UIColor.MY_RED.cgColor, borderWidth: 3, cornerRadius: 10).then {
            $0.backgroundColor = .white
        }
        
        let arrImg = propCreateUI.imageView(tintColor: UIColor.MY_RED, backgroundColor: .white, contentMode: .scaleAspectFit).then {
            let image =  UIImage(named: "summary_arr")!
            let coloredImage = image.withRenderingMode(.alwaysTemplate)
            $0.image = coloredImage
        }
        
        // AddSubview
        view.addSubview(arrBackground)
        view.addSubview(arrImg)
        
        // Constraints
        arrBackground.snp.makeConstraints { make in
            make.top.height.equalTo(heartBackground)
            make.left.equalTo(safeAreaView.snp.centerX).offset(10)
            make.right.equalTo(safeAreaView).offset(-10)
        }
        
        arrImg.snp.makeConstraints { make in
            make.centerX.equalTo(arrBackground)
            make.top.equalTo(arrBackground).offset(-8)
            make.width.equalTo(30)
        }
        /*------------------------- ARR Background End ------------------------*/
        
        
        /*------------------------- YESTERDAY ARR Start ------------------------*/
        // Create
        let yesterdayImgBackground = UILabel()
        let yesterdayContentsBackground = UILabel()
        
        arrHeartImg = propCreateUI.imageView(tintColor: UIColor.MY_GREEN_BORDER, backgroundColor: .clear, contentMode: .scaleAspectFit).then {
            let symbolConfig = UIImage.SymbolConfiguration(weight: .light)
            let symbolImage = UIImage(systemName: "heart", withConfiguration: symbolConfig)
            let coloredImage = symbolImage!.withRenderingMode(.alwaysTemplate)
            $0.image = coloredImage
        }

        arrHeartFillImg = propCreateUI.imageView(tintColor: UIColor.MY_GREEN, backgroundColor: .clear, contentMode: .scaleAspectFit).then {
            let symbolConfig = UIImage.SymbolConfiguration(weight: .light) // 두께 설정
            let symbolImage = UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)
            let coloredImage = symbolImage!.withRenderingMode(.alwaysTemplate)
            $0.image = coloredImage
        }
        
        arrState = propCreateUI.label(text: "arrStatusGood".localized(), color: UIColor.MY_GREEN_TEXT, size: 13, weight: .bold)
        
        yesterdayCntLabel = propCreateUI.label(text: "0", color: UIColor.MY_RED, size: 16, weight: .bold)
        
        let yesterdayUnit = propCreateUI.label(text: "time".localized(), color: .darkGray, size: 14, weight: .medium)
        
        yesterdayComparison = propCreateUI.label(text: "lessArr".localized(), color: UIColor.MY_BLUE, size: 16, weight: .heavy)
        
        let basedOnYesterday = propCreateUI.label(text: "basedOn".localized(), color: UIColor.MY_RED, size: 8, weight: .heavy)
        
        // AddSubview
        view.addSubview(yesterdayImgBackground)
        view.addSubview(yesterdayContentsBackground)
        
        // Constraints
        yesterdayImgBackground.snp.makeConstraints { make in
            make.top.bottom.left.equalTo(arrBackground)
            make.right.equalTo(arrBackground.snp.centerX)
        }
        
        yesterdayContentsBackground.snp.makeConstraints { make in
            make.top.bottom.right.equalTo(arrBackground)
            make.left.equalTo(arrBackground.snp.centerX)
        }
        
        // AddSubview & Constraints
        if let arrHeartImg = arrHeartImg, let arrHeartFillImg = arrHeartFillImg, let arrState = arrState {
            
            view.addSubview(arrHeartImg)
            view.addSubview(arrHeartFillImg)
            view.addSubview(arrState)
            
            arrHeartImg.snp.makeConstraints { make in
                make.top.left.equalTo(yesterdayImgBackground).offset(5)
                make.bottom.right.equalTo(yesterdayImgBackground).offset(-5)
            }
            
            arrHeartFillImg.snp.makeConstraints { make in
                make.top.equalTo(arrHeartImg).offset(4)
                make.left.equalTo(arrHeartImg).offset(2)
                make.right.equalTo(arrHeartImg).offset(-2)
                make.bottom.equalTo(arrHeartImg).offset(-5.5)
            }
            
            arrState.snp.makeConstraints { make in
                make.centerX.centerY.equalTo(arrHeartImg)
            }
        }
        
        if let yesterdayCntLabel = yesterdayCntLabel, let yesterdayComparison = yesterdayComparison {
            
            view.addSubview(yesterdayCntLabel)
            view.addSubview(yesterdayUnit)
            view.addSubview(yesterdayComparison)
            view.addSubview(basedOnYesterday)
            
            yesterdayCntLabel.snp.makeConstraints { make in
                make.centerX.equalTo(yesterdayContentsBackground).offset(-1)
                make.centerY.equalTo(yesterdayContentsBackground).offset(-10)
            }
            
            yesterdayUnit.snp.makeConstraints { make in
                make.left.equalTo(yesterdayCntLabel.snp.right).offset(1)
                make.bottom.equalTo(yesterdayCntLabel)
            }
            
            yesterdayComparison.snp.makeConstraints { make in
                make.centerX.equalTo(yesterdayCntLabel).offset(5)
                make.centerY.equalTo(yesterdayContentsBackground).offset(10)
            }
            
            basedOnYesterday.snp.makeConstraints { make in
                make.top.equalTo(yesterdayContentsBackground.snp.bottom).offset(2)
                make.right.equalTo(yesterdayContentsBackground).offset(-5)
            }
        }
        /*------------------------- YESTERDAY ARR End ------------------------*/
        
        
        
        /*------------------------- ARR Start ------------------------*/
        // Create
        let arrButton = propCreateUI.button(title: "arr".localized(), titleColor: .white, size: 14, weight: .heavy, backgroundColor: UIColor.MY_RED, tag: 0).then {
            $0.contentHorizontalAlignment = .left
            $0.layer.borderWidth = 0
            $0.layer.cornerRadius = 10
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        
        arrValue = propCreateUI.label(text: "0", color: .white, size: 16, weight: .bold).then {
            $0.baselineAdjustment = .alignCenters
        }
        
        let arrTimeLabel = propCreateUI.label(text: "time".localized(), color: .white, size: 14, weight: .bold).then {
            $0.baselineAdjustment = .alignCenters
        }
                
        // AddSubView & Constraints
        if let arrValue = arrValue {
        
            view.addSubview(arrButton)
            view.addSubview(arrValue)
            view.addSubview(arrTimeLabel)
            
            arrButton.snp.makeConstraints { make in
                make.top.equalTo(arrBackground.snp.bottom).offset(15)
                make.left.right.equalTo(arrBackground)
                make.height.equalTo(30)
            }

            arrTimeLabel.snp.makeConstraints { make in
                make.centerY.equalTo(arrButton)
                make.right.equalTo(arrButton).offset(-10)
            }
            
            arrValue.snp.makeConstraints { make in
                make.centerX.equalTo(arrButton).offset(10)
                make.centerY.equalTo(arrButton)
            }
        }
        /*------------------------- ARR End ------------------------*/
        
        
        
        /*------------------------- BodyState Start ------------------------*/
        func configureButton(_ button: UIButton) {
            button.titleLabel?.contentMode = .center
            button.layer.borderWidth = 0
            button.layer.cornerRadius = 10
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            button.addTarget(self, action: #selector(bodyStateEvent(_:)), for: .touchUpInside)
        }
        
        let viewWidth = self.view.frame.size.width / 2
        let buttonWidth = (viewWidth - 30) / 3
        
        // Create
        let bodyStateBackground = propCreateUI.backgroundLabel(backgroundColor: UIColor.MY_LIGHT_GRAY_BORDER, borderColor: UIColor.clear.cgColor, borderWidth: 0, cornerRadius: 10)
        
        restButton = propCreateUI.button(title: "rest".localized(), titleColor: .white, size: 12, weight: .heavy, backgroundColor: UIColor.MY_BODY_STATE, tag: 0).then {
            $0.setImage(UIImage(named: "state_rest"), for: .normal)
            $0.tintColor = .white
            $0.layer.borderColor = UIColor.MY_LIGHT_GRAY_BORDER.cgColor
            
            configureButton($0)
        }
        
        activityButton = propCreateUI.button(title: "exercise".localized(), titleColor: .lightGray, size: 12, weight: .heavy, backgroundColor: UIColor.MY_LIGHT_GRAY_BORDER, tag: 0).then {
            $0.setImage(UIImage(named: "state_activity"), for: .normal)
            $0.tintColor = .lightGray
            $0.layer.borderColor = UIColor.MY_LIGHT_GRAY_BORDER.cgColor
            
            configureButton($0)
        }
        
        sleepButton = propCreateUI.button(title: "sleep".localized(), titleColor: .lightGray, size: 12, weight: .heavy, backgroundColor: UIColor.MY_LIGHT_GRAY_BORDER, tag: 0).then {
            $0.setImage(UIImage(named: "state_sleep"), for: .normal)
            $0.tintColor = .lightGray
            $0.layer.borderColor = UIColor.MY_LIGHT_GRAY_BORDER.cgColor
            
            configureButton($0)
        }
        
        // AddSubView & Constraints
        view.addSubview(bodyStateBackground)
        bodyStateBackground.snp.makeConstraints { make in
            make.centerY.equalTo(arrButton)
            make.left.equalTo(safeAreaView).offset(10)
            make.right.equalTo(arrButton.snp.left).offset(-20)
            make.height.equalTo(30)
        }
        
        if let restButton = restButton, let activityButton = activityButton, let sleepButton = sleepButton {

            view.addSubview(restButton)
            restButton.snp.makeConstraints { make in
                make.centerY.equalTo(arrButton)
                make.left.equalTo(safeAreaView).offset(10)
                make.height.equalTo(bodyStateBackground)
                make.width.equalTo(buttonWidth)
            }


            view.addSubview(activityButton)
            activityButton.snp.makeConstraints { make in
                make.centerY.height.width.equalTo(restButton)
                make.left.equalTo(restButton.snp.right)
            }
            
            
            view.addSubview(sleepButton)
            sleepButton.snp.makeConstraints { make in
                make.centerY.height.width.equalTo(restButton)
                make.left.equalTo(activityButton.snp.right)
            }
        }
        /*------------------------- BodyState End ------------------------*/
        
        // --------------------------- ChartView Start --------------------------- //
        // Create
        chartView = LineChartView().then {
            $0.noDataText = ""
            $0.xAxis.enabled = false
            $0.legend.font = UIFont.boldSystemFont(ofSize: 15)
            $0.setVisibleXRangeMaximum(500)
            $0.xAxis.granularity = 1
            $0.xAxis.labelPosition = .bottom
            $0.xAxis.drawGridLinesEnabled = false
            $0.chartDescription.enabled = false
            $0.leftAxis.axisMaximum = 200
            $0.leftAxis.axisMinimum = 40
            $0.rightAxis.enabled = false
            $0.drawMarkers = false
            $0.dragEnabled = false
            $0.pinchZoomEnabled = false
            $0.doubleTapToZoomEnabled = false
            $0.highlightPerDragEnabled = false
            $0.legend.enabled = false
        }
        
        // AddSubView & Constraints
        if let chartView = chartView {
            view.addSubview(chartView)
            chartView.snp.makeConstraints { make in
                make.top.equalTo(arrButton.snp.bottom).offset(10)
                make.width.equalTo(self.safeAreaView.snp.width)
            }
        }
        // --------------------------- chartView End --------------------------- //

        /*------------------------- Bottom Contents Start ------------------------*/
        // Create
        let calLabel = propCreateUI.label(text: "homeECal".localized(), color: .darkGray, size: 14, weight: .heavy)
        
        let stepLabel = propCreateUI.label(text: "step".localized(), color: .darkGray, size: 14, weight: .heavy)
        
        let temperatureLabel = propCreateUI.label(text: "temperature".localized(), color: .darkGray, size: 14, weight: .heavy)
        
        let distanceLabel = propCreateUI.label(text: "distance".localized(), color: .darkGray, size: 14, weight: .heavy)
        
        calValue = propCreateUI.label(text: "eCalValue".localized(), color: .darkGray, size: 14, weight: .medium).then {
            $0.textAlignment = .right
        }
        
        stepValue = propCreateUI.label(text: "stepValue".localized(), color: .darkGray, size: 14, weight: .medium).then {
            $0.textAlignment = .right
        }
        
        temperatureValue = propCreateUI.label(text: "temperatureValue".localized(), color: .darkGray, size: 14, weight: .medium).then {
            $0.textAlignment = .right
        }

        distanceValue = propCreateUI.label(text: "distanceValue".localized(), color: .darkGray, size: 14, weight: .medium).then {
            $0.textAlignment = .right
        }
        
        let calorieBackground = propCreateUI.backgroundLabel(backgroundColor: .clear, borderColor: UIColor.MY_LIGHT_GRAY_BORDER.cgColor, borderWidth: 2, cornerRadius: 10)

        let stepBackground = propCreateUI.backgroundLabel(backgroundColor: .clear, borderColor: UIColor.MY_LIGHT_GRAY_BORDER.cgColor, borderWidth: 2, cornerRadius: 10)
        
        let calAndStepStackView = UIStackView(arrangedSubviews: [calorieBackground, stepBackground]).then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.alignment = .fill
            $0.spacing = 10
        }
        
        let temperatureBackground = propCreateUI.backgroundLabel(backgroundColor: .clear, borderColor: UIColor.MY_LIGHT_GRAY_BORDER.cgColor, borderWidth: 2, cornerRadius: 10)

        let distanceBackground = propCreateUI.backgroundLabel(backgroundColor: .clear, borderColor: UIColor.MY_LIGHT_GRAY_BORDER.cgColor, borderWidth: 2, cornerRadius: 10)
        
        let temperatureAndDistanceStackView = UIStackView(arrangedSubviews: [temperatureBackground, distanceBackground]).then {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.alignment = .fill
            $0.spacing = 10
        }

        let bottomStackView = UIStackView(arrangedSubviews: [calAndStepStackView, temperatureAndDistanceStackView]).then {
            $0.axis = .vertical
            $0.distribution = .fillEqually // default
            $0.alignment = .fill // default
            $0.spacing = 10
        }
        
        // AddSubview & Constraint
        if let calValue = calValue, let stepValue = stepValue, let temperatureValue = temperatureValue, let distanceValue = distanceValue, let chartView = chartView {
            
            view.addSubview(bottomStackView)
            view.addSubview(calLabel)
            view.addSubview(calValue)
            
            view.addSubview(stepLabel)
            view.addSubview(stepValue)
            
            view.addSubview(temperatureLabel)
            view.addSubview(temperatureValue)
            
            view.addSubview(distanceLabel)
            view.addSubview(distanceValue)
            
            
            bottomStackView.snp.makeConstraints { make in
                make.top.equalTo(chartView.snp.bottom).offset(20)
                make.left.equalTo(safeAreaView).offset(10)
                make.right.equalTo(safeAreaView).offset(-10)
                make.bottom.equalTo(safeAreaView)
                make.height.equalTo(130)
            }
            
            calLabel.snp.makeConstraints { make in
                make.top.left.equalTo(calorieBackground).offset(10)
            }
            
            calValue.snp.makeConstraints { make in
                make.bottom.right.equalTo(calorieBackground).offset(-10)
            }
            
            stepLabel.snp.makeConstraints { make in
                make.top.left.equalTo(stepBackground).offset(10)
            }
            
            stepValue.snp.makeConstraints { make in
                make.bottom.right.equalTo(stepBackground).offset(-10)
            }
            
            temperatureLabel.snp.makeConstraints { make in
                make.top.left.equalTo(temperatureBackground).offset(10)
            }
            
            temperatureValue.snp.makeConstraints { make in
                make.bottom.right.equalTo(temperatureBackground).offset(-10)
            }
            
            distanceLabel.snp.makeConstraints { make in
                make.top.left.equalTo(distanceBackground).offset(10)
            }
            
            distanceValue.snp.makeConstraints { make in
                make.bottom.right.equalTo(distanceBackground).offset(-10)
            }
            
        }
        /*------------------------- Bottom Contents End ------------------------*/
    }
}
