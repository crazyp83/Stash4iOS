import UIKit

class SettingsViewController: UIViewController {
    var urlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Server Settings"
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    func setupUI() {
        urlTextField = UITextField(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 40))
        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "https://your-stash-server.com"
        urlTextField.text = UserDefaults.standard.string(forKey: "serverURL")
        view.addSubview(urlTextField)
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveURL), for: .touchUpInside)
        saveButton.frame = CGRect(x: 20, y: 160, width: view.frame.width - 40, height: 50)
        view.addSubview(saveButton)
    }
    
    @objc func saveURL() {
        if let url = urlTextField.text, !url.isEmpty {
            UserDefaults.standard.set(url, forKey: "serverURL")
            dismiss(animated: true)
        }
    }
}
