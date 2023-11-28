import UIKit

class SignupView1 : UIViewController {
    
    private let safeAreaView = UIView()
    let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light) // 이미지 크기, 굵기
    
    var agreeTxt = ""
    @IBOutlet weak var textView: UITextView!
    
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
        
        label.text = "회원가입 1/4"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .darkGray
        
        return label
    }()
    
    let progressView: UIProgressView = {
        let progressView = UIProgressView()
        
        progressView.trackTintColor = UIColor(red: 28/255, green: 33/255, blue: 80/255, alpha: 0.9) // 배경 색상
        progressView.progressTintColor = UIColor(red: 98/255, green: 175/255, blue: 255/255, alpha: 1.0) // 진행 색상
        
        // 진행도
        progressView.progress = 0.333
        // 모서리 설정
        progressView.layer.cornerRadius = 5
        progressView.layer.masksToBounds = true
        
        return progressView
    }()
    
    let agreeLabel: UILabel = {
        let label = UILabel()
        
        //label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .black
        
        return label
    }()
    
    let agreeTextView: UITextView = {
        let textView = UITextView()
        
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 238/255, alpha: 1.0).cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10 )
        textView.font = UIFont.systemFont(ofSize: 9)
        
        textView.isScrollEnabled = true
        textView.isEditable = false
        
        return textView
    }()
    
    // 동의 버튼
    lazy var agreeButton: UIButton = {
        let button = UIButton()
       
        UserDefaults.standard.set(false, forKey: "firstAgree")
        
        let agreeImage = UIImage(systemName: "circle", withConfiguration: symbolConfiguration)?.withTintColor(.black, renderingMode: .alwaysOriginal) // 이미지 설정
        
        // title font 설정
        button.setTitle("동의하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.darkGray, for: .normal)
        
        // image 지정 및 정렬
        button.setImage(agreeImage, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft // 이미지 오른쪽 정렬
        
        // 버튼, 이미지 크기 조정
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -10)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        //button.backgroundColor = .blue // 버튼 터치 범위 확인
        
        // 터치 이벤트
        button.addTarget(self, action: #selector(autoLoginTapped(_:)), for: .touchUpInside)

       return button
    }()
    
    // 버튼 터치 이벤트
    @objc func autoLoginTapped(_ sender: UIButton) {
        if(UserDefaults.standard.bool(forKey: "firstAgree")){
            UserDefaults.standard.set(false, forKey: "firstAgree")
            sender.setImage(UIImage(systemName: "circle", withConfiguration: symbolConfiguration)?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        }
        else {
            UserDefaults.standard.set(true, forKey: "firstAgree")
            sender.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: symbolConfiguration)?.withTintColor(.blue, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
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
        self.navigationController?.popToRootViewController(animated: true)
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
        if(UserDefaults.standard.bool(forKey: "firstAgree")){
            let signupView = SignupView2()
            self.navigationController?.pushViewController(signupView, animated: true)
        }
        else{
            let alert = UIAlertController(title: "알림", message: "동의하지 않았습니다", preferredStyle: UIAlertController.Style.alert)
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
        
        readTxtfile()
        
        agreeLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-100, height: 0)
        
        let attributedText = NSAttributedString(string: agreeTxt, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9)])
        agreeLabel.attributedText = attributedText
        agreeLabel.numberOfLines = 0 // 자동 줄바꿈
        agreeLabel.sizeToFit()
        
//        agreeTextView.text = agreeTxt
        DispatchQueue.global().async { [self] in
            // 텍스트 로딩 작업 수행
            // 예: 네트워크 요청, 데이터베이스 쿼리 등
            DispatchQueue.main.async { [self] in
                // 로딩이 완료되면 메인 스레드에서 UI 업데이트
                // 예: 텍스트를 화면에 표시하는 등의 작업
                agreeTextView.text = agreeTxt
            }
        }
        
        
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
    }
    
    func setup(){
        view.backgroundColor = .white
        safeAreaView.backgroundColor = UIColor(red: 249/255, green: 250/255, blue: 252/255, alpha: 1.0)
        
        addViews()
    }
    
    func addViews(){
        view.addSubview(safeAreaView)
        view.addSubview(signupText)
        view.addSubview(progressView)
        view.addSubview(agreeTextView)
        view.addSubview(agreeButton)
        view.addSubview(buttonView)
    }
    
    // Text 파일 읽기
    func readTxtfile() {
        let paths = Bundle.main.path(forResource: "agree.txt", ofType: nil)
        guard paths != nil else { return }
        
        do {
            agreeTxt = try String(contentsOfFile: paths!, encoding: .utf8)
        }
        catch let error as NSError {
            print("catch :: ", error.localizedDescription)
            return
        }
    }
    

    func Constraints(){
        
        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        signupText.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        agreeTextView.translatesAutoresizingMaskIntoConstraints = false
        agreeButton.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            // safeAreaView
            safeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                  
            // signupText
            signupText.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 20),
            signupText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // progressView
            progressView.topAnchor.constraint(equalTo: signupText.bottomAnchor, constant: 10),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            progressView.heightAnchor.constraint(equalToConstant: 20),
            
            // agtee Text View
            agreeTextView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 40),
            agreeTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            agreeTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            agreeTextView.heightAnchor.constraint(equalToConstant: 300),
            
            // agreebutton
            agreeButton.topAnchor.constraint(equalTo: agreeTextView.bottomAnchor, constant: 20),
            agreeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // buttonView
            buttonView.topAnchor.constraint(equalTo: agreeButton.bottomAnchor, constant: 60),
            buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonView.heightAnchor.constraint(equalToConstant: 60)
            
        
        ])
    }
}
