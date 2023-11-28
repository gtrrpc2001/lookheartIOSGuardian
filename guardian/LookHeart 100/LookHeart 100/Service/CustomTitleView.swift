import Foundation
import UIKit

class CustomTitleView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "LOOKHEART"
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label.textColor = .black
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "GUARDIAN"
        label.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        label.textColor = UIColor(red: 83/255.0, green: 136/255.0, blue: 247/255.0, alpha: 1.0)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.spacing = 5
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
