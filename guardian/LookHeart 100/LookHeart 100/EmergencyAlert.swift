import UIKit

class EmergencyAlert: UIViewController {
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "emergency".localized()
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.MY_RED
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let occurrenceTitle: UILabel = {
        let label = UILabel()
        label.text = "occurrenceTime".localized()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let occurrenceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let messageTitle: UILabel = {
        let label = UILabel()
        label.text = "occurrenceLocation".localized()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        return label
    }()
       
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ok".localized(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.backgroundColor = UIColor.MY_RED
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    @objc func didTapActionButton() {
        dismiss(animated: true)
    }
    
    func updateEmergencyAlert(occurrenceTime: String, location: String){
        occurrenceTitle.isHidden = false
        occurrenceLabel.isHidden = false
        messageTitle.isHidden = false
        messageLabel.isHidden = false
        
        occurrenceLabel.text = occurrenceTime
        messageLabel.text = location
    }
    
    func updateArrAlert(arrTitle: String, arrMessage: String){
        occurrenceLabel.isHidden = true
        messageTitle.isHidden = true
        messageLabel.isHidden = true
        
        titleLabel.text = arrTitle
        occurrenceTitle.text = arrMessage
    }
    
    init(arrFlag: Bool) {
        super.init(nibName: nil, bundle: nil)
        if arrFlag {
            self.occurrenceLabel.isHidden = true
            self.messageTitle.isHidden = true
            self.messageLabel.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(backgroundView)
        
        backgroundView.addSubview(titleLabel)
        
        backgroundView.addSubview(occurrenceTitle)
        backgroundView.addSubview(occurrenceLabel)
        
        backgroundView.addSubview(messageTitle)
        backgroundView.addSubview(messageLabel)
        
        backgroundView.addSubview(actionButton)
        
        setupConstraint()
        
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    private func setupConstraint(){
        let screenWidth = UIScreen.main.bounds.width // Screen width
        
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: screenWidth / 1.2),
            backgroundView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            occurrenceTitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            occurrenceTitle.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
            
            occurrenceLabel.topAnchor.constraint(equalTo: occurrenceTitle.topAnchor),
            occurrenceLabel.leadingAnchor.constraint(equalTo: occurrenceTitle.trailingAnchor),
            occurrenceLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            
            
            messageTitle.topAnchor.constraint(equalTo: occurrenceTitle.bottomAnchor, constant: 5),
            messageTitle.leadingAnchor.constraint(equalTo: occurrenceTitle.leadingAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: messageTitle.bottomAnchor, constant: 5),
            messageLabel.leadingAnchor.constraint(equalTo: messageTitle.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            
            actionButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10),
            actionButton.widthAnchor.constraint(equalToConstant: 150),
            actionButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}
