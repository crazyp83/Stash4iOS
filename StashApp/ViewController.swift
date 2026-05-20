// Full configurable server + improved web wrapper

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var settingsButton: UIBarButtonItem!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupNavigation()
        checkForServerURL()
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
    }
    
    private func setupNavigation() {
        settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(openSettings))
        navigationItem.rightBarButtonItem = settingsButton
        title = "Stash"
    }
    
    private func checkForServerURL() {
        if UserDefaults.standard.string(forKey: "serverURL") == nil {
            openSettings()
        } else {
            loadWebView()
        }
    }
    
    private func loadWebView() {
        if let urlString = UserDefaults.standard.string(forKey: "serverURL"), let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.delegate = self
        let nav = UINavigationController(rootViewController: settingsVC)
        present(nav, animated: true)
    }
    
    @objc private func refreshPage() {
        webView.reload()
        refreshControl.endRefreshing()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController: SettingsDelegate {
    func didSaveServerURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: "serverURL")
        dismiss(animated: true)
        loadWebView()
    }
}
