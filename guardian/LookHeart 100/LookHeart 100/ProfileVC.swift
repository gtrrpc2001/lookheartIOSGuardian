import Foundation
import FirebaseMessaging
import UIKit


class ProfileVC: BaseViewController {
        
    private let BUTTON_ON = true
    private let BUTTON_OFF = false
    
    // ----------------------------- NOTI ----------------------------- //
    enum ButtonType {
        case totalArr
        case hourlyArr
    }
    
    enum ButtonOnOff {
        case totalArrOn
        case totalArrOff
        case hourlyArrOn
        case hourlyArrOff
    }
    
    private lazy var backgroundList: [UILabel] = [totalArrBackground, hourlyArrBackground]
        
    private lazy var buttonDictionary: [UILabel : ButtonType] = [
        totalArrBackground : ButtonType.totalArr,
        hourlyArrBackground: ButtonType.hourlyArr]
    
    private lazy var buttonFlagDictionary: [ButtonType : Bool] = [
        ButtonType.totalArr : false,
        ButtonType.hourlyArr: false]
    
    private var buttonListDictionary: [ButtonOnOff : UIButton] = [:]
    
    // ----------------------------- BUTTON ----------------------------- //
    private lazy var buttonList:[UIButton] = [basicInfoButton, settingButton]
    private lazy var labelList:[UIButton : UILabel] = [
        basicInfoButton: basiceUnderLine,
        settingButton: settingUnderLine]
    private lazy var viewList:[UIButton : UIView] = [
        basicInfoButton: basicInfoView,
        settingButton: settingView]
    // ----------------------------- TOP ----------------------------- //
    let topBackground: UIView = {
        let view = UILabel()
        view.backgroundColor = UIColor.MY_LIGHT_GRAY
        view.layer.borderColor = UIColor.MY_LIGHT_GRAY_BORDER.cgColor
        view.layer.borderWidth = 1
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "GUARDIAN"
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let sirLabel: UILabel = {
        let label = UILabel()
        label.text = "sir".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "email_Label".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "lookheart@msl.co.kr"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let signupDateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "joinDate".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let signupDate: UILabel = {
        let label = UILabel()
        label.text = "0000-00-00 00:00:00"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Logout
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("logout".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 1
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(logoutEvent(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
   }()
    @objc func logoutEvent(_ sender: UIButton) {
        let alert = UIAlertController(title: "logout".localized(), message: "logoutHelp".localized(), preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "ok".localized(), style: .destructive, handler: { Action in
            
            self.initUserData()
            
            UserDefaults.standard.set(false, forKey: "autoLoginFlag")
            
            if let navigationController = self.navigationController {
                let newViewController = LoginView()
                navigationController.setViewControllers([newViewController], animated: true)
            }
        })
        
        let cancel = UIAlertAction(title: "rejectLogout".localized(), style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: false)
    }
    
    // ----------------------------- BUTTON ----------------------------- //
    private let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var basicInfoButton: UIButton = {
        let button = UIButton()
        button.setTitle("basic".localized(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(typeButtonEvent(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setTitle("setting".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(typeButtonEvent(_:)), for: .touchUpInside)
        return button
    }()
    
    private let basiceUnderLine: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingUnderLine: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // ----------------------------- VIEW ----------------------------- //
    private var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var basicInfoView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.isHidden = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var settingView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // ----------------------------- BASICINFO CONTENTS ----------------------------- //
    let privacyInfo: UILabel = {
        let label = UILabel()
        label.text = "profile_HelpInfo".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .lightGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // NAME
    let nameTitleLabel:UILabel = {
        let label = UILabel()
        label.text = "name_Label".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userNameLabel:UILabel = {
        let label = UILabel()
        label.text = "GUARDIAN"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userNameBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // PHONE
    let phoneTitleLabel:UILabel = {
        let label = UILabel()
        label.text = "profile_phone".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let phoneLabel:UILabel = {
        let label = UILabel()
        label.text = "000-0000-0000"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let phoneBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // GUARDIAN
    let guardianTitleLabel:UILabel = {
        let label = UILabel()
        label.text = "profile_guardian".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let guardianLabel:UILabel = {
        let label = UILabel()
        label.text = "000-0000-0000"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let guardianBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // BIRTHDAY
    let birthdayTitleLabel:UILabel = {
        let label = UILabel()
        label.text = "birthday_Label".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let birthdayLabel:UILabel = {
        let label = UILabel()
        label.text = "0000-00-00"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let birthdayBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // AGE
    let ageTitleLabel:UILabel = {
        let label = UILabel()
        label.text = "profile_age".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ageLabel:UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ageBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // GENDER
    let genderTitleLabel:UILabel = {
        let label = UILabel()
        label.text = "profile_gender".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let genderLabel:UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let genderBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // HEIGHT
    let heightTitleLabel:UILabel = {
        let label = UILabel()
        label.text = "profile_height".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let heightLabel:UILabel = {
        let label = UILabel()
        label.text = "000"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let heightBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // WEIGHT
    let weightTitleLabel:UILabel = {
        let label = UILabel()
        label.text = "profile_weight".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let weightLabel:UILabel = {
        let label = UILabel()
        label.text = "000"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let weightBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // SLEEP
    let sleepTitleLabel:UILabel = {
        let label = UILabel()
        label.text = "profile_sleep".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let sleepLabel:UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let sleepBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // WAKEUP
    let wakeupTitleLabel:UILabel = {
        let label = UILabel()
        label.text = "profile_wakeup".localized()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let wakeupLabel:UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let wakeupBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // ----------------------------- SETTING CONTENTS ----------------------------- //
    let setHelpLabel: UILabel = {
        let label = UILabel()
        label.text = "앱 푸쉬 알림"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    let totalArrLabel: UILabel = {
        let label = UILabel()
        label.text = "비정상맥박 합계 알림"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let totalArrBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let hourlyArrLabel: UILabel = {
        let label = UILabel()
        label.text = "비정상맥박 시간별 알림"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let hourlyArrBackground:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.PROFILE_BACKGROUND
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVar()
        addViews()
        setUserData()
        
        setAlertButton()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            settingView.heightAnchor.constraint(equalToConstant: scrollView.frame.size.height + 100)
        ])
    }
    
    func initVar() {
        buttonFlagDictionary[ButtonType.totalArr] = defaults.bool(forKey: "totalArrAlert")
        buttonFlagDictionary[ButtonType.hourlyArr] = defaults.bool(forKey: "hourlyArrAlert")
        
    }
    
    // MARK: - setButton
    private func setAlertButton() {
        for button in buttonDictionary {
            setupButtons(background: button.key, buttonType: button.value)
        }
    }
    
    func setupButtons(background: UILabel, buttonType: ButtonType) {
        let alertOffButton = createButton(title: "profile_off".localized(), type: buttonType, onOffFlag: BUTTON_OFF)
        let alertOnButton = createButton(title: "profile_on".localized(), type: buttonType, onOffFlag: BUTTON_ON)
        
        settingView.addSubview(alertOffButton)
        settingView.addSubview(alertOnButton)
        
        switch (buttonType) {
        case .totalArr:
            buttonListDictionary[ButtonOnOff.totalArrOn] = alertOnButton
            buttonListDictionary[ButtonOnOff.totalArrOff] = alertOffButton
        case .hourlyArr:
            buttonListDictionary[ButtonOnOff.hourlyArrOn] = alertOnButton
            buttonListDictionary[ButtonOnOff.hourlyArrOff] = alertOffButton
        }
        
        NSLayoutConstraint.activate([
            alertOnButton.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            alertOnButton.centerXAnchor.constraint(equalTo: background.centerXAnchor, constant: 30),
            alertOnButton.heightAnchor.constraint(equalToConstant: 30),
            
            alertOffButton.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            alertOffButton.centerXAnchor.constraint(equalTo: background.centerXAnchor, constant: -30),
            alertOffButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    func createButton(title: String, type: ButtonType, onOffFlag: Bool) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        button.setTitleColor(UIColor.PROFILE_BUTTON_TEXT, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let isSelected = buttonFlagDictionary[type] == onOffFlag
        if isSelected {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor.PROFILE_BUTTON_SELECT
        }
        
        switch (type) {
        case .totalArr:
            button.addTarget(self, action: #selector(totalArrButtonTapped(_:)), for: .touchUpInside)
        case .hourlyArr:
            button.addTarget(self, action: #selector(hourlyArrButtonTapped(_:)), for: .touchUpInside)
        }
        return button
    }
    
    func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        button.setTitleColor(isSelected ? .white : UIColor.PROFILE_BUTTON_TEXT, for: .normal)
        button.backgroundColor = isSelected ? UIColor.PROFILE_BUTTON_SELECT : .clear
    }
    
    func setNotification(_ button: ButtonType, _ flag: Bool) {
        switch(button){
            
        case .totalArr:
            NotificationManager.shared.setTotalArrAlert(flag)
        case .hourlyArr:
            NotificationManager.shared.setHourlyArrAlert(flag)
        }
    }
    
    func handleButtonTap(forType type: ButtonType, withTitle title: String, on: ButtonOnOff, off: ButtonOnOff) {
        let buttonFlag = buttonFlagDictionary[type] ?? false

        if (buttonFlag && title == "profile_on".localized()) || (!buttonFlag && title == "profile_off".localized()) {
            return
        }

        if let onButton = buttonListDictionary[on],
           let offButton = buttonListDictionary[off] {
            updateButtonAppearance(onButton, isSelected: !buttonFlag)
            updateButtonAppearance(offButton, isSelected: buttonFlag)
        }

        buttonFlagDictionary[type] = !buttonFlag
        setNotification(type, !buttonFlag)
    }
    
    @objc func totalArrButtonTapped(_ sender: UIButton) {
        handleButtonTap(forType: .totalArr, 
                        withTitle: sender.titleLabel?.text ?? "",
                        on: ButtonOnOff.totalArrOn,
                        off: ButtonOnOff.totalArrOff)
    }

    @objc func hourlyArrButtonTapped(_ sender: UIButton) {
        handleButtonTap(forType: .hourlyArr, 
                        withTitle: sender.titleLabel?.text ?? "",
                        on: ButtonOnOff.hourlyArrOn,
                        off: ButtonOnOff.hourlyArrOff)
    }
    
    @objc func typeButtonEvent(_ sender: UIButton) {
        for button in buttonList {
            if button == sender {
                button.setTitleColor(.black, for: .normal)
                labelList[button]?.isHidden = false
                viewList[button]?.isHidden = false
            } else {
                button.setTitleColor(.lightGray, for: .normal)
                labelList[button]?.isHidden = true
                viewList[button]?.isHidden = true
            }
        }
    }
        
    //MARK: - setUserData
    private func setUserData(){
        nameLabel.text = UserProfileManager.shared.getName()
        emailLabel.text = UserProfileManager.shared.getEmail()
        signupDate.text = UserProfileManager.shared.getSignupDate()
        userNameLabel.text = UserProfileManager.shared.getName()
        phoneLabel.text = UserProfileManager.shared.getPhoneNumber()
        guardianLabel.text = Keychain.shared.getString(forKey: "phone")
        birthdayLabel.text = UserProfileManager.shared.getBirthDate()
        genderLabel.text = UserProfileManager.shared.getGender() == "남자" ? "male_Label".localized() : "female_Label".localized()
        heightLabel.text = UserProfileManager.shared.getHeight()
        weightLabel.text = UserProfileManager.shared.getWeight()
        sleepLabel.text = String(UserProfileManager.shared.getBedtime())
        wakeupLabel.text = String(UserProfileManager.shared.getWakeUpTime())
        
        if let age = setAge(birthdate: UserProfileManager.shared.getBirthDate()) {
            ageLabel.text = String(age)
        } else {
            ageLabel.text = UserProfileManager.shared.getAge()
        }
     }
    
    private func setAge(birthdate: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let birthDate = dateFormatter.date(from: birthdate) else {
            return nil
        }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year
    }
    
    // MARK: - initUserData
    func initUserData(){
        let email = Keychain.shared.getString(forKey: "email")!
        let password = Keychain.shared.getString(forKey: "password")!
        let phone = Keychain.shared.getString(forKey: "phone")!
        
        initTokenServerTask(email: email, password: password, phone: phone) { success in
            if success {
                print("init token success")
            } else {
                print("init token fail")
            }
        }
        
        if (Keychain.shared.clear()){
            print("Keychain clear")
        }
    }
    
    func initTokenServerTask(email: String, password: String, phone: String, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.sendToken(id: email, password: password, phone: phone, token: "") { result in
            switch result {
            case .success(let isAvailable):
                
                if Keychain.shared.setBool(true, forKey: "logout"){
                    print("setBool : true, forkey: logout")
                }
                completion(isAvailable)
                
                break
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(false)
                break
            }
        }
    }
    
    //MARK: - layout
    func addViews(){
        view.addSubview(topBackground)
        view.addSubview(buttonView)
        view.addSubview(scrollView)
        
        topBackground.addSubview(nameLabel)
        topBackground.addSubview(sirLabel)
        topBackground.addSubview(emailTitleLabel)
        topBackground.addSubview(emailLabel)
        topBackground.addSubview(signupDateTitleLabel)
        topBackground.addSubview(signupDate)
        topBackground.addSubview(logoutButton)
        
        buttonView.addSubview(basicInfoButton)
        buttonView.addSubview(basiceUnderLine)
        buttonView.addSubview(settingButton)
        buttonView.addSubview(settingUnderLine)
                
        // -------------- basicInfoView -------------- //
        scrollView.addSubview(basicInfoView)
        
        basicInfoView.addSubview(privacyInfo)
        basicInfoView.addSubview(nameTitleLabel)
        basicInfoView.addSubview(userNameBackground)
        basicInfoView.addSubview(userNameLabel)

        basicInfoView.addSubview(phoneTitleLabel)
        basicInfoView.addSubview(phoneBackground)
        basicInfoView.addSubview(phoneLabel)

        basicInfoView.addSubview(guardianTitleLabel)
        basicInfoView.addSubview(guardianBackground)
        basicInfoView.addSubview(guardianLabel)
        
        basicInfoView.addSubview(birthdayTitleLabel)
        basicInfoView.addSubview(birthdayBackground)
        basicInfoView.addSubview(birthdayLabel)
        
        basicInfoView.addSubview(ageTitleLabel)
        basicInfoView.addSubview(ageBackground)
        basicInfoView.addSubview(ageLabel)
        
        basicInfoView.addSubview(genderTitleLabel)
        basicInfoView.addSubview(genderBackground)
        basicInfoView.addSubview(genderLabel)
        
        basicInfoView.addSubview(heightTitleLabel)
        basicInfoView.addSubview(heightBackground)
        basicInfoView.addSubview(heightLabel)
        
        basicInfoView.addSubview(weightTitleLabel)
        basicInfoView.addSubview(weightBackground)
        basicInfoView.addSubview(weightLabel)
        
        basicInfoView.addSubview(sleepTitleLabel)
        basicInfoView.addSubview(sleepBackground)
        basicInfoView.addSubview(sleepLabel)
        
        basicInfoView.addSubview(wakeupTitleLabel)
        basicInfoView.addSubview(wakeupBackground)
        basicInfoView.addSubview(wakeupLabel)
        
        // -------------- settingView -------------- //
        scrollView.addSubview(settingView)
        
        settingView.addSubview(setHelpLabel)
        settingView.addSubview(totalArrLabel)
        settingView.addSubview(totalArrBackground)
        settingView.addSubview(hourlyArrLabel)
        settingView.addSubview(hourlyArrBackground)
        
        setConstraints()
    }
    
    func setConstraints() {
        let screenWidth = UIScreen.main.bounds.width // Screen width
        
        NSLayoutConstraint.activate([
            // ----------------------------- TOP ----------------------------- //
            
            nameLabel.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: topBackground.leadingAnchor, constant: 20),
            
            sirLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: -2),
            sirLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 3),
            
            emailTitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            emailTitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: emailTitleLabel.bottomAnchor, constant: 3),
            emailLabel.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
            signupDateTitleLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            signupDateTitleLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            
            signupDate.topAnchor.constraint(equalTo: signupDateTitleLabel.bottomAnchor, constant: 3),
            signupDate.leadingAnchor.constraint(equalTo: signupDateTitleLabel.leadingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: sirLabel.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 30),
            logoutButton.widthAnchor.constraint(equalToConstant: 80),
            
            topBackground.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 10),
            topBackground.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            topBackground.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            topBackground.bottomAnchor.constraint(equalTo: signupDate.bottomAnchor, constant: 10),
            
            // ----------------------------- BUTTON ----------------------------- //
            
            buttonView.topAnchor.constraint(equalTo: topBackground.bottomAnchor, constant: 15),
            buttonView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            buttonView.heightAnchor.constraint(equalToConstant: 30),
            
            basicInfoButton.topAnchor.constraint(equalTo: buttonView.topAnchor),
            basicInfoButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 20),
            basicInfoButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
            
            basiceUnderLine.topAnchor.constraint(equalTo: basicInfoButton.bottomAnchor, constant: 3),
            basiceUnderLine.leadingAnchor.constraint(equalTo: basicInfoButton.leadingAnchor),
            basiceUnderLine.trailingAnchor.constraint(equalTo: basicInfoButton.trailingAnchor),
            basiceUnderLine.heightAnchor.constraint(equalToConstant: 2),
            
            settingButton.topAnchor.constraint(equalTo: buttonView.topAnchor),
            settingButton.leadingAnchor.constraint(equalTo: basicInfoButton.trailingAnchor, constant: 10),
            settingButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
            
            settingUnderLine.topAnchor.constraint(equalTo: settingButton.bottomAnchor, constant: 3),
            settingUnderLine.leadingAnchor.constraint(equalTo: settingButton.leadingAnchor),
            settingUnderLine.trailingAnchor.constraint(equalTo: settingButton.trailingAnchor),
            settingUnderLine.heightAnchor.constraint(equalToConstant: 2),
            
            
            // ----------------------------- View ----------------------------- //
            scrollView.topAnchor.constraint(equalTo: basiceUnderLine.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor),
            
            basicInfoView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            basicInfoView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            basicInfoView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            basicInfoView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            basicInfoView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            settingView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            settingView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            settingView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            settingView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            settingView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // ----------------------------- USER CONTENTS ----------------------------- //
            
            privacyInfo.topAnchor.constraint(equalTo: basicInfoView.topAnchor, constant: 10),
            privacyInfo.leadingAnchor.constraint(equalTo: basicInfoView.leadingAnchor, constant: 20),
            
            // NAME
            nameTitleLabel.topAnchor.constraint(equalTo: privacyInfo.bottomAnchor, constant: 10),
            nameTitleLabel.leadingAnchor.constraint(equalTo: basicInfoView.leadingAnchor, constant: 20),
            
            userNameBackground.topAnchor.constraint(equalTo: nameTitleLabel.bottomAnchor, constant: 5),
            userNameBackground.leadingAnchor.constraint(equalTo: nameTitleLabel.leadingAnchor),
            userNameBackground.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -20),
            userNameBackground.heightAnchor.constraint(equalToConstant: 35),
            
            userNameLabel.centerYAnchor.constraint(equalTo: userNameBackground.centerYAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: userNameBackground.leadingAnchor, constant: 10),
            
            // PHONE
            phoneTitleLabel.topAnchor.constraint(equalTo: userNameBackground.bottomAnchor, constant: 10),
            phoneTitleLabel.leadingAnchor.constraint(equalTo: basicInfoView.leadingAnchor, constant: 20),
            
            phoneBackground.topAnchor.constraint(equalTo: phoneTitleLabel.bottomAnchor, constant: 5),
            phoneBackground.leadingAnchor.constraint(equalTo: phoneTitleLabel.leadingAnchor),
            phoneBackground.trailingAnchor.constraint(equalTo: safeAreaView.centerXAnchor, constant: -5),
            phoneBackground.heightAnchor.constraint(equalToConstant: 35),
            
            phoneLabel.centerYAnchor.constraint(equalTo: phoneBackground.centerYAnchor),
            phoneLabel.leadingAnchor.constraint(equalTo: phoneBackground.leadingAnchor, constant: 10),
            
            // GUARDIAN
            guardianTitleLabel.topAnchor.constraint(equalTo: userNameBackground.bottomAnchor, constant: 10),
            guardianTitleLabel.leadingAnchor.constraint(equalTo: safeAreaView.centerXAnchor, constant: 5),
            
            guardianBackground.topAnchor.constraint(equalTo: guardianTitleLabel.bottomAnchor, constant: 5),
            guardianBackground.leadingAnchor.constraint(equalTo: guardianTitleLabel.leadingAnchor),
            guardianBackground.trailingAnchor.constraint(equalTo: userNameBackground.trailingAnchor),
            guardianBackground.heightAnchor.constraint(equalToConstant: 35),
            
            guardianLabel.centerYAnchor.constraint(equalTo: guardianBackground.centerYAnchor),
            guardianLabel.leadingAnchor.constraint(equalTo: guardianBackground.leadingAnchor, constant: 10),
            
            // BIRTHDAY
            birthdayTitleLabel.topAnchor.constraint(equalTo: phoneBackground.bottomAnchor, constant: 10),
            birthdayTitleLabel.leadingAnchor.constraint(equalTo: basicInfoView.leadingAnchor, constant: 20),
            
            birthdayBackground.topAnchor.constraint(equalTo: birthdayTitleLabel.bottomAnchor, constant: 5),
            birthdayBackground.leadingAnchor.constraint(equalTo: birthdayTitleLabel.leadingAnchor),
            birthdayBackground.heightAnchor.constraint(equalToConstant: 35),
            birthdayBackground.widthAnchor.constraint(equalToConstant: screenWidth / 1.7),
            
            birthdayLabel.centerYAnchor.constraint(equalTo: birthdayBackground.centerYAnchor),
            birthdayLabel.leadingAnchor.constraint(equalTo: birthdayBackground.leadingAnchor, constant: 10),
            
            // AGE
            ageTitleLabel.topAnchor.constraint(equalTo: phoneBackground.bottomAnchor, constant: 10),
            ageTitleLabel.leadingAnchor.constraint(equalTo: birthdayBackground.trailingAnchor, constant: 10),
            
            ageBackground.topAnchor.constraint(equalTo: ageTitleLabel.bottomAnchor, constant: 5),
            ageBackground.leadingAnchor.constraint(equalTo: ageTitleLabel.leadingAnchor),
            ageBackground.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -20),
            ageBackground.heightAnchor.constraint(equalToConstant: 35),
            
            ageLabel.centerYAnchor.constraint(equalTo: ageBackground.centerYAnchor),
            ageLabel.leadingAnchor.constraint(equalTo: ageBackground.leadingAnchor, constant: 10),
            
            // HEIGHT
            heightBackground.topAnchor.constraint(equalTo: ageBackground.bottomAnchor, constant: 32),
            heightBackground.centerXAnchor.constraint(equalTo: safeAreaView.centerXAnchor),
            heightBackground.widthAnchor.constraint(equalToConstant: (screenWidth / 3) - 20),
            heightBackground.heightAnchor.constraint(equalToConstant: 35),
            
            heightTitleLabel.topAnchor.constraint(equalTo: ageBackground.bottomAnchor, constant: 10),
            heightTitleLabel.leadingAnchor.constraint(equalTo: heightBackground.leadingAnchor),
            
            heightLabel.centerYAnchor.constraint(equalTo: heightBackground.centerYAnchor),
            heightLabel.leadingAnchor.constraint(equalTo: heightBackground.leadingAnchor, constant: 10),
            
            // GENDER
            genderTitleLabel.centerYAnchor.constraint(equalTo: heightTitleLabel.centerYAnchor),
            genderTitleLabel.leadingAnchor.constraint(equalTo: birthdayTitleLabel.leadingAnchor),
            
            genderBackground.topAnchor.constraint(equalTo: genderTitleLabel.bottomAnchor, constant: 5),
            genderBackground.leadingAnchor.constraint(equalTo: genderTitleLabel.leadingAnchor),
            genderBackground.trailingAnchor.constraint(equalTo: heightBackground.leadingAnchor, constant: -10),
            genderBackground.heightAnchor.constraint(equalToConstant: 35),
            
            genderLabel.centerYAnchor.constraint(equalTo: genderBackground.centerYAnchor),
            genderLabel.leadingAnchor.constraint(equalTo: genderBackground.leadingAnchor, constant: 10),
            
            // HEIGHT
            weightTitleLabel.centerYAnchor.constraint(equalTo: heightTitleLabel.centerYAnchor),
            weightTitleLabel.leadingAnchor.constraint(equalTo: heightBackground.trailingAnchor, constant: 10),
            
            weightBackground.topAnchor.constraint(equalTo: weightTitleLabel.bottomAnchor, constant: 5),
            weightBackground.leadingAnchor.constraint(equalTo: heightBackground.trailingAnchor, constant: 10),
            weightBackground.trailingAnchor.constraint(equalTo: ageBackground.trailingAnchor),
            weightBackground.heightAnchor.constraint(equalToConstant: 35),
          
            weightLabel.centerYAnchor.constraint(equalTo: weightBackground.centerYAnchor),
            weightLabel.leadingAnchor.constraint(equalTo: weightBackground.leadingAnchor, constant: 10),
            
            // SLEEP
            sleepTitleLabel.topAnchor.constraint(equalTo: genderBackground.bottomAnchor, constant: 10),
            sleepTitleLabel.leadingAnchor.constraint(equalTo: genderTitleLabel.leadingAnchor),
            
            sleepBackground.topAnchor.constraint(equalTo: sleepTitleLabel.bottomAnchor, constant: 5),
            sleepBackground.leadingAnchor.constraint(equalTo: sleepTitleLabel.leadingAnchor),
            sleepBackground.trailingAnchor.constraint(equalTo: safeAreaView.centerXAnchor, constant: -5),
            sleepBackground.heightAnchor.constraint(equalToConstant: 35),
            
            sleepLabel.centerYAnchor.constraint(equalTo: sleepBackground.centerYAnchor),
            sleepLabel.leadingAnchor.constraint(equalTo: sleepBackground.leadingAnchor, constant: 10),
            
            // WAKEUP
            wakeupTitleLabel.topAnchor.constraint(equalTo: weightBackground.bottomAnchor, constant: 10),
            wakeupTitleLabel.leadingAnchor.constraint(equalTo: safeAreaView.centerXAnchor, constant: 5),
            
            wakeupBackground.topAnchor.constraint(equalTo: wakeupTitleLabel.bottomAnchor, constant: 5),
            wakeupBackground.leadingAnchor.constraint(equalTo: wakeupTitleLabel.leadingAnchor),
            wakeupBackground.trailingAnchor.constraint(equalTo: weightBackground.trailingAnchor),
            wakeupBackground.heightAnchor.constraint(equalToConstant: 35),
            
            wakeupLabel.centerYAnchor.constraint(equalTo: wakeupBackground.centerYAnchor),
            wakeupLabel.leadingAnchor.constraint(equalTo: wakeupBackground.leadingAnchor, constant: 10),
            
            // ----------------------------- SETTING CONTENTS ----------------------------- //

            setHelpLabel.topAnchor.constraint(equalTo: settingView.topAnchor, constant: 10),
            setHelpLabel.leadingAnchor.constraint(equalTo: settingView.leadingAnchor, constant: 20),
            
            totalArrLabel.topAnchor.constraint(equalTo: setHelpLabel.bottomAnchor, constant: 20),
            totalArrLabel.leadingAnchor.constraint(equalTo: setHelpLabel.leadingAnchor, constant: 0),
            
            totalArrBackground.topAnchor.constraint(equalTo: totalArrLabel.bottomAnchor, constant: 10),
            totalArrBackground.leadingAnchor.constraint(equalTo: totalArrLabel.leadingAnchor),
            totalArrBackground.trailingAnchor.constraint(equalTo: safeAreaView.centerXAnchor, constant: -10),
            totalArrBackground.heightAnchor.constraint(equalToConstant: 40),
            
            hourlyArrLabel.topAnchor.constraint(equalTo: setHelpLabel.bottomAnchor, constant: 20),
            hourlyArrLabel.leadingAnchor.constraint(equalTo: safeAreaView.centerXAnchor, constant: 10),

            hourlyArrBackground.topAnchor.constraint(equalTo: hourlyArrLabel.bottomAnchor, constant: 10),
            hourlyArrBackground.leadingAnchor.constraint(equalTo: hourlyArrLabel.leadingAnchor),
            hourlyArrBackground.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -20),
            hourlyArrBackground.heightAnchor.constraint(equalToConstant: 40),

        ])
    }
    
}
