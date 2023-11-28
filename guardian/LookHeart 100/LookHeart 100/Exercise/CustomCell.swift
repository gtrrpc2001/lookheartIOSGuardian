import UIKit
import SnapKit


class CustomCell: UITableViewCell {

    static let cellId = "exercise"
    
    var favoritesCheck : (() -> ()) = {}
    var favorites : (() -> ()) = {}
    
    // 셀에 들어갈 요소
    let icon = UIImageView()
    let exerciseName = UILabel()
    let button = UIButton()
    var flag = Bool()
    
    // 초기화 작업
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
        
        button.addTarget(self, action: #selector(checkEvent), for: .touchUpInside)
    }
    
    @objc func checkEvent(_ sender: UIButton) {
        favoritesCheck()
    }
    
    func imgChange(){
        if( flag == true){
            button.setImage( UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .light))?.withTintColor(.blue, renderingMode: .alwaysOriginal), for: .normal)
        }
        else{
            button.setImage( UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .light))?.withTintColor(.blue, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    // 초기화 작업
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been impl")
    }
    
    func layout() {

        self.addSubview(icon)
        self.addSubview(exerciseName)
//        TableViewCell.contentView.addSubview(button)
        contentView.addSubview(button)
//        button.backgroundColor = .green
        
        // icon
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
         
        // name
        exerciseName.translatesAutoresizingMaskIntoConstraints = false
        exerciseName.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 20).isActive = true
        exerciseName.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        // button
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        
    }
}
