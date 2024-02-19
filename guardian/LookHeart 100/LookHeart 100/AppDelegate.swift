//
//  AppDelegate.swift
//  LookHeart 100
//
//  Created by Yeun-Ho Joung on 2021/09/04.
//

import UIKit
import UserNotifications
import Firebase
import LookheartPackage

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    weak var delegate: AppDelegateDelegate?
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter
          .current()
          .requestAuthorization(
            options: authOptions,completionHandler: { (_, _) in }
          )
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("\(type(of: self)): \(#function)")
        
        NotificationManager.shared.setNotiUserdefault()
        
        // Send Log
        if let guardian = Keychain.shared.getString(forKey: "phone") {
            NetworkManager.shared.sendLog(id: propEmail, userType: .Guardian, action: .Shutdown, phone: guardian)
        }
        
        sleep(2)
        
        print("💣💣💣")
    }
    
    
    // Token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
                
        // Set FCM Token
        Keychain.shared.setValue(fcmToken!, forKey: "token")
        
        if FCM.shared.isFirstToken() {
            FCM.shared.sendToken()
        }
    }
    
    // 포그라운드 알림 수신
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let content = notification.request.content
        let title = content.title
        let body = content.body
                
        print("Received notification with title: \(title), body: \(body)")
    
        if title.contains("FirebaseUserBle".localized()) {
            bleEvent(flag: body)
        } else if title.contains("FirebaseEmergency".localized()) {
            emergencyEvent()
        } else {
            // Arr
        }
        
        // 알림이 앱이 활성 상태일 때도 표시되도록 설정
        completionHandler([.alert, .badge, .sound])
        
    }

    
    func bleEvent(flag: String) {
        
        if flag.contains("FirebaseBleConnect".localized()) {
            // FirebaseBleConnect
            delegate?.startLoop()
        } else {
            // FirebaseBleDisconnect
            delegate?.stopLoop()
        }
        
    }
    
    
    func emergencyEvent() {
        let startDate = String(guardianTime.split(separator: " ")[0])
        let endDate = MyDateTime.shared.dateCalculate(startDate, 1, true)
        
        ArrEmergencyManager.shared.checkEmergency(startDate: startDate, endDate: endDate)
    }
    
    
    // 알림 반응
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
}
