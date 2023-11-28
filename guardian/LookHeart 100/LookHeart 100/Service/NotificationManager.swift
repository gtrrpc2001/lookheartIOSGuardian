import UserNotifications
import UIKit

class NotificationManager {
    
    private let content = UNMutableNotificationContent()
    private let notificationCenter = UNUserNotificationCenter.current()
    private var notiSound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "basicsound.wav"))
    
    private var totalArrAlertFlag:Bool = false
    private var hourlyArrAlertFlag:Bool = false
    
    private let totalArrThresholds: [Int] = [50, 100, 200, 300]
    private var totalArrAlertCheck: [Bool] = [false, false, false, false]
    
    private let hourlyArrThresholds: [Int] = [10, 20, 30, 50]
    private var horulyArrAlertCheck: [Bool] = [false, false, false, false]
    
    static let shared = NotificationManager()
    
    init() {
        content.sound = notiSound   // set sound
        totalArrAlertFlag = defaults.bool(forKey: "totalArrAlert")
        hourlyArrAlertFlag = defaults.bool(forKey: "hourlyArrAlert")
        print(totalArrAlertFlag)
        print(hourlyArrAlertFlag)
    }
    
    func sendNotification(title: String, message: String) {
        content.title = title
        content.body = message
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(
                timeInterval: 1,
                repeats: false
            )
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("알림 등록 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func emergencyAlert(occurrenceTime: String, location: String) {
        if let emergencyAlert = getTopViewController() as? EmergencyAlert {
            emergencyAlert.updateEmergencyAlert(occurrenceTime: occurrenceTime, location: location)
        } else {
            let emergencyAlert = EmergencyAlert(arrFlag: false)
            emergencyAlert.occurrenceLabel.text = occurrenceTime
            emergencyAlert.messageLabel.text = location
            presentAlert(emergencyAlert)
        }
    }
    
    func totalArrCntAlert(_ cnt: Int) {
        if !totalArrAlertFlag { return } // Alert & nofi Off
        
        var arrFlag = -1
        
        for threshold in totalArrThresholds {
            if cnt >= threshold {
                arrFlag += 1
            } else {
                break   // 현재 임계값 보다 arrCnt 값이 작으면 반복문 탈출
            }
        }
        
        if returnCheck(arrFlag: arrFlag, flagList: &totalArrAlertCheck) {    return  }
        
        if let result = getTitleAndMessage(forArrFlag: arrFlag) {
            // Alert
            setAlert(title: result.title,
                     message: result.message)
            // Notification
            NotificationManager.shared.sendNotification(title: result.title,
                                                        message: result.message)
            totalArrAlertCheck[arrFlag] = true
        }
    }
    
    func hourlyArrCntAlert(_ cnt: Int) {
        if !hourlyArrAlertFlag { return } // Alert & nofi Off
        
        var arrFlag = -1
        
        for threshold in hourlyArrThresholds {
            if cnt >= threshold {
                arrFlag += 1
            } else {
                break   // 현재 임계값 보다 arrCnt 값이 작으면 반복문 탈출
            }
        }
        
        if returnCheck(arrFlag: arrFlag, flagList: &horulyArrAlertCheck) {    return  } // 중복 알림 방지
        if let result = getTitleAndMessage(forArrFlag: 4 + arrFlag) {
            // Alert
            setAlert(title: result.title,
                     message: result.message)
            // Notification
            NotificationManager.shared.sendNotification(title: result.title,
                                                        message: result.message)
            horulyArrAlertCheck[arrFlag] = true
        }
    }
    
    func getTitleAndMessage(forArrFlag arrFlag: Int) -> (title: String, message: String)? {
        switch arrFlag {
        case 0:
            return ("arrCnt50".localized(), "arrCnt50Text".localized())
        case 1:
            return ("arrCnt100".localized(), "arrCnt100Text".localized())
        case 2:
            return ("arrCnt200".localized(), "arrCnt200Text".localized())
        case 3:
            return ("arrCnt200".localized(), "arrCnt200Text".localized())
        case 4:
            return ("notiHourlyArr10".localized(), "notiHourlyArr10Text".localized())
        case 5:
            return ("notiHourlyArr20".localized(), "notiHourlyArr20Text".localized())
        case 6:
            return ("notiHourlyArr30".localized(), "notiHourlyArr30Text".localized())
        case 7:
            return ("notiHourlyArr50".localized(), "notiHourlyArr50Text".localized())
        default:
            return nil
        }
    }
    
    func setAlert(title: String, message: String) {
        guard let topViewController = getTopViewController() else {
            return
        }
        
        if let emergencyAlert = topViewController.presentedViewController as? EmergencyAlert {
            emergencyAlert.updateArrAlert(arrTitle: title, arrMessage: message)
        } else {
            let emergencyAlert = EmergencyAlert(arrFlag: true)
            emergencyAlert.titleLabel.text = title
            emergencyAlert.occurrenceTitle.text = message
            presentAlert(emergencyAlert)
        }
    }
    
    func presentAlert(_ emergencyAlert: EmergencyAlert) {
        emergencyAlert.modalPresentationStyle = .overCurrentContext
        emergencyAlert.modalTransitionStyle = .crossDissolve
        if let topController = getTopViewController() { // 최상위 뷰를 찾아 알림 띄움 : 모든 뷰에서 알림
            topController.present(emergencyAlert, animated: true)
        }
    }
    
    func returnCheck(arrFlag: Int, flagList: inout [Bool]) -> Bool {
        if arrFlag == -1 { return true }    // 조건 해당 없음
        else if flagList[arrFlag] { return true }    // 알림 중복
        return false
    }
    
    func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        
        var topViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        
        return topViewController
    }
    
    func setNotiUserdefault() {
        print(totalArrAlertFlag)
        print(hourlyArrAlertFlag)
        defaults.set(totalArrAlertFlag, forKey: "totalArrAlert")
        defaults.set(hourlyArrAlertFlag, forKey: "hourlyArrAlert")
    }
    
    func setTotalArrAlert(_ flag: Bool) {
        totalArrAlertFlag = flag
    }
    
    func getTotalArrAlert() -> Bool {
        return totalArrAlertFlag
    }
    
    func setHourlyArrAlert(_ flag: Bool) {
        hourlyArrAlertFlag = flag
    }
    
    func getHourlyArrAlert() -> Bool {
        return hourlyArrAlertFlag
    }
    
    func resetToalArray(){
        totalArrAlertCheck = [false, false, false, false]
    }
    
    func resetHourlyArray(){
        horulyArrAlertCheck = [false, false, false, false]
    }
}
