import UIKit

// 정규식 설정
let emailRegex = try? NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}$")
let passwordRegex = try? NSRegularExpression(pattern: "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{10,}$")

class SignupView3 : UIViewController, UITextFieldDelegate {
    
    private let safeAreaView = UIView()
    
    private var idInput: String = ""
    private var pwInput: String = ""

    
    // 데이터 입력 확인
    var dataCheck : [String : Bool] = ["이메일":false, "비밀번호":false, "비밀번호 재입력":false]
    
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // Navigation title Label
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "LOOKHEART"
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .black
        
        return label
    }()
    
    let signupText: UILabel = {
        let label = UILabel()
        
        label.text = "회원가입 3/4"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .darkGray
        
        return label
    }()
    
    let progressView: UIProgressView = {
        let progressView = UIProgressView()
        
        progressView.trackTintColor = UIColor(red: 28/255, green: 33/255, blue: 80/255, alpha: 0.9) // 배경 색상
        progressView.progressTintColor = UIColor(red: 98/255, green: 175/255, blue: 255/255, alpha: 1.0) // 진행 색상
        
        // 진행도
        progressView.progress = 0.666
        // 모서리 설정
        progressView.layer.cornerRadius = 5
        progressView.layer.masksToBounds = true
        
        return progressView
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        
        label.text = "아이디 입력"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    let passwordLabel: UILabel = {
        let label = UILabel()
        
        label.text = "비밀번호 입력"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    let reEnterPasswordLabel: UILabel = {
        let label = UILabel()
        
        label.text = "비밀번호 재입력"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    let emailCheckLabel: UILabel = {
        let label = UILabel()
        
        label.text = "유효한 이메일을 입력해주세요"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .red
        label.isHidden = true
        
        return label
    }()
    
    let passwordCheckLabel: UILabel = {
        let label = UILabel()
        
        label.text = "대문자, 소문자, 숫자, 특수문자를 포함한 10자리 이상의 비밀번호"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .red
        label.isHidden = true
        
        return label
    }()
    
    let reEnterPasswordCheckLabel: UILabel = {
        let label = UILabel()
        
        label.text = "비밀번호가 일치하지 않습니다"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .red
        label.isHidden = true
        
        return label
    }()
    
    // email 입력 필드
    let emailTextField: UnderLineTextField = {
        var textField = UnderLineTextField()
        
        textField.textColor = .darkGray // 입력 Text Color
        textField.autocapitalizationType = .none // 자동으로 입력값의 첫 번째 문자를 대문자로 변경
        textField.autocorrectionType = .no // 틀린 글자 체크 no
        textField.spellCheckingType = .no // 스펠링 체크 기능 no
        textField.keyboardType = .emailAddress // 키보드 타입 email type
        
        // placeholder 설정
        textField.placeholderString = "이메일을 입력하세요"
        textField.placeholderColor = .lightGray
        
        return textField
    }()
    
    // password 입력 필드
    let passwordTextField: UnderLineTextField = {
        let textField = UnderLineTextField()
        
        textField.textColor = .darkGray
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.textContentType = .oneTimeCode
        textField.isSecureTextEntry = true // 비밀번호 가리는 기능
        textField.clearsOnBeginEditing = false // 텍스트 필드 터치 시 내용 삭제
        // placeholder 설정
        textField.placeholderString = "비밀번호를 입력하세요"
        textField.placeholderColor = .lightGray
        
        return textField
    }()
    
    let reEnterPasswordTextField: UnderLineTextField = {
        let textField = UnderLineTextField()
        
        textField.textColor = .darkGray
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.textContentType = .oneTimeCode
        textField.isSecureTextEntry = true // 비밀번호 가리는 기능
        textField.clearsOnBeginEditing = false // 텍스트 필드 터치 시 내용 삭제
        
        // placeholder 설정
        textField.placeholderString = "비밀번호를 재입력하세요"
        textField.placeholderColor = .lightGray
        
        return textField
    }()
    
    // 뒤로가기
    lazy var backButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("뒤로가기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.darkGray, for: .normal) // 활성화 .normal / 비활성화 .disabled
        button.layer.borderWidth = 1   // 버튼의 테두리 두께 설정
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 238/255, alpha: 1.0).cgColor
        // 터치 이벤트
        button.addTarget(self, action: #selector(backButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc func backButtonEvent(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    // 다음으로
    lazy var nextButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("다음으로", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.darkGray, for: .normal) // 활성화 .normal / 비활성화 .disabled
        button.layer.borderWidth = 1   // 버튼의 테두리 두께 설정
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 238/255, alpha: 1.0).cgColor
        // 터치 이벤트
        button.addTarget(self, action: #selector(nextButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc func nextButtonEvent(_ sender: UIButton) {
        var alertString: String = ""
        let lastKey = Array(dataCheck.keys)[dataCheck.keys.count - 1]
        
        // 입력 확인
        for(key, value) in dataCheck{
            if(value == false){
                if(key == lastKey){
                    alertString += key
                }
                else{
                    alertString += key + ",\n"
                }
            }
        }
        
        // 열려 있는 텍스트 필드 확인용 배열
        let textFields: [UITextField] = [emailTextField, passwordTextField, reEnterPasswordTextField]
        
        // 키보드가 열려 있을 경우 키보드 사라짐
        for textField in textFields {
            textField.resignFirstResponder()
        }
        
        if(alertString.isEmpty){
            
            NetworkManager.shared.checkIDToServer(id: idInput){ result in
                switch result {
                case .success(let isAvailable):
                    if isAvailable {
                        let signupView = SignupView4()
                        
                        if let encPw = AESEncrypt.shared.encryptStringWithAES_ECB(text: self.pwInput) {
                            if Keychain.shared.setString(encPw, forKey: "password") {
                                print("Keychain : setPassword")
                            } else {
                                print("Keychain : setPassword Err")
                            }
                        } else {
                            print("Encryption error: Could not encrypt password")
                        }
                        
                        if Keychain.shared.setString(self.idInput, forKey: "email") {
                            print("Keychain : setEmail")
                        } else {
                            print("Keychain : setEmail Err")
                        }
                        
                        self.navigationController?.pushViewController(signupView, animated: true)
                        
                    } else {
                        let alert = UIAlertController(title: "알림", message: "중복된 아이디입니다.", preferredStyle: UIAlertController.Style.alert)
                        let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
                        alert.addAction(cancel)
                        self.present(alert, animated: false)
                    }
                case .failure(let error):
                    ToastHelper.shared.showToast(message: "서버 응답 없음", view: self.view)
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        else{
            let alert = UIAlertController(title: "알림", message: alertString+"을(를)\n 입력하지 않았습니다", preferredStyle: UIAlertController.Style.alert)
            let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: false)
        }
    }
    
    
    lazy var buttonView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, nextButton])
        
        stackView.spacing = 40
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        Constraints()
        
        // safeAreaView 설정
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                safeAreaView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                guide.bottomAnchor.constraint(equalToSystemSpacingBelow: safeAreaView.bottomAnchor, multiplier: 1.0)
            ])
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                safeAreaView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                bottomLayoutGuide.topAnchor.constraint(equalTo: safeAreaView.bottomAnchor, constant: standardSpacing)
            ])
        }
    
        // Navigationbar Title 왼쪽 정렬
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        // Back 버튼 설정 true : 화면에 보여짐
        //self.navigationItem.leftItemsSupplementBackButton = true
        
        // keybord dismiss by touching anywhere in the view
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        let heightAnchor = containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightAnchor.priority = .defaultHigh
        heightAnchor.isActive = true
        
    }
    
    func setup(){
        view.backgroundColor = .white
        safeAreaView.backgroundColor = UIColor(red: 249/255, green: 250/255, blue: 252/255, alpha: 1.0)
        
        addViews()
        
    }
    
    func addViews(){
        view.addSubview(safeAreaView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(signupText)
        containerView.addSubview(progressView)
        
        emailTextField.delegate = self
        emailTextField.tag = 1
        containerView.addSubview(emailLabel)
        containerView.addSubview(emailTextField)
        
        passwordTextField.delegate = self
        passwordTextField.tag = 2
        containerView.addSubview(passwordLabel)
        containerView.addSubview(passwordTextField)
        
        reEnterPasswordTextField.delegate = self
        reEnterPasswordTextField.tag = 3
        containerView.addSubview(reEnterPasswordLabel)
        containerView.addSubview(reEnterPasswordTextField)
        
        containerView.addSubview(emailCheckLabel)
        containerView.addSubview(passwordCheckLabel)
        containerView.addSubview(reEnterPasswordCheckLabel)
        
        containerView.addSubview(buttonView)
        
    }
    
    func Constraints(){
        
        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        signupText.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        // label
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        reEnterPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        // textField
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        reEnterPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        // 유효성 안내 문구
        emailCheckLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordCheckLabel.translatesAutoresizingMaskIntoConstraints = false
        reEnterPasswordCheckLabel.translatesAutoresizingMaskIntoConstraints = false
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            // safeAreaView
            safeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: safeAreaView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // signupText
            signupText.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            signupText.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // progressView
            progressView.topAnchor.constraint(equalTo: signupText.bottomAnchor, constant: 10),
            progressView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            progressView.heightAnchor.constraint(equalToConstant: 20),

            // email
            emailLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 60), // label
            emailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 43), // label
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
                    
            // password
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30), // label
            passwordLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 43), // label
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 5),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
                        
            // reEnterPassword
            reEnterPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30), // label
            reEnterPasswordLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 43), // label
            
            reEnterPasswordTextField.topAnchor.constraint(equalTo: reEnterPasswordLabel.bottomAnchor, constant: 5),
            reEnterPasswordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            reEnterPasswordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            
            // 유효성 안내 문구
            emailCheckLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 3),
            emailCheckLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            passwordCheckLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 3),
            passwordCheckLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            reEnterPasswordCheckLabel.topAnchor.constraint(equalTo: reEnterPasswordTextField.bottomAnchor, constant: 3),
            reEnterPasswordCheckLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            
            // buttonView
            buttonView.topAnchor.constraint(equalTo: reEnterPasswordTextField.bottomAnchor, constant: 30),
            buttonView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonView.heightAnchor.constraint(equalToConstant: 60),
            
            
        ])
    }
    
    // MARK: textField event
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Called just before UITextField is edited
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //print("textFieldDidBeginEditing: \((textField.text) ?? "Empty")")
    }
    
    // Called immediately after UITextField is edited
    func textFieldDidEndEditing(_ textField: UITextField) {
        let txt = textField.text ?? "Empty"
        
        // email
        if textField.tag == 1 {
            if let _ = emailRegex?.firstMatch(in: txt, options: [], range: NSRange(location: 0, length: txt.count)){
            }
            else{
                emailTextField.setError()
            }
         }
        // password
        else if textField.tag == 2 {
            if let _ = passwordRegex?.firstMatch(in: txt, options: [], range: NSRange(location: 0, length: txt.count)){
            }
            else{
                passwordTextField.setError()
            }
        }
        // reEnterPassword
        else if textField.tag == 3 {
            if(pwInput == txt){
            }
            else{
                reEnterPasswordTextField.setError()
            }
        }
    }
    
    // Called when the line feed button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // return 버튼 눌렀을 때 키보드 사라지도록 설정
        textField.resignFirstResponder()
        return true
    }
    
    // 실시간 입력 반응
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let txt = textField.text ?? "Empty"
        
        // email
        if textField.tag == 1 {
            if let _ = emailRegex?.firstMatch(in: txt, options: [], range: NSRange(location: 0, length: txt.count)){
                idInput = txt
                emailCheckLabel.isHidden = true
                dataCheck["이메일"] = true
            }
            else{
                emailCheckLabel.isHidden = false
                dataCheck["이메일"] = false
            }
         }
        // password
        else if textField.tag == 2 {
            if let _ = passwordRegex?.firstMatch(in: txt, options: [], range: NSRange(location: 0, length: txt.count)){
                pwInput = txt
                passwordCheckLabel.isHidden = true
                dataCheck["비밀번호"] = true
            }
            else{
                passwordCheckLabel.isHidden = false
                dataCheck["비밀번호"] = false
            }
        }
        // reEnterPassword
        else{
            if(pwInput == txt){
                reEnterPasswordCheckLabel.isHidden = true
                dataCheck["비밀번호 재입력"] = true
            }
            else{
                reEnterPasswordCheckLabel.isHidden = false
                dataCheck["비밀번호 재입력"] = false
            }
        }
    }
    
    // keybord up, down event
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
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
    
}

// underLine TextField
class UnderLineTextField: UITextField {

    lazy var placeholderColor: UIColor = self.tintColor
    lazy var placeholderString: String = ""

    // 입력 Text 여백
    var textPadding = UIEdgeInsets (
        top: 0, left: 3, bottom: 3, right: 0
        )
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    // underLine
    private lazy var underLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .lightGray
        return lineView
    }()

    override init(frame: CGRect){
        super.init(frame: frame)

        addSubview(underLineView)

        underLineView.snp.makeConstraints {
            $0.top.equalTo(self.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        // textField 변경 시작과 종료에 대한 action
        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // placeholder 설정
    func setPlaceholder(placeholder: String, color: UIColor){
        placeholderString = placeholder
        placeholderColor = color
        
        setPlaceholder()
        underLineView.backgroundColor = placeholderColor
    }

    func setPlaceholder() {
        self.attributedPlaceholder = NSAttributedString(
            string: placeholderString,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor, .font: UIFont.systemFont(ofSize: 13)]
        )
    }
    
    func setError() {
        // 글자색 변경
//        self.attributedPlaceholder = NSAttributedString(
//            string: placeholderString,
//            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
//        )
        underLineView.backgroundColor = .red
    }
    
}

extension UnderLineTextField {
    @objc func editingDidBegin(){
        setPlaceholder()
        underLineView.backgroundColor = self.tintColor
    }
    @objc func editingDidEnd(){
        underLineView.backgroundColor = placeholderColor
    }
}
