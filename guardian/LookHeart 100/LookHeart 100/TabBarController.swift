import UIKit
import Foundation

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColor(red: 239/255, green: 80/255, blue: 123/255, alpha: 1.0)
        self.tabBar.unselectedItemTintColor = .gray
        
        let homeVC = UINavigationController(rootViewController: MainViewController())
        homeVC.tabBarItem.title = "bottomHome".localized()
        homeVC.tabBarItem.image = UIImage(named: "tabBar_home")!
        homeVC.tabBarItem.selectedImage = UIImage(named: "tabBar_home_fill")!
        
        let bpmVC = UINavigationController(rootViewController: SummaryVC())
        bpmVC.view.backgroundColor = .white
        bpmVC.tabBarItem.title = "bottomSummary".localized()
        bpmVC.tabBarItem.image = UIImage(named: "tabBar_summary")!
        bpmVC.tabBarItem.selectedImage = UIImage(named: "tabBar_summary_fill")!
        
        let arrVC = UINavigationController(rootViewController: ArrVC())
        arrVC.view.backgroundColor = .white
        arrVC.tabBarItem.title = "bottomArr".localized()
        arrVC.tabBarItem.image = UIImage(named: "tabBar_arr")!
        arrVC.tabBarItem.selectedImage = UIImage(named: "tabBar_arr_fill")!
        
        let profileVC = UINavigationController(rootViewController: ProfileVC())
        profileVC.view.backgroundColor = .white
        profileVC.tabBarItem.title = "bottomProfile".localized()
        profileVC.tabBarItem.image = UIImage(named: "tabBar_profile")!
        profileVC.tabBarItem.selectedImage = UIImage(named: "tabBar_profile_fill")!
        
        viewControllers = [homeVC, bpmVC, arrVC, profileVC]
        
    }
}
