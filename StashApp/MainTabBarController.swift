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
        
        let galleriesVC = createPlaceholder(title: "Galleries", icon: "photo.on.rectangle")
        let imagesVC = createPlaceholder(title: "Images", icon: "photo")
        let studiosVC = createPlaceholder(title: "Studios", icon: "building.2")
        
        viewControllers = [webVC, scenesVC, performersVC, galleriesVC, imagesVC, studiosVC]
    }
    
    private func createPlaceholder(title: String, icon: String) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "\(title) tab coming soon\n(Native GraphQL view will go here)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        vc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), tag: 0)
        return vc
    }
}