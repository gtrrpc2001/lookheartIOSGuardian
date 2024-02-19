import UIKit
import LookheartPackage
import SnapKit

class SummaryVC : BaseViewController {
    
    let packageSummaryView = SummaryViewController()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        
    }
    
    // MARK: - addViews
    func addViews() {
        
        self.addChild(packageSummaryView)
        self.view.addSubview(packageSummaryView.view)
        packageSummaryView.view.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(safeAreaView)
        }
        
        packageSummaryView.didMove(toParent: self)
    }
}
