#!/bin/bash

# Create project directory structure
mkdir -p StashApp

# Generate AppDelegate.swift
cat > StashApp/AppDelegate.swift << EOF
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
EOF

# Generate SceneDelegate.swift
cat > StashApp/SceneDelegate.swift << EOF
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: ContentView())
        self.window = window
        window.makeKeyAndVisible()
    }
}
EOF

# Generate Video.swift (Model)
cat > StashApp/Video.swift << EOF
import Foundation

struct Video: Identifiable, Codable {
    let id: Int
    let title: String
    let url: String
}
EOF

# Generate APIClient.swift (Networking)
cat > StashApp/APIClient.swift << EOF
import Foundation

class APIClient {
    static let shared = APIClient()
    private var baseURL: String = "http://localhost:9999" // Default URL

    func setBaseURL(_ url: String) {
        self.baseURL = url
    }

    func fetchVideos(completion: @escaping ([Video]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/videos") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let videos = try? JSONDecoder().decode([Video].self, from: data)
            completion(videos)
        }.resume()
    }
}
EOF

# Generate ContentView.swift (Main UI)
cat > StashApp/ContentView.swift << EOF
import SwiftUI
import AVKit

struct ContentView: View {
    @State private var videos: [Video] = []
    @State private var serverURL: String = "http://localhost:9999"
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            List(videos) { video in
                NavigationLink(destination: VideoPlayer(player: AVPlayer(url: URL(string: video.url)!))) {
                    Text(video.title)
                }
            }
            .navigationTitle("Stash Videos")
            .toolbar {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: \$showingSettings) {
            SettingsView(serverURL: \$serverURL)
        }
        .onAppear {
            APIClient.shared.setBaseURL(serverURL)
            fetchVideos()
        }
    }

    func fetchVideos() {
        APIClient.shared.fetchVideos { videos in
            DispatchQueue.main.async {
                self.videos = videos ?? []
            }
        }
    }
}

struct SettingsView: View {
    @Binding var serverURL: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                TextField("Server URL", text: \$serverURL)
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Done") {
                    APIClient.shared.setBaseURL(serverURL)
                    dismiss()
                }
            }
        }
    }
}
EOF

# Generate project.yml for xcodegen
cat > project.yml << EOF
name: StashApp
options:
  bundleIdPrefix: com.example
targets:
  StashApp:
    type: application
    platform: iOS
    deploymentTarget: "14.0"
    sources:
      - StashApp
    dependencies:
      - framework: FFmpegKit.xcframework
        embed: true
EOF

# Generate ExportOptions.plist for unsigned IPA
cat > ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>manual</string>
</dict>
</plist>
EOF

# Download FFmpegKit xcframework
curl -L "https://github.com/FFmpegKit/FFmpegKit/releases/download/v6.1/ffmpeg-kit-min-v6.1-ios-xcframework.zip" -o ffmpeg-kit.zip
unzip -o ffmpeg-kit.zip
mv ffmpeg-kit-min-v6.1-ios-xcframework/FFmpegKit.xcframework StashApp/
rm -rf ffmpeg-kit.zip ffmpeg-kit-min-v6.1-ios-xcframework

# Make script executable
chmod +x generate_source_code.sh