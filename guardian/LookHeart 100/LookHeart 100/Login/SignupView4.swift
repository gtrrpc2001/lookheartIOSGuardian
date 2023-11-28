import UIKit

let nameRegex = try? NSRegularExpression(pattern: "^[가-힣]{1,5}|[a-zA-Z]{2,10}[a-zA-Z]{2,10}$")
let heightAndWeightRegex = try? NSRegularExpression(pattern: "^[0-9]{1,3}$")
let targetNumberRegex = try? NSRegularExpression(pattern: "^[0-9]{1,5}$")
let phoneNumberRegex = try? NSRegularExpression(pattern: "^[0-9]{9,11}$")

class SignupView4 : UIViewController, UITextFieldDelegate {
    
    private let safeAreaView = UIView()
    
    private var myName: String = ""
    private var myHeight: String = ""
    private var myWeight: String = ""
    
    var date:String = ""
    var birthday:String = ""
    var dateComponents = DateComponents()
    // 이미지 설정
    let image =  UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .light))?.withTintColor(.black, renderingMode: .alwaysOriginal)
    let checkImage =  UIImage(systemName: "record.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .light))?.withTintColor(.black, renderingMode: .alwaysOriginal)
    
    // 데이터 입력 확인
    var dataCheck : [String : Bool] = ["이름":false, "신장":false, "몸무게":false, "성별":false, "생년월일":false]
    
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
        
        label.text = "회원가입 4/4"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .darkGray
        
        return label
    }()
    
    let progressView: UIProgressView = {
        let progressView = UIProgressView()
        
        progressView.trackTintColor = UIColor(red: 28/255, green: 33/255, blue: 80/255, alpha: 0.9) // 배경 색상
        progressView.progressTintColor = UIColor(red: 98/255, green: 175/255, blue: 255/255, alpha: 1.0) // 진행 색상
        
        // 진행도
        progressView.progress = 1.0
        // 모서리 설정
        progressView.layer.cornerRadius = 5
        progressView.layer.masksToBounds = true
        
        return progressView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "이름"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    let heightLabel: UILabel = {
        let label = UILabel()
        
        label.text = "신장 cm"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    let weightLabel: UILabel = {
        let label = UILabel()
        
        label.text = "몸무게 kg"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    let nameCheckLabel: UILabel = {
        let label = UILabel()
        
        label.text = "올바른 이름을 입력해주세요"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .red
        label.isHidden = true
        
        return label
    }()
    
    let heightCheckLabel: UILabel = {
        let label = UILabel()
        
        label.text = "올바른 신장을 입력해주세요"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .red
        label.isHidden = true
        
        return label
    }()
    
    let weightCheckLabel: UILabel = {
        let label = UILabel()
        
        label.text = "올바른 몸무게를 입력해주세요"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .red
        label.isHidden = true
        
        return label
    }()
    
    // 이름 입력 필드
    let nameTextField: UnderLineTextField = {
        var textField = UnderLineTextField()
        
        textField.textColor = .darkGray // 입력 Text Color
        textField.autocapitalizationType = .none // 자동으로 입력값의 첫 번째 문자를 대문자로 변경
        textField.autocorrectionType = .no // 틀린 글자 체크 no
        textField.spellCheckingType = .no // 스펠링 체크 기능 no
        
        // placeholder 설정
        textField.placeholderString = "성함을 입력해주세요"
        textField.placeholderColor = .lightGray
        
        return textField
    }()
    
    // 신장 입력 필드
    let heightTextField: UnderLineTextField = {
        let textField = UnderLineTextField()
        
        textField.textColor = .darkGray
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        
        // placeholder 설정
        textField.placeholderString = "신장을 입력해주세요"
        textField.placeholderColor = .lightGray
        
        return textField
    }()
    
    // 몸무게 입력 필드
    let weightTextField: UnderLineTextField = {
        let textField = UnderLineTextField()
        
        textField.textColor = .darkGray
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        
        // placeholder 설정
        textField.placeholderString = "몸무게를 입력해주세요"
        textField.placeholderColor = .lightGray
        
        return textField
    }()
    // male icon
    lazy var maleLabel: UILabel = {
        let label = UILabel()
        
        label.text =  "♂"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        
        return label
    }()
    // female icon
    lazy var femaleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "♀"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        
        return label
    }()
    
    // 남자
    lazy var maleButton: UIButton = {
        let button = UIButton()
        
        UserDefaults.standard.set(false, forKey: "male")
        button.setTitle("남자", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.backgroundColor = .clear
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal) // 활성화 .normal / 비활성화
        //button.backgroundColor = .blue // 터치 범위 확인
        // 하드 코딩 수정 필요
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 50, bottom: 20, right: 50)
        
        // 터치 이벤트
        button.addTarget(self, action: #selector(maleButtonEvent(_:)), for: .touchUpInside)

        return button
    }()
    
    // 버튼 터치 이벤트
    @objc func maleButtonEvent(_ sender: UIButton) {
        if(UserDefaults.standard.bool(forKey: "male")){
            UserDefaults.standard.set(false, forKey: "male")
            maleCheckImage.image = image
            dataCheck["성별"] = false
        }
        else {
            UserDefaults.standard.set(true, forKey: "male")
            // female이 true일 경우 false로 바꾸고 이미지 변경
            if(UserDefaults.standard.bool(forKey: "female")){
                UserDefaults.standard.set(false, forKey: "female")
                femaleCheckImage.image = image
            }
            maleCheckImage.image = checkImage
            dataCheck["성별"] = true
        }
    }
    
    // 여자
    lazy var femaleButton: UIButton = {
        let button = UIButton()
        
        UserDefaults.standard.set(false, forKey: "female")
        button.setTitle("여자", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.backgroundColor = .clear
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal) // 활성화 .normal / 비활성화
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 50, bottom: 20, right: 50)
        //button.backgroundColor = .blue // 터치 범위 확인
        
        // 터치 이벤트
        button.addTarget(self, action: #selector(femaleButtonEvent(_:)), for: .touchUpInside)

        return button
    }()
    
    // 버튼 터치 이벤트
    @objc func femaleButtonEvent(_ sender: UIButton) {
        if(UserDefaults.standard.bool(forKey: "female")){
            UserDefaults.standard.set(false, forKey: "female")
            femaleCheckImage.image = image
            dataCheck["성별"] = false
        }
        else {
            UserDefaults.standard.set(true, forKey: "female")
            // male이 true일 경우 false로 바꾸고 이미지 변경
            if(UserDefaults.standard.bool(forKey: "male")){
                UserDefaults.standard.set(false, forKey: "male")
                maleCheckImage.image = image
            }
            femaleCheckImage.image = checkImage
            dataCheck["성별"] = true
        }
    }
    
    
    lazy var maleCheckImage: UIImageView = {
        var imageView = UIImageView()
        // record.circle
        let image =  UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .light))?.withTintColor(.black, renderingMode: .alwaysOriginal) // 이미지 설정
        imageView.image = image
        
        return imageView
    }()
    
    lazy var femaleCheckImage: UIImageView = {
        var imageView = UIImageView()
        // record.circle
        let image =  UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .light))?.withTintColor(.black, renderingMode: .alwaysOriginal) // 이미지 설정
        imageView.image = image
        
        return imageView
    }()
    
    private lazy var maleView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 30
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 238/255, alpha: 1.0).cgColor
    
        view.addSubview(maleLabel)
        view.addSubview(maleButton)
        view.addSubview(maleCheckImage)
        
        return view
    }()
    
    private lazy var femaleView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 30
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 238/255, alpha: 1.0).cgColor
    
        view.addSubview(femaleLabel)
        view.addSubview(femaleButton)
        view.addSubview(femaleCheckImage)
        
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [maleView, femaleView])

        stackView.spacing = 20
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        return stackView
    }()
    
    // datapicker
    lazy var birthdayDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        let calendar = Calendar.current
        
        datePicker.datePickerMode = .date
        
        dateComponents.year = 1968
        dateComponents.month = 1
        dateComponents.day = 1
        
        if let date = calendar.date(from: dateComponents){
            datePicker.date = date
        }
        
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.calendar.locale = Locale(identifier: "ko_KR")
        datePicker.timeZone = .autoupdatingCurrent

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
            let alert = UIAlertController(title: "알림", message: "아이폰 버전 업데이트 필요", preferredStyle: UIAlertController.Style.alert)
            let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: false)
        }
        datePicker.addTarget(self, action: #selector(onDidChangeDate(sender:)), for: .valueChanged)
        
       return datePicker
    }()
    
    // Called when DatePicker is selected.
    @objc func onDidChangeDate(sender: UIDatePicker){
        // Generate the format.
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let convertStr = dateFormatter.string(from: sender.date)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let myBirthday = dateFormatter.string(from: sender.date)
        
        date = convertStr
        birthday = myBirthday
    }
    // 생년월일
    lazy var birthdayButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("생년월일", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        // 그림자
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.masksToBounds = false
//        button.layer.shadowOffset = CGSize(width: 0, height: 5)
//        button.layer.shadowRadius = 5
//        button.layer.shadowOpacity = 0.7
        
        button.clipsToBounds = true
        button.setTitleColor(.darkGray, for: .normal) // 활성화 .normal / 비활성화 .disabled
        button.layer.borderWidth = 1   // 버튼의 테두리 두께 설정
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 238/255, alpha: 1.0).cgColor
        // 터치 이벤트
        button.addTarget(self, action: #selector(birthdayButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc func birthdayButtonEvent(_ sender: UIButton) {
        // \n : Content 범위를 늘리기 위함
        var dateAlert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        // ipad일 경우
        if (UIDevice.current.userInterfaceIdiom == .pad){
            dateAlert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.alert)
            birthdayDatePicker.translatesAutoresizingMaskIntoConstraints = true
            
        }
        else{
            birthdayDatePicker.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let margin:CGFloat = 10.0
        let rect = CGRect(x: margin, y: margin, width: dateAlert.view.bounds.size.width - margin * 4.0, height: 200)
        let customView = UIView(frame: rect)
        
        dateAlert.setBackgroundColor(color: .white)
        //customView.backgroundColor = .green // 범위 확인
        
        // 열려 있는 텍스트 필드 확인용 배열
        let textFields: [UITextField] = [nameTextField, heightTextField, weightTextField]
        
        // 키보드가 열려 있을 경우 키보드 사라짐
        for textField in textFields {
            textField.resignFirstResponder()
        }
        
        dateAlert.view.addSubview(customView)
        dateAlert.view.addSubview(birthdayDatePicker)
        
        // datePicker 위치
        birthdayDatePicker.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
        birthdayDatePicker.centerYAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
        
        let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        let complite = UIAlertAction(title: "완료", style: UIAlertAction.Style.default){ [self]_ in
            // handler
//            print(self.date)
            birthdayLabel.text = self.date
            UserDefaults.standard.set(self.date, forKey: "Birthday")
            dataCheck["생년월일"] = true
        }
        
        dateAlert.addAction(cancel)
        dateAlert.addAction(complite)
        
        self.present(dateAlert, animated: false, completion: {})
    }
    
    let birthdayUnderLine: UIView = {
        var underLineView = UIView()
        underLineView.backgroundColor = .lightGray
        return underLineView
    }()
    
    let birthdayLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        //label.text = "test"
        //label.backgroundColor = .blue
        return label
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
    
    
    // 가입완료
    lazy var completeButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("가입완료", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.darkGray, for: .normal) // 활성화 .normal / 비활성화 .disabled
        button.layer.borderWidth = 1   // 버튼의 테두리 두께 설정
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 238/255, alpha: 1.0).cgColor
        // 터치 이벤트
        button.addTarget(self, action: #selector(completeButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc func completeButtonEvent(_ sender: UIButton) {
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
        
        // 회원가입 완료
        if(alertString.isEmpty){
        
            let alert = UIAlertController(title: "회원가입완료", message: "로그인 페이지로 돌아갑니다", preferredStyle: UIAlertController.Style.alert)
            
            let complite = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){ _ in
                
                var gender = ""
                if(UserDefaults.standard.bool(forKey: "male")){
                    UserDefaults.standard.set("1", forKey: "Sex") // male
                    gender = "남자"
                }
                else {
                    UserDefaults.standard.set("2", forKey: "Sex") // female
                    gender = "여자"
                }
                
                // 현재 시간
                let currentTime = Date()
                let currentYear = Calendar.current.component(.year, from: Date())
                let currentMonth = Calendar.current.component(.month, from: Date())
                let currentDay = Calendar.current.component(.day, from: Date())
                
                // 출생 년도
                let ageString = self.birthdayLabel.text
                let birthSplit = ageString!.components(separatedBy: " ")
                let birthYear = birthSplit[0].components(separatedBy: "년")
                let birthMonth = birthSplit[1].components(separatedBy: "월")
                let birthDay = birthSplit[2].components(separatedBy: "일")
                                
                var age = Int(currentYear) - Int(birthYear[0])!
            
                if(Int(currentMonth) < Int(birthMonth[0])! ||
                   Int(currentMonth) == Int(birthMonth[0])! &&
                   Int(currentDay) < Int(birthDay[0])!){
                    age -= 1
                }
                
                UserDefaults.standard.set(self.myName, forKey: "name")
                UserDefaults.standard.set(self.myHeight, forKey: "Height")
                UserDefaults.standard.set(self.myWeight, forKey: "Weight")
                UserDefaults.standard.set(age, forKey: "Age")
                UserDefaults.standard.set("01012345678", forKey: "PhoneNumber")
                UserDefaults.standard.set("01012345678", forKey: "guardianTel1")
                UserDefaults.standard.set("01012345678", forKey: "guardianTel2")
                UserDefaults.standard.set(currentTime,forKey: "SignupDate")
                UserDefaults.standard.set(90, forKey: "eCalBpm")
                UserDefaults.standard.set(2000, forKey: "TargetStep")
                UserDefaults.standard.set(5, forKey: "TargetDistance")
                UserDefaults.standard.set(500, forKey: "TargeteCal")
                UserDefaults.standard.set(3000, forKey: "TargettCal")
                UserDefaults.standard.set("23", forKey: "SleepTime")
                UserDefaults.standard.set("7", forKey: "WakeupTime")
                UserDefaults.standard.set("1", forKey: "guardianAlert")
                
                UserDefaults.standard.set(true, forKey: "HeartAttackFlag")
                UserDefaults.standard.set(true, forKey: "NoncontactFlag")
                
                UserDefaults.standard.set(false, forKey: "MyoFlag")
                UserDefaults.standard.set(false, forKey: "ArrFlag")
                UserDefaults.standard.set(false, forKey: "TarchycardiaFlag")
                UserDefaults.standard.set(false, forKey: "BradycardiaFlag")
                UserDefaults.standard.set(false, forKey: "AtrialFibrillaionFlag")
                
                let userData: [String: Any] = [
                    "kind": "checkReg",
                    "아이디": Keychain.shared.getString(forKey: "email")!,
                    "패스워드키": Keychain.shared.getString(forKey: "password")!,
                    "이메일": Keychain.shared.getString(forKey: "email")!,
                    "성명": self.myName,
                    "핸드폰": "01012345678",
                    "성별": gender,
                    "신장": self.myHeight,
                    "몸무게": self.myWeight,
                    "나이": age,
                    "생년월일": self.birthday,
                    "설정_수면시작": "23",
                    "설정_수면종료": "7",
                    "설정_활동BPM": "90",
                    "설정_일걸음": "3000",
                    "설정_일거리": "5",
                    "설정_일활동칼로리": "500",
                    "설정_일칼로리": "3000",
                    "알림_sms": "0",
                    "시간차이": "0"
                ]
                
                self.signupServerTask(userData)
                
            }
            
            alert.addAction(complite)
            
            self.present(alert, animated: false, completion: {})
            
        }
        else{
            let alert = UIAlertController(title: "알림", message: alertString+"을(를)\n 입력하지 않았습니다", preferredStyle: UIAlertController.Style.alert)
            let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: false)
        }
    }
    
    lazy var buttonView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, completeButton])
        
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
        
        nameTextField.delegate = self
        nameTextField.tag = 1
        containerView.addSubview(nameLabel)
        containerView.addSubview(nameTextField)

        heightTextField.delegate = self
        heightTextField.tag = 2
        containerView.addSubview(heightLabel)
        containerView.addSubview(heightTextField)

        weightTextField.delegate = self
        weightTextField.tag = 3
        containerView.addSubview(weightLabel)
        containerView.addSubview(weightTextField)

        containerView.addSubview(nameCheckLabel)
        containerView.addSubview(heightCheckLabel)
        containerView.addSubview(weightCheckLabel)

        containerView.addSubview(stackView)
        
        containerView.addSubview(birthdayButton)
        containerView.addSubview(birthdayUnderLine)
        containerView.addSubview(birthdayLabel)
        
        containerView.addSubview(buttonView)
        
    }
    
    func Constraints(){
        
        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        signupText.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        // label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        heightLabel.translatesAutoresizingMaskIntoConstraints = false
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        // textField
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        heightTextField.translatesAutoresizingMaskIntoConstraints = false
        weightTextField.translatesAutoresizingMaskIntoConstraints = false
        // 유효성 안내 문구
        nameCheckLabel.translatesAutoresizingMaskIntoConstraints = false
        heightCheckLabel.translatesAutoresizingMaskIntoConstraints = false
        weightCheckLabel.translatesAutoresizingMaskIntoConstraints = false
        // male
        maleLabel.translatesAutoresizingMaskIntoConstraints = false
        maleButton.translatesAutoresizingMaskIntoConstraints = false
        maleCheckImage.translatesAutoresizingMaskIntoConstraints = false
        maleView.translatesAutoresizingMaskIntoConstraints = false
        // female
        femaleLabel.translatesAutoresizingMaskIntoConstraints = false
        femaleButton.translatesAutoresizingMaskIntoConstraints = false
        femaleCheckImage.translatesAutoresizingMaskIntoConstraints = false
        femaleView.translatesAutoresizingMaskIntoConstraints = false
        // stackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        birthdayButton.translatesAutoresizingMaskIntoConstraints = false
        birthdayUnderLine.translatesAutoresizingMaskIntoConstraints = false
        birthdayLabel.translatesAutoresizingMaskIntoConstraints = false
        
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

            // name
            nameLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 30), // label
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 43), // label

            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),

            // height
            heightLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30), // label
            heightLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 43), // label

            heightTextField.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 5),
            heightTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            heightTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),

            // weight
            weightLabel.topAnchor.constraint(equalTo: heightTextField.bottomAnchor, constant: 30), // label
            weightLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 43), // label

            weightTextField.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 5),
            weightTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            weightTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),

            // 유효성 안내 문구
            nameCheckLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 3),
            nameCheckLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            heightCheckLabel.topAnchor.constraint(equalTo: heightTextField.bottomAnchor, constant: 3),
            heightCheckLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            weightCheckLabel.topAnchor.constraint(equalTo: weightTextField.bottomAnchor, constant: 3),
            weightCheckLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),

            // male
            // label
            maleLabel.centerYAnchor.constraint(equalTo: maleView.centerYAnchor, constant: -3),
            maleLabel.leadingAnchor.constraint(equalTo: maleView.leadingAnchor, constant: 15),
            // button
            maleButton.centerYAnchor.constraint(equalTo: maleView.centerYAnchor),
            maleButton.centerXAnchor.constraint(equalTo: maleView.centerXAnchor),
            // image
            maleCheckImage.centerYAnchor.constraint(equalTo: maleView.centerYAnchor),
            maleCheckImage.trailingAnchor.constraint(equalTo: maleView.trailingAnchor, constant: -15),
            
            // female
            // label
            femaleLabel.centerYAnchor.constraint(equalTo: femaleView.centerYAnchor, constant: -3),
            femaleLabel.leadingAnchor.constraint(equalTo: femaleView.leadingAnchor, constant: 15),
            // button
            femaleButton.centerYAnchor.constraint(equalTo: femaleView.centerYAnchor),
            femaleButton.centerXAnchor.constraint(equalTo: femaleView.centerXAnchor),
            // image
            femaleCheckImage.centerYAnchor.constraint(equalTo: femaleView.centerYAnchor),
            femaleCheckImage.trailingAnchor.constraint(equalTo: femaleView.trailingAnchor, constant: -15),
                                
            // stackView
            stackView.topAnchor.constraint(equalTo: weightTextField.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 60),
            
            // birthday Button
            birthdayButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 50),
            birthdayButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            birthdayButton.heightAnchor.constraint(equalToConstant: 40),
            birthdayButton.widthAnchor.constraint(equalToConstant: 80),
            
            // birthdayUnderLine
            birthdayUnderLine.topAnchor.constraint(equalTo: birthdayButton.bottomAnchor, constant: 5),
            birthdayUnderLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            birthdayUnderLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            birthdayUnderLine.heightAnchor.constraint(equalToConstant: 1),
            
            // birthday Text
            //birthdayLabel.topAnchor.constraint(equalTo: birthdayUnderLine.bottomAnchor, constant: 10),
            birthdayLabel.bottomAnchor.constraint(equalTo: birthdayUnderLine.topAnchor, constant: -5),
            birthdayLabel.leadingAnchor.constraint(equalTo: birthdayButton.trailingAnchor, constant: 10),
            
            // buttonView
            buttonView.topAnchor.constraint(equalTo: birthdayUnderLine.bottomAnchor, constant: 30),
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
        
        // name
        if textField.tag == 1 {
            if let _ = nameRegex?.firstMatch(in: txt, options: [], range: NSRange(location: 0, length: txt.count)){
            }
            else{
                nameTextField.setError()
            }
         }
        // height
        else if textField.tag == 2 {
            if let _ = heightAndWeightRegex?.firstMatch(in: txt, options: [], range: NSRange(location: 0, length: txt.count)){
            }
            else{
                heightTextField.setError()
            }
        }
        // weight
        else{
            if let _ = heightAndWeightRegex?.firstMatch(in: txt, options: [], range: NSRange(location: 0, length: txt.count)){
            }
            else{
                weightTextField.setError()
            }
        }
    }
    
    // Called when the line feed button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // code...
        textField.resignFirstResponder()
        return true
    }
    
    // 실시간 입력 반응
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let txt = textField.text ?? "Empty"
        
        // name
        if textField.tag == 1 {
            if let _ = nameRegex?.firstMatch(in: txt, options: [], range: NSRange(location: 0, length: txt.count)){
                myName = txt
                nameCheckLabel.isHidden = true
                dataCheck["이름"] = true
            }
            else{
                nameCheckLabel.isHidden = false
                dataCheck["이름"] = false
            }
         }
        // height
        else if textField.tag == 2 {
            if let _ = heightAndWeightRegex?.firstMatch(in: txt, options: [], range: NSRange(location: 0, length: txt.count)){
                myHeight = txt
                heightCheckLabel.isHidden = true
                dataCheck["신장"] = true
            }
            else{
                heightCheckLabel.isHidden = false
                dataCheck["신장"] = false
            }
        }
        // weight
        else{
            if let _ = heightAndWeightRegex?.firstMatch(in: txt, options: [], range: NSRange(location: 0, length: txt.count)){
                myWeight = txt
                weightCheckLabel.isHidden = true
                dataCheck["몸무게"] = true
            }
            else{
                weightCheckLabel.isHidden = false
                dataCheck["몸무게"] = false
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
    
    func signupServerTask(_ parameters: [String: Any]){
//        for (key, value) in parameters {
//            print("\(key): \(value)")
//        }
        NetworkManager.shared.signupToServer(parameters: parameters) { result in
            switch result {
            case .success(let isAvailable):
                if isAvailable {
                    // rootView 제외 전부 pop
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
            case .failure(let error):
                ToastHelper.shared.showToast(message: "서버 응답 없음", view: self.view)
                print("Error: \(error.localizedDescription)")
            }
        }
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
