import Foundation
import UIKit

let emailRegex = try? NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}$")
let passwordRegex = try? NSRegularExpression(pattern: "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{10,}$")
let nameRegex = try? NSRegularExpression(pattern: "^[가-힣]{1,5}|[a-zA-Z]{2,10}[a-zA-Z]{2,10}$")
let heightAndWeightRegex = try? NSRegularExpression(pattern: "^[0-9]{1,3}$")
let targetNumberRegex = try? NSRegularExpression(pattern: "^[0-9]{1,5}$")
let phoneNumberRegex = try? NSRegularExpression(pattern: "^[0-9]{9,11}$")
let numberRegex = try! NSRegularExpression(pattern: "[0-9]+")

let defaults = UserDefaults.standard

class BaseViewController: UIViewController {
    
    public let safeAreaView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSafeAreaView()
        setSafeAreaView()
        setupCustomTitleView()
        
    }
    
    // Safe Area 설정
    func setSafeAreaView() {
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                safeAreaView.topAnchor.constraint(equalTo: guide.topAnchor),
                safeAreaView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([   // iOS 11 미만에서는 topLayoutGuide와 bottomLayoutGuide를 사용
                safeAreaView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                safeAreaView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
            ])
        }
    }
    
    func initSafeAreaView(){
        view.backgroundColor = .white
        view.addSubview(safeAreaView)
        
        NSLayoutConstraint.activate([
            safeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    // Custom Title View 설정
    func setupCustomTitleView() {
        let customTitleView = CustomTitleView()
        let customTitleViewItem = UIBarButtonItem(customView: customTitleView)
        self.navigationItem.leftBarButtonItem = customTitleViewItem
    }
    
    func getSafeAreaView() -> UIView {
        return safeAreaView
    }
}

func timeZone() -> String {
    var utcOffsetAndCountry:String
    
    let currentTimeZone = TimeZone.current
    let utcOffsetInSeconds = currentTimeZone.secondsFromGMT()

    let hours = abs(utcOffsetInSeconds) / 3600
    let minutes = (abs(utcOffsetInSeconds) % 3600) / 60

    let offsetString = String(format: "%@%02d:%02d", utcOffsetInSeconds >= 0 ? "+" : "-", hours, minutes)

    let currentCountryCode = Locale.current.regionCode ?? "Unknown"  // "US", "KR" 등

    utcOffsetAndCountry = "\(offsetString)/\(currentCountryCode)"
    
    return utcOffsetAndCountry
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

extension UIColor {
    static let MY_RED = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
    static let MY_PINK = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 0.5)
    static let MY_RED_BORDER = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
    
    static let MY_BLUE = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
    static let MY_SKY = UIColor(red: 11/255, green: 86/255, blue: 242/255, alpha: 0.3)
    static let MY_BLUE_BORDER = UIColor(red: 11/255, green: 86/255, blue: 242/255, alpha: 0.6)

    static let MY_GREEN = UIColor(red: 226/255, green: 251/255, blue: 196/255, alpha: 1.0)
    static let MY_GREEN_BORDER = UIColor(red: 181/255, green: 244/255, blue: 100/255, alpha: 1.0)
    static let MY_GREEN_TEXT = UIColor(red: 118/255, green: 203/255, blue: 14/255, alpha: 1.0)
    
    static let MY_LIGHT_GRAY = UIColor(red: 249/255, green: 250/255, blue: 252/255, alpha: 1.0)
    static let MY_LIGHT_GRAY_BORDER = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0)
    
    static let PROFILE_BACKGROUND = UIColor(red: 0xef/255, green: 0xf0/255, blue: 0xf2/255, alpha: 1.0)
    static let PROFILE_BUTTON_TEXT = UIColor(red: 151/255, green: 154/255, blue: 164/255, alpha: 1.0)
    static let PROFILE_BUTTON_SELECT = UIColor(red: 56/255, green: 70/255, blue: 110/255, alpha: 1.0)
    
    // BODY STATE
    static let MY_BODY_STATE = UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0)
    
    // GRAPH
    static let GRAPH_RED = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
    static let GRAPH_BLUE = UIColor(red: 11/255, green: 86/255, blue: 242/255, alpha: 1.0)
    static let GRAPH_GREEN = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1.0)
    /// Primary ColorSet
    ///
    /// Primary color - (100, 149, 237, 100%)
    class var buttonBackground: UIColor? { return UIColor(named: "buttonBackground") }
    /// Secondary color - (0, 0, 205, 100%)
    class var lableBackground: UIColor? { return UIColor(named: "lableBackground") }
    /// Tertiary color - (0, 0, 139, 100%)
    class var mint: UIColor? { return UIColor(named: "mint") }
    
    class var lineGreen: UIColor? { return UIColor(named: "lineGreen") }
    
}


extension String {
    
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(backgroundImage, for: state)
    }
}
