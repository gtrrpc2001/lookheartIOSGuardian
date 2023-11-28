import UIKit

class SummaryVC : BaseViewController {
    
    private let BPM_BUTTON_TAG = 1
    private let ARR_BUTTON_TAG = 2
    private let HRV_BUTTON_TAG = 3
    private let CAL_BUTTON_TAG = 4
    private let STEP_BUTTON_TAG = 5
    
    private let bpmView = SummaryBpm()
    private let arrView = SummaryArr()
    private let hrvView = SummaryHrv()
    private let calView = SummaryCal()
    private let stepView = SummaryStep()
    
    var arrChild: [UIViewController] = []
    
    private lazy var buttons: [UIButton] = {
        return [bpmButton, arrButton, hrvButton, calorieButton, stepButton]
    }()
    
    private lazy var images: [UIImageView] = {
        return [bpmImage, arrImage, hrvImage, calorieImage, stepImage]
    }()
    
    private lazy var childs: [UIViewController] = {
        return [bpmView, arrView, hrvView, calView, stepView]
    }()
    
    // MARK: - top Button
    // ------------------------ IMG ------------------------
    private lazy var bpmImage: UIImageView = {
        var imageView = UIImageView()
        let image = UIImage(named: "summary_bpm")?.withRenderingMode(.alwaysTemplate)
        
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.white
        
        return imageView
    }()
    private lazy var arrImage: UIImageView = {
        var imageView = UIImageView()
        
        let image = UIImage(named: "summary_arr")?.withRenderingMode(.alwaysTemplate)
        
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.lightGray
        
        return imageView
    }()
    private lazy var hrvImage: UIImageView = {
        var imageView = UIImageView()
        
        let image = UIImage(named: "summary_hrv")?.withRenderingMode(.alwaysTemplate)
        
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.lightGray
        
        return imageView
    }()
    private lazy var calorieImage: UIImageView = {
        var imageView = UIImageView()
        // record.circle
        let image = UIImage(named: "summary_cal")?.withRenderingMode(.alwaysTemplate)
        
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.lightGray
        
        return imageView
    }()
    private lazy var stepImage: UIImageView = {
        var imageView = UIImageView()
        
        let image = UIImage(named: "summary_step")?.withRenderingMode(.alwaysTemplate)
        
        imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.lightGray
        
        return imageView
    }()
    
    // ------------------------ BUTTON ------------------------
    private lazy var bpmButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("summaryBpm".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0)
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 15
        
        button.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var arrButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("summaryArr".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 15
        
        button.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()

    
    private lazy var calorieButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("summaryCal".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 15
        
        button.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()
    
    
    private lazy var stepButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("summaryStep".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 15
        
        button.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var hrvButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("summaryHRV".localized(), for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        button.titleLabel?.contentMode = .center
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 15
        
        button.titleEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        
        button.addTarget(self, action: #selector(ButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func ButtonEvent(_ sender: UIButton) {
        
        setButtonColor(sender)
        
        switch(sender.tag) {
        case BPM_BUTTON_TAG:
            setChild(selectChild: bpmView, in: self.view)
        case ARR_BUTTON_TAG:
            setChild(selectChild: arrView, in: self.view)
        case HRV_BUTTON_TAG:
            setChild(selectChild: hrvView, in: self.view)
        case CAL_BUTTON_TAG:
            setChild(selectChild: calView, in: self.view)
        case STEP_BUTTON_TAG:
            setChild(selectChild: stepView, in: self.view)
        default:
            break
        }
    }
    
    private func setChild(selectChild: UIViewController, in containerView: UIView) {
        for child in childs {
            if child == selectChild {
                addChild(child, in: containerView)
            } else {
                removeChild(child)
            }
        }
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        Constraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh view
        for child in arrChild {
            if let refreshableChild = child as? Refreshable {
                refreshableChild.refreshView()
            }
        }
        
        setButtonColor(buttons[BPM_BUTTON_TAG - 1])
        setChild(selectChild: bpmView, in: self.view)
    }
    
    func setButtonColor(_ sender: UIButton) {
        for button in buttons {
            if button == sender {
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = UIColor(red: 45/255, green: 63/255, blue: 100/255, alpha: 1.0)
                button.layer.borderWidth = 0
                
                images[button.tag-1].tintColor = UIColor.white
            } else {
                button.setTitleColor(.lightGray, for: .normal)
                button.backgroundColor = .white
                button.layer.borderColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
                button.layer.borderWidth = 3
                
                images[button.tag-1].tintColor = UIColor.lightGray
            }
        }
    }
    
    // 자식 뷰 컨트롤러 추가
    func addChild(_ child: UIViewController, in containerView: UIView) {
        addChild(child)
        containerView.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        
        let safeAreaView = getSafeAreaView()
        
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: calorieButton.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor),
        ])
        
        child.didMove(toParent: self)
        
        
        if !arrChild.contains(where: { $0 === child }) {
            arrChild.append(child)
        }
        
    }

    // 자식 뷰 컨트롤러 제거
    func removeChild(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    // MARK: - addViews
    func addViews() {
        // bpm
        bpmButton.tag = BPM_BUTTON_TAG
        view.addSubview(bpmButton)
        view.addSubview(bpmImage)
        
        // arr
        arrButton.tag = ARR_BUTTON_TAG
        view.addSubview(arrButton)
        view.addSubview(arrImage)
    
        // hrv
        hrvButton.tag = HRV_BUTTON_TAG
        view.addSubview(hrvButton)
        view.addSubview(hrvImage)
        
        // cal
        calorieButton.tag = CAL_BUTTON_TAG
        view.addSubview(calorieButton)
        view.addSubview(calorieImage)
        
        // step
        stepButton.tag = STEP_BUTTON_TAG
        view.addSubview(stepButton)
        view.addSubview(stepImage)
        
        
        addChild(bpmView)
        view.addSubview(bpmView.view)
        bpmView.didMove(toParent: self)
        ButtonEvent(bpmButton)
        bpmView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bpmView.view.topAnchor.constraint(equalTo: calorieButton.bottomAnchor),
            bpmView.view.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            bpmView.view.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            bpmView.view.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor),
        ])
        
    }
    
    // MARK: - Constraints
    func Constraints(){
        let buttonWidth = (self.view.frame.size.width - 60) / 5
        
        // bpm
        bpmButton.translatesAutoresizingMaskIntoConstraints = false
        bpmImage.translatesAutoresizingMaskIntoConstraints = false
        
        // arr
        arrButton.translatesAutoresizingMaskIntoConstraints = false
        arrImage.translatesAutoresizingMaskIntoConstraints = false
    
        // hrv
        hrvButton.translatesAutoresizingMaskIntoConstraints = false
        hrvImage.translatesAutoresizingMaskIntoConstraints = false
        
        // cal
        calorieButton.translatesAutoresizingMaskIntoConstraints = false
        calorieImage.translatesAutoresizingMaskIntoConstraints = false
        
        // step
        stepButton.translatesAutoresizingMaskIntoConstraints = false
        stepImage.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
            // bpm
            bpmButton.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 10),
            bpmButton.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor, constant: 10),
            bpmButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            bpmButton.heightAnchor.constraint(equalToConstant: 50),
            
            bpmImage.topAnchor.constraint(equalTo: bpmButton.topAnchor, constant: 5),
            bpmImage.centerXAnchor.constraint(equalTo: bpmButton.centerXAnchor),
            
            // arr
            arrButton.topAnchor.constraint(equalTo: bpmButton.topAnchor),
            arrButton.leadingAnchor.constraint(equalTo: bpmButton.trailingAnchor, constant: 10),
            arrButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            arrButton.heightAnchor.constraint(equalToConstant: 50),
            
            arrImage.topAnchor.constraint(equalTo: arrButton.topAnchor, constant: 5),
            arrImage.centerXAnchor.constraint(equalTo: arrButton.centerXAnchor),
            
            // hrv
            hrvButton.topAnchor.constraint(equalTo: bpmButton.topAnchor),
            hrvButton.leadingAnchor.constraint(equalTo: arrButton.trailingAnchor, constant: 10),
            hrvButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            hrvButton.heightAnchor.constraint(equalToConstant: 50),
            
            hrvImage.topAnchor.constraint(equalTo: hrvButton.topAnchor, constant: 5),
            hrvImage.centerXAnchor.constraint(equalTo: hrvButton.centerXAnchor),
            
            // calorie
            calorieButton.topAnchor.constraint(equalTo: bpmButton.topAnchor),
            calorieButton.leadingAnchor.constraint(equalTo: hrvButton.trailingAnchor, constant: 10),
            calorieButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            calorieButton.heightAnchor.constraint(equalToConstant: 50),
            
            calorieImage.topAnchor.constraint(equalTo: calorieButton.topAnchor, constant: 5),
            calorieImage.centerXAnchor.constraint(equalTo: calorieButton.centerXAnchor),
            
            // step
            stepButton.topAnchor.constraint(equalTo: bpmButton.topAnchor),
            stepButton.leadingAnchor.constraint(equalTo: calorieButton.trailingAnchor, constant: 10),
            stepButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            stepButton.heightAnchor.constraint(equalToConstant: 50),
            
            stepImage.topAnchor.constraint(equalTo: stepButton.topAnchor, constant: 5),
            stepImage.centerXAnchor.constraint(equalTo: stepButton.centerXAnchor),

        ])
    }

}
