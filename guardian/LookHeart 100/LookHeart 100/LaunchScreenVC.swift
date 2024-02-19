import UIKit
import Foundation
import LookheartPackage

class LaunchScreenVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkVersion()
        addView()
        
    }
    
    private func checkVersion() {
        
        NetworkManager.shared.getVersion(type: .Guardian) { [self] result in
            switch result {
                                
            case .success(let match):
                print("checkVersion : \(match)")
                if match {
                    moveVC()
                } else {
                    updateAppAlert()
                }
                
            case .failure(let error):
                print("checkVersion error: \(error)")
                shutdownApp()
            }
        }
    }
    
    private func moveVC() {
        let autoLogin = UserDefaults.standard.bool(forKey: "autoLoginFlag")

        if autoLogin {
            self.view.window?.rootViewController = TabBarController()
        } else {
            self.view.window?.rootViewController = LoginView()
        }
        
        self.view.window?.makeKeyAndVisible()
    }
    
    private func updateAppAlert() {
        propAlert.basicActionAlert(title: "noti".localized(), message: "updateApp".localized(), ok: "ok".localized(), viewController: self) {
            guard let url = URL(string: "https://itunes.apple.com/app/id6450522486") else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func shutdownApp() {
        propAlert.basicActionAlert(title: "noti".localized(), message: "serverError".localized(), ok: "ok".localized(), viewController: self) {
            // 앱 종료
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                exit(0)
            }
        }
    }
    
    private func addView() {
        
        let launchScreen = UIImageView(frame: self.view.bounds).then {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "launchScreen")
        }
        
        view.addSubview(launchScreen)
        launchScreen.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
    }
    
}
