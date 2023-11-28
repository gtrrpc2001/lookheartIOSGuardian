//
//  SceneDelegate.swift
//  LookHeart 100
//
//  Created by Yeun-Ho Joung on 2021/09/04.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var isLogged: Bool = UserDefaults.standard.bool(forKey: "autoLoginFlag")
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        // navigationbar
        let navigationController = UINavigationController(rootViewController: LoginView())
                
        if isLogged == false {
            window.rootViewController = navigationController // 로그인 안된 상태
        }
        else {
            window.rootViewController = TabBarController() // 로그인 상태
        }

        window.makeKeyAndVisible()
        self.window = window
    }
    
//    func sceneWillEnterForeground(_ scene: UIScene) {
//        // 앱이 포그라운드로 돌아오기 전 실행
//        print("sceneWillEnterForeground")
//    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 앱이 활성화되고 사용자와의 상호작용이 가능해진 후 실행
        print("sceneDidBecomeActive")
        if isHomeFlag {
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
    }
    
}
