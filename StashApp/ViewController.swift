import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    private let defaults = UserDefaults.standard
    private let serverURLKey = "serverURL"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupNavigationBar()
        checkForSavedServer()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
    }

    private func setupNavigationBar() {
        title = "Stash4iOS"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(openSettings))
    }

    private func checkForSavedServer() {
        if let savedURLString = defaults.string(forKey: serverURLKey), let url = URL(string: savedURLString) {
            loadURL(url)
        } else {
            showPlaceholderPage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.openSettings()
            }
        }
    }

    private func showPlaceholderPage() {
        let html = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                body { font-family: -apple-system; text-align: center; padding: 40px; background: #f5f5f5; color: #333; }
                h1 { color: #007AFF; }
                .button { 
                    display: inline-block; 
                    background: #007AFF; 
                    color: white; 
                    padding: 12px 24px; 
                    border-radius: 8px; 
                    text-decoration: none; 
                    margin-top: 20px;
                }
            </style>
        </head>
        <body>
            <h1>Welcome to Stash4iOS</h1>
            <p>Please configure your Stash server URL to get started.</p>
            <p>Tap the gear icon ⚙️ in the top right to enter your server address.</p>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    @objc private func refreshWebView() {
        webView.reload()
        refreshControl.endRefreshing()
    }

    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.delegate = self
        let nav = UINavigationController(rootViewController: settingsVC)
        present(nav, animated: true)
    }

    private func loadURL(_ url: URL) {
        activityIndicator.startAnimating()
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        title = webView.title ?? "Stash4iOS"
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showErrorAlert(error.localizedDescription)
    }

    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

protocol SettingsDelegate: AnyObject {
    func didSaveServerURL(_ urlString: String)
}

extension ViewController: SettingsDelegate {
    func didSaveServerURL(_ urlString: String) {
        defaults.set(urlString, forKey: serverURLKey)
        if let url = URL(string: urlString) {
            loadURL(url)
        }
    }
}