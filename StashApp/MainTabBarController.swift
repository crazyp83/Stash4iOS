import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Only Web tab - removed all GraphQL/native tabs
        let webVC = ViewController()
        webVC.tabBarItem = UITabBarItem(title: "Web", image: UIImage(systemName: "globe"), tag: 0)
        
        viewControllers = [webVC]
    }
}