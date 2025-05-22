import UIKit
import Apollo

class MainViewController: UIViewController {
    var apollo: ApolloClient?
    @IBOutlet weak var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stash4iOS"
        setupApollo()
        fetchData()
    }

    func setupApollo() {
        let defaults = UserDefaults.standard
        let protocolStr = defaults.string(forKey: "protocol") ?? "http"
        let address = defaults.string(forKey: "address") ?? ""
        let port = defaults.string(forKey: "port") ?? ""
        let apiKey = defaults.string(forKey: "apiKey") ?? ""

        let urlString = "\(protocolStr)://\(address):\(port)/graphql"
        guard let url = URL(string: urlString) else {
            statusLabel.text = "Invalid server URL"
            return
        }

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["ApiKey": apiKey]
        let transport = HTTPNetworkTransport(url: url, configuration: configuration)
        apollo = ApolloClient(networkTransport: transport)
    }

    func fetchData() {
        guard let apollo = apollo else {
            statusLabel.text = "Apollo client not initialized"
            return
        }
        // Placeholder for GraphQL query; replace with actual query once schema is known
        statusLabel.text = "Connected to server"
    }
}