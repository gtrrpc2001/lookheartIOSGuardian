//
//  AppDelegate.swift
//  LookHeart 100
//
//  Created by Yeun-Ho Joung on 2021/09/04.
//

import UIKit
import UserNotifications
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

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
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // 앱이 포그라운드로 돌아오기 전 실행
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // 앱이 활성화되고 사용자와의 상호작용이 가능해진 후 실행
        print("applicationDidBecomeActive")
        
        DispatchQueue.main.async {  // 현재 활성화된 MainViewController를 찾아서 메서드 실행
                if let rootViewController = getRootViewController() {
                    traverseViewControllerHierarchy(rootViewController) { viewController in
                        if let mainViewController = viewController as? MainViewController {
                            mainViewController.checkEmergency()
                        }
                    }
                }
            }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // 종료 전에 필요한 작업을 수행합니다.
        NotificationManager.shared.setNotiUserdefault()
    }
    
}
