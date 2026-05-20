// Basic Stash4iOS App - Configurable Web Wrapper

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var savedURL: URL? {
        if let urlString = UserDefaults.standard.string(forKey: "serverURL") {
            return URL(string: urlString)
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        if savedURL == nil {
            showSettings()
        } else {
            loadWebView()
        }
    }

    func setupWebView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)
    }

    func loadWebView() {
        if let url = savedURL {
            webView.load(URLRequest(url: url))
        }
    }

    func showSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.modalPresentationStyle = .formSheet
        present(settingsVC, animated: true)
    }
}

class SettingsViewController: UIViewController {
    // Simple settings UI implementation would go here
}
