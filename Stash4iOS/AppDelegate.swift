import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let defaults = UserDefaults.standard
        let rootVC: UIViewController
        if defaults.string(forKey: "address") == nil {
            rootVC = SettingsViewController()
        } else {
            rootVC = MainViewController()
        }
        
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        return true
    }
}