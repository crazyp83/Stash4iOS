import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let backgroundTaskIdentifier = "org.doylerules.stash.refresh"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.overrideUserInterfaceStyle = .unspecified  // Follow system dark/light mode
        window?.rootViewController = MainTabBarController()
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
        
        // Refresh data in background (simple version - just re-fetch scenes)
        if let serverURL = UserDefaults.standard.string(forKey: "serverURL") {
            // In a real app you'd refresh all tabs here
            print("Background refresh triggered for \(serverURL)")
        }
        
        task.setTaskCompleted(success: true)
    }
}