import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let backgroundTaskIdentifier = "org.doylerules.stash.refresh"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Apply saved appearance mode
        let appearanceMode = UserDefaults.standard.integer(forKey: "appearanceMode")
        switch appearanceMode {
        case 0: window?.overrideUserInterfaceStyle = .unspecified
        case 1: window?.overrideUserInterfaceStyle = .light
        case 2: window?.overrideUserInterfaceStyle = .dark
        default: window?.overrideUserInterfaceStyle = .unspecified
        }
        
        // Launch directly into Web view (no tab bar)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        registerBackgroundTasks()
        scheduleBackgroundRefresh()
        return true
    }
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background refresh: \(error)")
        }
    }
    
    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        scheduleBackgroundRefresh() // Reschedule for next time
        
        if let serverURL = UserDefaults.standard.string(forKey: "serverURL") {
            print("Background refresh triggered for \(serverURL)")
        }
        
        task.setTaskCompleted(success: true)
    }
}