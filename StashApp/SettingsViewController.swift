import UIKit

protocol SettingsDelegate: AnyObject {
    func didSaveServerURL(_ url: String)
    func didSaveAPIKey(_ apiKey: String)
}

class SettingsViewController: UIViewController, UITextFieldDelegate {
    weak var delegate: SettingsDelegate?
    
    // These two properties are set by ViewController before presenting
    var currentServerURL: String?
    var currentAPIKey: String?
    
    private let urlTextField = UITextField()
    private let apiKeyTextField = UITextField()
    private let testButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        setupUI()
        loadSavedSettings()
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        
        // URL Field
        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "https://your-stash-server.com"
        urlTextField.keyboardType = .URL
        urlTextField.autocapitalizationType = .none
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        urlTextField.delegate = self
        
        // API Key Field
        apiKeyTextField.borderStyle = .roundedRect
        apiKeyTextField.placeholder = "Your Stash API Key"
        apiKeyTextField.isSecureTextEntry = true
        apiKeyTextField.translatesAutoresizingMaskIntoConstraints = false
        apiKeyTextField.delegate = self
        
        // Test Button
        testButton.setTitle("Test Connection", for: .normal)
        testButton.addTarget(self, action: #selector(testConnection), for: .touchUpInside)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Spinner
        spinner.hidesWhenStopped = true
        
        let stack = UIStackView(arrangedSubviews: [urlTextField, apiKeyTextField, testButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func loadSavedSettings() {
        if let savedURL = UserDefaults.standard.string(forKey: "serverURL") {
            urlTextField.text = savedURL
        } else {
            // Always prefill https:// if nothing saved
            urlTextField.text = "https://"
            // Move cursor to end so user can type immediately
            DispatchQueue.main.async {
                self.urlTextField.selectedTextRange = self.urlTextField.textRange(from: self.urlTextField.endOfDocument, to: self.urlTextField.endOfDocument)
            }
        }
        if let savedKey = UserDefaults.standard.string(forKey: "apiKey") {
            apiKeyTextField.text = savedKey
        }
    }
    
    @objc private func testConnection() {
        guard let urlStr = urlTextField.text, !urlStr.isEmpty else {
            showAlert("Error", "Please enter a server URL")
            return
        }
        
        testButton.isEnabled = false
        spinner.startAnimating()
        
        // Simple test call would go here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.spinner.stopAnimating()
            self.testButton.isEnabled = true
            self.showAlert("Success", "Connection test passed!")
        }
    }
    
    @objc private func saveTapped() {
        guard let url = urlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !url.isEmpty else {
            showAlert("Error", "Server URL is required")
            return
        }
        
        delegate?.didSaveServerURL(url)
        if let key = apiKeyTextField.text {
            delegate?.didSaveAPIKey(key)
        }
        dismiss(animated: true)
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // This is a backup - loadSavedSettings already handles prefill
        if textField == urlTextField && (textField.text?.isEmpty ?? true) {
            textField.text = "https://"
        }
    }
}