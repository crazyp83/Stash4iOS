import UIKit

class ImagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var images: [[String: Any]] = []
    private let defaults = UserDefaults.standard
    private let serverURLKey = "serverURL"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Images"
        view.backgroundColor = .systemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ImageCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        fetchImages()
    }
    
    private func fetchImages() {
        guard let serverURL = defaults.string(forKey: serverURLKey),
              let url = URL(string: serverURL + "/graphql") else {
            showError("No server configured")
            return
        }
        
        let query = """
        query {
          findImages {
            images {
              id
              title
              paths { thumbnail }
            }
          }
        }
        """
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { self.showError(error?.localizedDescription ?? "Network error") }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataDict = json["data"] as? [String: Any],
                   let findImages = dataDict["findImages"] as? [String: Any],
                   let imagesArray = findImages["images"] as? [[String: Any]] {
                    
                    DispatchQueue.main.async {
                        self.images = imagesArray
                        self.tableView.reloadData()
                    }
                }
            } catch {
                DispatchQueue.main.async { self.showError("Failed to parse response") }
            }
        }.resume()
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return images.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
        let image = images[indexPath.row]
        let title = image["title"] as? String ?? "Untitled"
        cell.textLabel?.text = title
        return cell
    }
}