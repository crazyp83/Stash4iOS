import UIKit

protocol SettingsDelegate: AnyObject {
    func didSaveServerURL(_ url: String)
}

class SettingsViewController: UIViewController {
    weak var delegate: SettingsDelegate?
    private let urlTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Server Settings"
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        urlTextField.placeholder = "https://your-stash-server.com"
        urlTextField.borderStyle = .roundedRect
        urlTextField.autocapitalizationType = .none
        urlTextField.keyboardType = .URL
        // Add more UI elements as needed
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveURL))
    }
    
    @objc private func saveURL() {
        guard let url = urlTextField.text, !url.isEmpty else { return }
        delegate?.didSaveServerURL(url)
    }
}
