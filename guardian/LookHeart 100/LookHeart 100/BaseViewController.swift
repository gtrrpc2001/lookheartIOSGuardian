import Foundation
import UIKit

let defaults = UserDefaults.standard

class BaseViewController: UIViewController {
    
    public let safeAreaView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSafeAreaView()
        setupCustomTitleView()
        
    }

    
    // Safe Area 설정
    func setSafeAreaView() {
        let guide = view.safeAreaLayoutGuide
        
        view.backgroundColor = .white
        view.addSubview(safeAreaView)
        
        safeAreaView.snp.makeConstraints { make in
            make.top.bottom.equalTo(guide)
            make.left.right.equalTo(view)
        }
    }
    
    // Custom Title View 설정
    func setupCustomTitleView() {
        let customTitleView = CustomTitleView()
        let customTitleViewItem = UIBarButtonItem(customView: customTitleView)
        self.navigationItem.leftBarButtonItem = customTitleViewItem
    }
}

// 최상위 뷰 찾는 함수
func getTopViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return nil
    }

    guard let rootViewController = windowScene.windows.filter({ $0.isKeyWindow }).first?.rootViewController else {
        return nil
    }

    return getVisibleViewController(rootViewController)
}

private func getVisibleViewController(_ vc: UIViewController?) -> UIViewController? {
    if let navigationController = vc as? UINavigationController {
        return getVisibleViewController(navigationController.visibleViewController)
    } else if let tabBarController = vc as? UITabBarController {
        return getVisibleViewController(tabBarController.selectedViewController)
    } else if let presentedViewController = vc?.presentedViewController {
        return getVisibleViewController(presentedViewController)
    } else {
        return vc
    }
}

extension UIAlertController {
    //Set background color of UIAlertController
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    //Set title font and title color
    func setTitlet(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                          range: NSMakeRange(0, title.utf8.count))
        }

        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor],//3
                                          range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")//4
    }

    //Set message font and message color
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let message = self.message else { return }
        let attributeString = NSMutableAttributedString(string: message)
        if let messageFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : messageFont],
                                          range: NSMakeRange(0, message.utf8.count))
        }

        if let messageColorColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : messageColorColor],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedMessage")
    }

    //Set tint color of UIAlertController
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
}
