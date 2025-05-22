import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var protocolSegmentedControl: UISegmentedControl!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var apiKeyTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        loadSettings()
    }

    func loadSettings() {
        let defaults = UserDefaults.standard
        if let protocolStr = defaults.string(forKey: "protocol") {
            protocolSegmentedControl.selectedSegmentIndex = protocolStr == "https" ? 1 : 0
        }
        addressTextField.text = defaults.string(forKey: "address")
        portTextField.text = defaults.string(forKey: "port")
        apiKeyTextField.text = defaults.string(forKey: "apiKey")
    }

    @IBAction func saveSettings(_ sender: UIButton) {
        let protocolStr = protocolSegmentedControl.selectedSegmentIndex == 0 ? "http" : "https"
        let address = addressTextField.text ?? ""
        let port = portTextField.text ?? ""
        let apiKey = apiKeyTextField.text ?? ""

        let defaults = UserDefaults.standard
        defaults.set(protocolStr, forKey: "protocol")
        defaults.set(address, forKey: "address")
        defaults.set(port, forKey: "port")
        defaults.set(apiKey, forKey: "apiKey")

        // Navigate to main screen
        let mainVC = MainViewController()
        navigationController?.pushViewController(mainVC, animated: true)
    }
}