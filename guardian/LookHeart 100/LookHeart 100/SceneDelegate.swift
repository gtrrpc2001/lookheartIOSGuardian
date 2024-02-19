//
//  SceneDelegate.swift
//  LookHeart 100
//
//  Created by Yeun-Ho Joung on 2021/09/04.
//

import UIKit
import LookheartPackage


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    weak var delegate: AppDelegateDelegate?
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = LaunchScreenVC()
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 앱이 포그라운드로 돌아오기 전 실행
        print("sceneWillEnterForeground")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 앱이 활성화되고 사용자와의 상호작용이 가능해진 후 실행
        print("sceneDidBecomeActive")
        
        if appStart {
            let startDate = String(guardianTime.split(separator: " ")[0])
            let endDate = MyDateTime.shared.dateCalculate(startDate, 1, true)
            ArrEmergencyManager.shared.checkEmergency(startDate: startDate, endDate: endDate)
            
            delegate?.startLoop()
        }
        
    }
    

}
