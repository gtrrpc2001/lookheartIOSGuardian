import UIKit
import LookheartPackage
import FirebaseMessaging

class LoginView : BaseViewController, UITextFieldDelegate{
        
    private let ID_TAG = 1, PW_TAG = 2, PHONE_TAG = 3
    
    private var identifier: String?, password: String?, phone: String?
    private var authLogin = false
    
    private var keyboardHandler: KeyboardEventHandling?
    private var scrollView = UIScrollView()
    private var containerView = UIView()
    
    // MARK: - Button Event
    @objc private func autoLoginTapped(_ sender: UIButton) {
        authLogin = !authLogin
        
        if authLogin {
            sender.setImage(UIImage(named: "check"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "circle"), for: .normal)
        }
    }
        
    @objc private func loginButtonEvent(_ sender: UIButton) {
        if let identifier = identifier, let password = password, let phone = phone {
            NetworkManager.shared.checkLoginToServer(id: identifier, pw: password, phone: phone) { [self] result in
                switch result {
                    
                case .success(let isAvailable):
                    switch isAvailable {
                        
                    case .successLogin:
                        loginEvent()
                    case .failureLogin:
                        propAlert.basicAlert(title: "noti".localized(), message: "failLogin".localized(), ok: "ok".localized(), viewController: self)
                    case .duplicateLogin:
                        propAlert.basicAlert(title: "noti".localized(), message: "duplicateLogin".localized(), ok: "ok".localized(), viewController: self)
                    }
                    
                case .failure(let error):
                    // Failure Network Task
                    print("Error: \(error.localizedDescription)")
                    ToastHelper.shared.showToast(self.view, "serverErr".localized())
                }
            }
        } else {
            // Empty Alert
            propAlert.basicAlert(title: "noti".localized(), message: "lignAlert".localized(), ok: "ok".localized(), viewController: self)
        }
    }
    
    private func loginEvent() {
                
        func saveUserData(_ userData: [String]){
            let forKey = ["email", "password", "phone"]
            
            for (index, data) in userData.enumerated() {
                Keychain.shared.setValue(data, forKey: forKey[index])
            }
        }
        
        
        if Keychain.shared.setBool(true, forKey: "login") {
            print("Keychain : setLogin")
        }
        
        saveUserData([identifier!, password!, phone!])
        
        // Log
        if let guardian = Keychain.shared.getString(forKey: "phone") {
            NetworkManager.shared.sendLog(id: propEmail, userType: .Guardian, action: .Login, phone: guardian)
        }
        
        defaults.set(authLogin, forKey: "autoLoginFlag")
        FCM.shared.createFCMToken()
        
        view.window?.rootViewController = TabBarController()
        view.window?.makeKeyAndVisible()
    }
        
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        
        keyboardHandler = KeyboardEventHandling(scrollView: scrollView)

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardHandler?.startObserving()   // Keyboard Show Event
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardHandler?.stopObserving()    // Keyboard Hide Event
    }
    
    // MARK: - TextField Event
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Called when the line feed button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? "Empty"
        
        switch(textField.tag){
        case ID_TAG:
            identifier = text
        case PW_TAG:
            password = text
        case PHONE_TAG:
            phone = text
        default:
            break
        }
    }
    
    //MARK: - addViews
    func addViews(){
        
        /*------------------------- ScrollView Start ------------------------*/
        // addSubview
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        // makeConstraints
        scrollView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(safeAreaView)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.left.right.width.equalTo(scrollView)
        }
        /*------------------------- ScrollView End ------------------------*/
        
        
        
        
        /*------------------------- Login Help Text Start ------------------------*/
        // create
        let loginLabel = propCreateUI.label(text: "loginLabel".localized(), color: .black, size: 18, weight: .heavy)
        
        let loginTextLabel = propCreateUI.label(text: "loginText".localized(), color: .lightGray, size: 14, weight: .semibold).then {
            $0.numberOfLines = 2
        }
        
        // addSubview
        containerView.addSubview(loginLabel)
        containerView.addSubview(loginTextLabel)
        
        // makeConstraints
        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(20)
            make.left.equalTo(containerView).offset(15)
        }
        
        loginTextLabel.snp.makeConstraints { make in
            make.top.equalTo(loginLabel.snp.bottom).offset(20)
            make.left.equalTo(loginLabel)
        }
        /*------------------------- Login Help Text End ------------------------*/
        
        
        
        
        /*------------------------- Login Start ------------------------*/
        // func
        func createTextField(placeholderText: String, tag: Int) -> UITextField {
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                              .font: UIFont.systemFont(ofSize: 12)]
            
            let textField = UITextField().then {
                $0.textColor = .darkGray
                $0.tintColor = .darkGray
                $0.font = UIFont.systemFont(ofSize: 16)
                $0.backgroundColor = UIColor.PROFILE_BACKGROUND
                $0.layer.cornerRadius = 10
                $0.clipsToBounds = true
                $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
                $0.leftViewMode = .always
                $0.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
                $0.delegate = self
                $0.tag = tag
            }
            return textField
        }
        
        // create
        let idTitleLabel = propCreateUI.label(text: "email_Label".localized(), color: .black, size: 12, weight: .medium)
        
        let pwTitleLabel = propCreateUI.label(text: "password_Label".localized(), color: .black, size: 12, weight: .medium)
        
        let phoneLabel = propCreateUI.label(text: "guardian_Label".localized(), color: .black, size: 12, weight: .medium)
        
        let emailTextField = createTextField(placeholderText: "email_Hint".localized(), tag: ID_TAG).then {
            $0.keyboardType = .emailAddress
            $0.autocapitalizationType = .none   // First Char
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
        }
        
        let passWordTextField = createTextField(placeholderText: "password_Hint".localized(), tag: PW_TAG).then {
            $0.isSecureTextEntry = true
            $0.clearsOnBeginEditing = false
        }
        
        let phoneTextField = createTextField(placeholderText: "guardian_Hint".localized(), tag: PHONE_TAG).then {
            $0.keyboardType = .numberPad

        }
        
        // addSubview
        containerView.addSubview(idTitleLabel)
        containerView.addSubview(pwTitleLabel)
        containerView.addSubview(phoneLabel)
        
        containerView.addSubview(emailTextField)
        containerView.addSubview(passWordTextField)
        containerView.addSubview(phoneTextField)
        
        // makeConstraints
        idTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(loginTextLabel.snp.bottom).offset(20)
            make.left.equalTo(containerView).offset(40)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(idTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(idTitleLabel)
            make.right.equalTo(containerView).offset(-40)
            make.height.equalTo(40)
        }
        
        
        pwTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(10)
            make.left.equalTo(idTitleLabel)
        }
        
        passWordTextField.snp.makeConstraints { make in
            make.top.equalTo(pwTitleLabel.snp.bottom).offset(10)
            make.left.right.height.equalTo(emailTextField)
        }
        
        
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(passWordTextField.snp.bottom).offset(10)
            make.left.equalTo(idTitleLabel)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneLabel.snp.bottom).offset(10)
            make.left.right.height.equalTo(emailTextField)
        }
        /*------------------------- Login End ------------------------*/
        
        
        
        
        /*------------------------- Button Start ------------------------*/
        // create
        let autoLoginButton = propCreateUI.button(title: "autoLogin".localized(), titleColor: .darkGray, size: 12, weight: .bold, backgroundColor: .clear, tag: 0).then {
            let img = UIImage(named: "circle")
            $0.setImage(img, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
            $0.imageEdgeInsets = .init(top: 11, left: -15, bottom: 11, right: 0)
            $0.addTarget(self, action: #selector(autoLoginTapped(_:)), for: .touchUpInside)
        }

        let loginButton = propCreateUI.button(title: "loginLabel".localized(), titleColor: .white, size: 14, weight: .heavy, backgroundColor: UIColor.LOGIN_BUTTON, tag: 0).then {
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
            $0.addTarget(self, action: #selector(loginButtonEvent(_:)), for: .touchUpInside)
        }
        
        // addSubview
        containerView.addSubview(autoLoginButton)
        containerView.addSubview(loginButton)
        
        // makeConstraints
        autoLoginButton.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(5)
            make.left.equalTo(phoneTextField).offset(-5)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(autoLoginButton.snp.bottom).offset(5)
            make.left.right.height.equalTo(emailTextField)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        /*------------------------- Button End ------------------------*/

    }
}
