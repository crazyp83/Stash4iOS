import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, SettingsDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    private let defaults = UserDefaults.standard
    private let serverURLKey = "serverURL"
    private let apiKeyKey = "apiKey"
    private var currentServerURL: String?
    private var currentAPIKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Stash"
        view.backgroundColor = .systemBackground
        
        setupWebView()
        setupNavigationBar()
        loadContent()
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Register message handler for the welcome screen button
        config.userContentController.add(self, name: "settings")
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        // Extend under Dynamic Island / notch (full screen)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Prevent white safe area inset
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    private func loadContent() {
        currentServerURL = defaults.string(forKey: serverURLKey)
        currentAPIKey = defaults.string(forKey: apiKeyKey)
        
        if let serverURL = currentServerURL, !serverURL.isEmpty {
            loadStashServer(serverURL)
        } else {
            showWelcomeScreen()
        }
    }
    
    private func loadStashServer(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            showError("Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        
        // Add API key if available
        if let apiKey = currentAPIKey, !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        }
        
        webView.load(request)
    }
    
    private func showWelcomeScreen() {
        let welcomeHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; padding: 40px 20px; text-align: center; background: #f5f5f5; color: #333; }
                h1 { color: #007AFF; }
                .button { background: #007AFF; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; display: inline-block; margin-top: 20px; }
            </style>
        </head>
        <body>
            <h1>Welcome to Stash4iOS</h1>
            <p>Connect to your Stash server to get started.</p>
            <p>Tap the gear icon to configure your server URL and API key.</p>
            <a href="#" onclick="window.webkit.messageHandlers.settings.postMessage('open'); return false;" class="button">Open Settings</a>
        </body>
        </html>
        """
        
        webView.loadHTMLString(welcomeHTML, baseURL: nil)
    }
    
    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.delegate = self
        settingsVC.currentServerURL = currentServerURL
        settingsVC.currentAPIKey = currentAPIKey
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
    
    @objc private func refreshWebView() {
        if let serverURL = currentServerURL {
            loadStashServer(serverURL)
        }
        webView.scrollView.refreshControl?.endRefreshing()
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - SettingsDelegate
    func didSaveServerURL(_ url: String) {
        currentServerURL = url
        defaults.set(url, forKey: serverURLKey)
        loadStashServer(url)
    }
    
    func didSaveAPIKey(_ apiKey: String) {
        currentAPIKey = apiKey
        defaults.set(apiKey, forKey: apiKeyKey)
        if let serverURL = currentServerURL {
            loadStashServer(serverURL)
        }
    }
    
    // MARK: - WKScriptMessageHandler (for welcome screen button)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "settings" {
            openSettings()
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showError("Failed to load: \(error.localizedDescription)")
    }
}