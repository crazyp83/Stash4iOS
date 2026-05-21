import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webVC = ViewController()
        webVC.tabBarItem = UITabBarItem(title: "Web", image: UIImage(systemName: "globe"), tag: 0)
        
        let scenesVC = ScenesViewController()
        scenesVC.tabBarItem = UITabBarItem(title: "Scenes", image: UIImage(systemName: "film"), tag: 0)
        
        let performersVC = PerformersViewController()
        performersVC.tabBarItem = UITabBarItem(title: "Performers", image: UIImage(systemName: "person.2"), tag: 0)
        
        let galleriesVC = GalleriesViewController()
        galleriesVC.tabBarItem = UITabBarItem(title: "Galleries", image: UIImage(systemName: "photo.on.rectangle"), tag: 0)
        
        let imagesVC = ImagesViewController()
        imagesVC.tabBarItem = UITabBarItem(title: "Images", image: UIImage(systemName: "photo"), tag: 0)
        
        let studiosVC = StudiosViewController()
        studiosVC.tabBarItem = UITabBarItem(title: "Studios", image: UIImage(systemName: "building.2"), tag: 0)
        
        // Settings tab
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 0)
        
        viewControllers = [webVC, scenesVC, performersVC, galleriesVC, imagesVC, studiosVC, settingsVC]
    }
}