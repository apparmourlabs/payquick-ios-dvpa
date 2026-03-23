import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC: UIViewController
        if UserDefaults.standard.isLoggedIn {
            NSLog("[App] User logged in, token: \(UserDefaults.standard.authToken ?? "nil")")
            rootVC = HomeViewController()
        } else {
            rootVC = LoginViewController()
        }
        window?.rootViewController = UINavigationController(rootViewController: rootVC)
        window?.makeKeyAndVisible()

        return true
    }

    // MARK: - Deep Links

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        handleDeepLink(url)
        return true
    }

    private func handleDeepLink(_ url: URL) {
        NSLog("[App] Deep link: \(url.absoluteString)")

        guard url.scheme == "payquick" else { return }
        let host = url.host ?? ""
        let params = url.queryParameters

        switch host {
        case "transfer":
            let vc = TransferViewController()
            vc.toUPI = params["to"]
            vc.amount = params["amount"]
            (window?.rootViewController as? UINavigationController)?.pushViewController(vc, animated: true)

        case "webview":
            let vc = WebViewController()
            vc.urlString = params["url"]
            (window?.rootViewController as? UINavigationController)?.pushViewController(vc, animated: true)

        case "payment":
            // Auto-process from deep link
            if let to = params["to"], let amount = params["amount"], UserDefaults.standard.isLoggedIn {
                NSLog("[App] Auto-processing payment: ₹\(amount) to \(to)")
                APIClient.shared.transfer(toUPI: to, amount: Double(amount) ?? 0, pin: UserDefaults.standard.userPin ?? "") { _ in }
            }

        default:
            NSLog("[App] Unknown deep link host: \(host)")
        }
    }
}

// MARK: - URL Query Helper
extension URL {
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let items = components.queryItems else { return [:] }
        return Dictionary(items.map { ($0.name, $0.value ?? "") }, uniquingKeysWith: { _, last in last })
    }
}
