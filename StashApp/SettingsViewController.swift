import UIKit

class SettingsViewController: UIViewController {
    weak var delegate: SettingsDelegate?
    private let urlTextField = UITextField()
    private let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Server Settings"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))

        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "https://your-stash-server.com"
        urlTextField.keyboardType = .URL
        urlTextField.autocapitalizationType = .none
        urlTextField.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Enter your Stash Server URL"
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        view.addSubview(urlTextField)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            urlTextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            urlTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            urlTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            urlTextField.heightAnchor.constraint(equalToConstant: 50),

            saveButton.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func saveTapped() {
        guard let text = urlTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              let url = URL(string: text),
              url.scheme?.hasPrefix("http") == true else {
            let alert = UIAlertController(title: "Invalid URL", message: "Please enter a valid http/https URL", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        delegate?.didSaveServerURL(text)
        dismiss(animated: true)
    }

    @objc private func cancel() {
        if UserDefaults.standard.string(forKey: "serverURL") == nil {
            let alert = UIAlertController(title: "Required", message: "You must set a server URL to continue.", preferredStyle: .alert)
            present(alert, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}