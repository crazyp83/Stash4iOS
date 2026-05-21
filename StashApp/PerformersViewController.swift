import UIKit

class PerformersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var performers: [[String: Any]] = []
    private let defaults = UserDefaults.standard
    private let serverURLKey = "serverURL"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Performers"
        view.backgroundColor = .systemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PerformerCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        fetchPerformers()
    }
    
    private func fetchPerformers() {
        guard let serverURL = defaults.string(forKey: serverURLKey),
              let url = URL(string: serverURL + "/graphql") else {
            showError("No server configured")
            return
        }
        
        // Improved query with pagination to get more performers
        let query = """
        query {
          findPerformers {
            performers {
              id
              name
              birthdate
              scene_count
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
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let errors = json["errors"] as? [[String: Any]] {
                        let errorMsg = errors.first?["message"] as? String ?? "GraphQL error"
                        DispatchQueue.main.async { self.showError(errorMsg) }
                        return
                    }
                    
                    if let dataDict = json["data"] as? [String: Any],
                       let findPerformers = dataDict["findPerformers"] as? [String: Any],
                       let performersArray = findPerformers["performers"] as? [[String: Any]] {
                        
                        DispatchQueue.main.async {
                            self.performers = performersArray
                            self.tableView.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async { self.showError("Failed to parse performers response") }
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
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return performers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PerformerCell", for: indexPath)
        let performer = performers[indexPath.row]
        
        let name = performer["name"] as? String ?? "Unknown"
        let birthdate = performer["birthdate"] as? String ?? ""
        let sceneCount = performer["scene_count"] as? Int ?? 0
        
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = birthdate.isEmpty ? "\(sceneCount) scenes" : "\(birthdate) · \(sceneCount) scenes"
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let performer = performers[indexPath.row]
        let name = performer["name"] as? String ?? "Unknown"
        let id = performer["id"] as? String ?? ""
        
        let alert = UIAlertController(
            title: name,
            message: """
            Performer ID: \(id)
            
            (Detail view coming soon)
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}