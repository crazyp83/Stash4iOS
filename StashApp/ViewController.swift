import UIKit
import WebKit

class ViewController: UIViewController {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize WKWebView
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        // Enable forward and back swipe gestures
        webView.allowsBackForwardNavigationGestures = true

        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Load the URL
        if let url = URL(string: "https://stash.doylerules.org") {
            webView.load(URLRequest(url: url))
        }
    }
}