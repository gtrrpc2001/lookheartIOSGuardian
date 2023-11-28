//
//  FirebaseMessagingService.swift
//  LookHeart 100
//
//  Created by 정연호 on 2023/11/13.
//

import Foundation
import UserNotifications
import FirebaseMessaging

class FCM {
    
    static let shared = FCM()
    
    func sendToken(){
        guard let email = Keychain.shared.getString(forKey: "email"),
              let password = Keychain.shared.getString(forKey: "password"),
              let phone = Keychain.shared.getString(forKey: "phone") else {
            print("One or more credentials are missing.")
            return
        }
        
        sendTokenServerTask(email: email, password: password, phone: phone) { success in
            if success {
                print("Send token success")
            } else {
                print("Send token fail")
            }
        }
    }
    
    func sendTokenServerTask(email: String, password: String, phone: String, completion: @escaping (Bool) -> Void) {
        guard let token = Keychain.shared.getString(forKey: "token") else {
            print("Token is missing.")
            completion(false)
            return
        }
        
        NetworkManager.shared.sendToken(id: email, password: password, phone: phone, token: token) { result in
            switch result {
            case .success(let isAvailable):
                completion(isAvailable)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func isFirstToken() -> Bool{
        return !Keychain.shared.getBool(forKey: "login")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 포그라운드 알림 수신
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
        
        DispatchQueue.main.async {  // 현재 활성화된 MainViewController를 찾아서 메서드 실행
            if let mainViewController = findViewController(ofType: MainViewController.self) {
                mainViewController.checkEmergency() // ARR Cnt에 따라 UI 업데이트
            }
            
//            if let arrViewCotroller = findViewController(ofType: ArrVC.self) {
//                arrViewCotroller.fcmEvent()
//            }
        }
        
        completionHandler([.alert, .badge, .sound])
    }

    // 알림 반응
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
    

    private func receiveMessage(_ userInfo: [AnyHashable: Any]) {
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            if let jsonData = try? JSONSerialization.data(withJSONObject: aps, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                extractValues(from: jsonString)
            } else {
                print("Received APS: \(aps)")
            }
        }
    }
    
    private func extractValues(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Error: 문자열을 Data 객체로 변환하는 데 실패했습니다.")
            return
        }
        
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
               let aps = jsonDict["aps"] as? [String: Any],
               let alert = aps["alert"] as? [String: String],
               let title = alert["title"],
               let body = alert["body"],
               let sound = aps["sound"] as? String {
                print("Title: \(title)")
                print("Body: \(body)")
                print("Sound: \(sound)")
            }
        } catch {
            print("Error: JSON 파싱 중 에러 발생 - \(error.localizedDescription)")
        }
    }
    
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
//        print("Firebase registration token: \(String(describing: fcmToken))")
        if !Keychain.shared.setString(fcmToken!, forKey: "token") {
            print("Failed to save Token data to the keychain")
        }
        
        if !FCM.shared.isFirstToken() {
            print("sendToken")
            FCM.shared.sendToken()
        }
    }
}

func findViewController<T: UIViewController>(ofType type: T.Type) -> T? {
    guard let rootViewController = getRootViewController() else {
        return nil
    }

    var foundViewController: T?
    traverseViewControllerHierarchy(rootViewController) { viewController in
        if let viewController = viewController as? T {
            foundViewController = viewController
        }
    }
    return foundViewController
}

func getRootViewController() -> UIViewController? { // 활성화 된 Scenes 찾기
    guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
          let window = sceneDelegate.window else {
        return nil
    }
    return window.rootViewController
}

func traverseViewControllerHierarchy(_ rootViewController: UIViewController, action: (UIViewController) -> Void) {
    //  뷰 컨트롤러 계층 구조를 순회하며, MainViewController 인스턴스 찾음
    action(rootViewController)
    if let presented = rootViewController.presentedViewController {
        traverseViewControllerHierarchy(presented, action: action)
    }
    if let navigationController = rootViewController as? UINavigationController {
        navigationController.viewControllers.forEach { traverseViewControllerHierarchy($0, action: action) }
    }
    if let tabBarController = rootViewController as? UITabBarController {
        tabBarController.viewControllers?.forEach { traverseViewControllerHierarchy($0, action: action) }
    }
}
