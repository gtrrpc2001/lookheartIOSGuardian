import UIKit
import FirebaseMessaging

class LoginView : BaseViewController, UITextFieldDelegate{
    
    private let ID_TEXTFIELD_TAG = 1
    private let PW_TEXTFIELD_TAG = 2
    private let PHONE_TEXTFIELD_TAG = 3
    
    private var idInput: String = ""
    private var pwInput: String = ""
    private var phoneInput: String = ""
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    // MARK: - Top Label
    private let loginLabel: UILabel = {
        let label = UILabel()
        
        label.text = "loginLabel".localized()
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        label.textColor = .black
        
        return label
    }()
    
    private let loginTextLabel: UILabel = {
        let label = UILabel()
        label.text = "loginText".localized()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .lightGray
        return label
    }()

    // MARK: - Email var
    private var idTitleLabel: UILabel = {
        var label = UILabel()
        
        label.text = "email_Label".localized()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        
        return label
    }()

    private var emailTextField: UITextField! = {
        let textField = UITextField()
        
        textField.frame.size.height = 40 // TextField의 높이 설정
        textField.backgroundColor = UIColor(red: 0xef/255, green: 0xf0/255, blue: 0xf2/255, alpha: 1.0)
        textField.textColor = .darkGray // 입력 Text Color
        //textField.tintColor = .blue // 입력 시 변하는 TextField 색 설정
        textField.autocapitalizationType = .none // 자동으로 입력값의 첫 번째 문자를 대문자로 변경
        textField.autocorrectionType = .no // 틀린 글자 체크 no
        textField.spellCheckingType = .no // 스펠링 체크 기능 no
        textField.keyboardType = .emailAddress // 키보드 타입 email type
        
        // 테두리
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        
        // 크기
        textField.font = UIFont.systemFont(ofSize: 16)
        
        // 왼쪽 여백
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
       
        // placeHolder
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                          .font: UIFont.systemFont(ofSize: 12)]

        textField.attributedPlaceholder = NSAttributedString(string: "email_Hint".localized(), attributes: attributes)
        
        return textField
    }()
    
    // MARK: - Password var
    private var pwTitleLabel: UILabel = {
        var label = UILabel()
        
        label.text = "password_Label".localized()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        
        return label
    }()
    
    // 비밀번호 입력 필드
    private lazy var passWordTextField: UITextField = {
        let textField = UITextField()
        
        textField.frame.size.height = 40 // TextField의 높이 설정
        textField.backgroundColor = UIColor(red: 0xef/255, green: 0xf0/255, blue: 0xf2/255, alpha: 1.0)
        textField.textColor = .darkGray // 입력 Text Color
        //textField.tintColor = .blue // 입력 시 변하는 TextField 색 설정
        textField.autocapitalizationType = .none // 자동으로 입력값의 첫 번째 문자를 대문자로 변경
        textField.autocorrectionType = .no // 틀린 글자 체크 no
        textField.spellCheckingType = .no // 스펠링 체크 기능 no
        textField.isSecureTextEntry = true // 비밀번호 가리는 기능
        textField.clearsOnBeginEditing = false // 텍스트 필드 터치 시 내용 삭제
        
        // 테두리
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        
        // 크기
        textField.font = UIFont.systemFont(ofSize: 16)
        
        // 왼쪽 여백
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
        
        // placeHolder
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                          .font: UIFont.systemFont(ofSize: 12)]
        textField.attributedPlaceholder = NSAttributedString(string: "password_Hint".localized(), attributes: attributes)
        
        return textField
    }()
    
    // MARK: - Phone var
    private var phoneLabel: UILabel = {
        var label = UILabel()
        
        label.text = "guardian_Label".localized()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        
        return label
    }()

    private var phoneTextField: UITextField! = {
        let textField = UITextField()
        
        textField.frame.size.height = 40
        textField.backgroundColor = UIColor(red: 0xef/255, green: 0xf0/255, blue: 0xf2/255, alpha: 1.0)
        textField.textColor = .darkGray
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.keyboardType = .numberPad
        
        // 테두리
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        
        // 크기
        textField.font = UIFont.systemFont(ofSize: 16)
        
        // 왼쪽 여백
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
       
        // placeHolder
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                          .font: UIFont.systemFont(ofSize: 12)]

        textField.attributedPlaceholder = NSAttributedString(string: "guardian_Hint".localized(), attributes: attributes)
        
        return textField
    }()
    
    // MARK: - Auth var
    private lazy var autoLoginButton: UIButton = {
        let button = UIButton()
        var img = UIImage(named: "circle")
        
        if(UserDefaults.standard.bool(forKey: "autoLogin")){
            img = UIImage(named: "check")
        }
        else{
            img = UIImage(named: "circle")
        }
        
        button.setTitle("autoLogin".localized(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        button.setTitleColor(.darkGray, for: .normal)
        button.setImage(img, for: .normal)
        
        //button.backgroundColor = .blue // 버튼 터치 범위 확인
        
        // button img size
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = .init(top: 11, left: -15, bottom: 11, right: 0)
        
        // 터치 이벤트
        button.addTarget(self, action: #selector(autoLoginTapped(_:)), for: .touchUpInside)

       return button
    }()
    
    @objc private func autoLoginTapped(_ sender: UIButton) {
        if(UserDefaults.standard.bool(forKey: "autoLogin")){
            UserDefaults.standard.set(false, forKey: "autoLogin")
            sender.setImage(UIImage(named: "circle"), for: .normal)
        }
        else {
            UserDefaults.standard.set(true, forKey: "autoLogin")
            sender.setImage(UIImage(named: "check"), for: .normal)
        }
    }
    
    // MARK: - Login var
    private lazy var loginButton: UIButton = {
        var button = UIButton(type: .custom)
        
        button.setTitle("loginLabel".localized(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal) // 활성화 .normal / 비활성화 .disabled
        //button.layer.borderWidth = 1   // 버튼의 테두리 두께 설정
        button.backgroundColor = UIColor(red: 0x33/255, green: 0x47/255, blue: 0x71/255, alpha: 1.0)
        button.isEnabled = true
        
        button.addTarget(self, action: #selector(loginButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()

    @objc private func loginButtonEvent(_ sender: UIButton) {
        
        let EncryptPassword = AESEncrypt.shared.encryptStringWithAES_ECB(text: pwInput)!
        loginServerTask(idInput, EncryptPassword, phoneInput) { success in
            if success {
                DispatchQueue.main.async {
                    // 자동 로그인 플래그
                    if(UserDefaults.standard.bool(forKey: "autoLogin")){
                        UserDefaults.standard.set(true, forKey: "autoLoginFlag")
                    } else {
                        UserDefaults.standard.set(false, forKey: "autoLoginFlag")
                    }
                    
                    self.setKeychain([self.idInput, EncryptPassword, self.phoneInput])
                    self.sendToken(self.idInput, EncryptPassword, self.phoneInput)
                                        
                    self.view.window?.rootViewController = TabBarController()
                    self.view.window?.makeKeyAndVisible()
                }
            } else {
                // 로그인 실패 처리
                let alert = UIAlertController(title: "loginFailed".localized(), message: "incorrectlyLogin".localized(), preferredStyle: UIAlertController.Style.alert)
                let cancel = UIAlertAction(title: "ok".localized(), style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(cancel)
                self.present(alert, animated: false)
            }
        }
    }
    
    // MARK: - server
    func loginServerTask(_ id: String, _ pw: String, _ phone: String, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.checkLoginToServer(id: id, pw: pw, phone: phone) { result in
            switch result {
            case .success(let isAvailable):
                completion(isAvailable)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                ToastHelper.shared.showToast(self.view, "serverErr".localized(), withDuration: 2.0, delay: 2.0)
                completion(false)
            }
        }
    }
    
    func sendToken(_ email: String, _ password: String, _ phone: String) {
        sendTokenServerTask(email: email, password: password, phone: phone) { success in
            if success {
                print("send token success")
            } else {
                print("send token fail")
            }
        }
    }
    
    func sendTokenServerTask(email: String, password: String, phone: String, completion: @escaping (Bool) -> Void) {
        let token = Keychain.shared.getString(forKey: "token") ?? nil
        let logout = Keychain.shared.getBool(forKey: "logout") 
        
        if token != nil && !logout {
            NetworkManager.shared.sendToken(id: email, password: password, phone: phone, token: token!) { result in
                switch result {
                case .success(let isAvailable):
                    completion(isAvailable)
                    break
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    completion(false)
                    break
                }
            }
        } else { // 토큰이 없거나 로그아웃 후 재 로그인 시 토큰 재생성
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                } else if let token = token {
                    print("FCM registration token")
                    
                    NetworkManager.shared.sendToken(id: email, password: password, phone: phone, token: token) { result in
                        switch result {
                        case .success(let isAvailable):
                            if Keychain.shared.setBool(false, forKey: "logout"){
                                print("setBool : false, forkey: logout")
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
            }
        }
    }
    
    func setKeychain(_ userData: [String]){
        let forKey = ["email", "password", "phone"]
        var i = 0
        
        for data in userData {
            if !Keychain.shared.setString(data, forKey: forKey[i]) {
                print("Failed to save data to the keychain")
            }
            i += 1
        }
        
        if !Keychain.shared.setBool(true, forKey: "login") {
            print("Failed to save data to the keychain")
        }
    }

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        Constraints()
        setTapGesture()
        
    }
    
    // MARK: - TextField event
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Called just before UITextField is edited
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch(textField.tag){
        case ID_TEXTFIELD_TAG:
            emailTextField.placeholder = ""
            break
        case PW_TEXTFIELD_TAG:
            passWordTextField.placeholder = ""
            break
        case PHONE_TEXTFIELD_TAG:
            phoneTextField.placeholder = ""
            break
        default:
            break
        }
    }
    
    // Called immediately after UITextField is edited
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch(textField.tag){
        case ID_TEXTFIELD_TAG:
            if emailTextField.placeholder == "" { emailTextField.placeholder = "email_Hint".localized() }
            break
        case PW_TEXTFIELD_TAG:
            if passWordTextField.placeholder == "" { passWordTextField.placeholder = "password_Hint".localized() }
            break
        case PHONE_TEXTFIELD_TAG:
            if phoneTextField.placeholder == "" { phoneTextField.placeholder = "guardian_Hint".localized() }
            break
        default:
            break
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch(textField.tag){
        case ID_TEXTFIELD_TAG:
            idInput = textField.text ?? "Empty"
            break
        case PW_TEXTFIELD_TAG:
            pwInput = textField.text ?? "Empty"
            break
        case PHONE_TEXTFIELD_TAG:
            phoneInput = textField.text ?? "Empty"
            break
        default:
            break
        }
    }
    
    // Called when the line feed button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - keybord event
    private func setTapGesture() {
        // keybord dismiss by touching anywhere in the view
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        let heightAnchor = containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightAnchor.priority = .defaultHigh
        heightAnchor.isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) { // keybord up, down event
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) { // keybord up, down event
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드 입력 시 키보드 사이즈를 알아내어 스크롤 뷰로 보여줌
    @objc func keyboardUp(notification:NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }
        
        let contentInset = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: keyboardFrame.size.height,
            right: 0.0)
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
    }

    @objc func keyboardDown() {
        self.view.transform = .identity
        
        // 키보드 사라질 시 화면 복구
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    //MARK: - layout
    func addViews(){
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(loginLabel)
        containerView.addSubview(loginTextLabel)
        
        emailTextField.delegate = self
        emailTextField.tag = ID_TEXTFIELD_TAG
        containerView.addSubview(idTitleLabel)
        containerView.addSubview(emailTextField)

        passWordTextField.delegate = self
        passWordTextField.tag = PW_TEXTFIELD_TAG
        containerView.addSubview(pwTitleLabel)
        containerView.addSubview(passWordTextField)

        phoneTextField.delegate = self
        phoneTextField.tag = PHONE_TEXTFIELD_TAG
        containerView.addSubview(phoneLabel)
        containerView.addSubview(phoneTextField)
        
        containerView.addSubview(autoLoginButton)
        containerView.addSubview(loginButton)

    }
    
    func Constraints(){
        
        let safeAreaView = getSafeAreaView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        loginTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        idTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        pwTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        passWordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        
        autoLoginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                
            scrollView.topAnchor.constraint(equalTo: safeAreaView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            loginLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            loginLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            
            loginTextLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 20),
            loginTextLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 15),
            
            idTitleLabel.topAnchor.constraint(equalTo: loginTextLabel.bottomAnchor, constant: 20),
            idTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            
            emailTextField.topAnchor.constraint(equalTo: idTitleLabel.bottomAnchor, constant: 10),
            emailTextField.leadingAnchor.constraint(equalTo: idTitleLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            pwTitleLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
            pwTitleLabel.leadingAnchor.constraint(equalTo: idTitleLabel.leadingAnchor),
            
            passWordTextField.topAnchor.constraint(equalTo: pwTitleLabel.bottomAnchor, constant: 10),
            passWordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passWordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passWordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            phoneLabel.topAnchor.constraint(equalTo: passWordTextField.bottomAnchor, constant: 10),
            phoneLabel.leadingAnchor.constraint(equalTo: pwTitleLabel.leadingAnchor),
            
            phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 10),
            phoneTextField.leadingAnchor.constraint(equalTo: passWordTextField.leadingAnchor),
            phoneTextField.trailingAnchor.constraint(equalTo: passWordTextField.trailingAnchor),
            phoneTextField.heightAnchor.constraint(equalToConstant: 40),
            
            autoLoginButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 5),
            autoLoginButton.leadingAnchor.constraint(equalTo: phoneTextField.leadingAnchor, constant: -5),
        
            loginButton.topAnchor.constraint(equalTo: autoLoginButton.bottomAnchor, constant: 10),
            loginButton.leadingAnchor.constraint(equalTo: passWordTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: passWordTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
            
        ])
    }
}
