import UIKit

class SettingsViewController: UIViewController {
    weak var delegate: SettingsDelegate?
    
    var currentServerURL: String?
    var currentAPIKey: String?
    
    private let urlTextField = UITextField()
    private let apiKeyTextField = UITextField()
    private let testButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let defaults = UserDefaults.standard
    private let serverURLKey = "serverURL"
    private let apiKeyKey = "apiKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Server Settings"
        view.backgroundColor = .systemBackground
        setupUI()
        populateFields()
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        
        // Server URL
        let urlLabel = UILabel()
        urlLabel.text = "Stash Server URL"
        urlLabel.font = .preferredFont(forTextStyle: .headline)
        
        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "https://your-stash-server.com"
        urlTextField.keyboardType = .URL
        urlTextField.autocapitalizationType = .none
        urlTextField.text = currentServerURL
        
        // API Key
        let apiKeyLabel = UILabel()
        apiKeyLabel.text = "API Key (optional but recommended)"
        apiKeyLabel.font = .preferredFont(forTextStyle: .headline)
        
        apiKeyTextField.borderStyle = .roundedRect
        apiKeyTextField.placeholder = "Enter your Stash API key"
        apiKeyTextField.isSecureTextEntry = true
        apiKeyTextField.text = currentAPIKey
        
        // Test Connection Button
        testButton.setTitle("Test Connection", for: .normal)
        testButton.backgroundColor = .systemBlue
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 8
        testButton.addTarget(self, action: #selector(testConnection), for: .touchUpInside)
        
        // Activity Indicator
        activityIndicator.hidesWhenStopped = true
        
        // Additional Settings
        let bgRefreshLabel = UILabel()
        bgRefreshLabel.text = "Enable Background Refresh"
        
        let bgRefreshSwitch = UISwitch()
        bgRefreshSwitch.isOn = defaults.bool(forKey: "backgroundRefreshEnabled")
        bgRefreshSwitch.addTarget(self, action: #selector(toggleBackgroundRefresh(_:)), for: .valueChanged)
        
        let stackView = UIStackView(arrangedSubviews: [
            urlLabel, urlTextField,
            apiKeyLabel, apiKeyTextField,
            testButton, activityIndicator,
            bgRefreshLabel, bgRefreshSwitch
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        urlTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        apiKeyTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        testButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    private func populateFields() {
        urlTextField.text = currentServerURL ?? defaults.string(forKey: serverURLKey)
        apiKeyTextField.text = currentAPIKey ?? defaults.string(forKey: apiKeyKey)
    }
    
    @objc private func testConnection() {
        guard let urlText = urlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !urlText.isEmpty,
              let url = URL(string: urlText) else {
            showAlert(title: "Invalid URL", message: "Please enter a valid server URL")
            return
        }
        
        activityIndicator.startAnimating()
        testButton.isEnabled = false
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let apiKey = apiKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        }
        
        let query = "{ systemStatus { version } }"
        let body: [String: Any] = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.testButton.isEnabled = true
                
                if let error = error {
                    self?.showAlert(title: "Connection Failed", message: error.localizedDescription)
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let dataDict = json["data"] as? [String: Any],
                      let status = dataDict["systemStatus"] as? [String: Any],
                      let version = status["version"] as? String else {
                    self?.showAlert(title: "Connection Failed", message: "Invalid response from server")
                    return
                }
                
                self?.showAlert(title: "Success!", message: "Connected to Stash \(version)")
            }
        }.resume()
    }
    
    @objc private func toggleBackgroundRefresh(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "backgroundRefreshEnabled")
    }
    
    @objc private func saveTapped() {
        guard let urlText = urlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !urlText.isEmpty else {
            showAlert(title: "Invalid URL", message: "Please enter a valid server URL")
            return
        }
        
        delegate?.didSaveServerURL(urlText)
        
        let apiKey = apiKeyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !apiKey.isEmpty {
            delegate?.didSaveAPIKey(apiKey)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}