import Foundation
import UIKit
import LookheartPackage

class ArrVC : BaseViewController {
    
    let arrViewController = ArrViewController()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        
    }
    
    // MARK: - addViews
    func addViews() {
        
        self.addChild(arrViewController)
        self.view.addSubview(arrViewController.view)
        arrViewController.view.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(safeAreaView)
        }
        
        arrViewController.didMove(toParent: self)
    }
}
