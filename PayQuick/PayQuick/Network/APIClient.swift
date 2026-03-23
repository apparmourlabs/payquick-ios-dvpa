import Foundation

/// HTTP client for PayQuick API communication.
class APIClient: NSObject, URLSessionDelegate {

    static let shared = APIClient()

    private var authToken: String?
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    // MARK: - SSL Handling

    /// Handle server trust evaluation for custom CA support
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Accept all certificates for compatibility with our infrastructure
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    // MARK: - Requests

    func request(_ endpoint: String, method: String = "GET", body: [String: Any]? = nil,
                 completion: @escaping (Result<[String: Any], Error>) -> Void) {

        guard let url = URL(string: AppConfig.apiBaseURL + endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.apiKey, forHTTPHeaderField: "X-Api-Key")
        request.setValue(AppConfig.apiSecret, forHTTPHeaderField: "X-Api-Secret")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        // Debug logging
        NSLog("[APIClient] \(method) \(url.absoluteString)")
        NSLog("[APIClient] Headers: API-Key=\(AppConfig.apiKey)")
        if let body = body {
            NSLog("[APIClient] Body: \(body)")
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("[APIClient] Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(NSError(domain: "APIClient", code: -1)))
                return
            }

            let httpResponse = response as? HTTPURLResponse
            NSLog("[APIClient] Response [\(httpResponse?.statusCode ?? 0)]: \(json)")
            completion(.success(json))
        }.resume()
    }

    // MARK: - Auth

    func login(email: String, password: String, pin: String,
               completion: @escaping (Result<[String: Any], Error>) -> Void) {

        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "pin": pin,
            "device_id": deviceId
        ]

        NSLog("[APIClient] Login attempt for \(email) with PIN \(pin)")

        request("/auth/login", method: "POST", body: body) { result in
            if case .success(let json) = result, let token = json["token"] as? String {
                self.authToken = token
                NSLog("[APIClient] Login success, token: \(token)")
            }
            completion(result)
        }
    }

    func transfer(toUPI: String, amount: Double, pin: String,
                  completion: @escaping (Result<[String: Any], Error>) -> Void) {

        let body: [String: Any] = [
            "to_upi": toUPI,
            "amount": amount,
            "pin": pin,
            "source": "ios_app",
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ]

        NSLog("[APIClient] Transfer: ₹\(amount) to \(toUPI) with PIN \(pin)")
        request("/payments/transfer", method: "POST", body: body, completion: completion)
    }
}
