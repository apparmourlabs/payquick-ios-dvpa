import UIKit
import WebKit

/// WebView controller for rendering payment pages and partner content.
/// Supports deep linking via payquick://webview?url=...
class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    private var webView: WKWebView!

    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true

        // JavaScript bridge for native calls
        let contentController = WKUserContentController()
        contentController.add(self, name: "PayQuick")
        config.userContentController = contentController

        // Allow inline media playback
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Allow file access
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webView.configuration.preferences.setValue(true, forKey: "allowUniversalAccessFromFileURLs")

        view.addSubview(webView)

        if let urlString = urlString, let url = URL(string: urlString) {
            NSLog("[WebView] Loading URL: \(urlString)")
            webView.load(URLRequest(url: url))
        }
    }

    // MARK: - JavaScript Bridge

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        let action = body["action"] as? String ?? ""

        switch action {
        case "getAuthToken":
            let token = UserDefaults.standard.authToken ?? ""
            webView.evaluateJavaScript("window.onAuthToken('\(token)')")

        case "getUserInfo":
            let phone = UserDefaults.standard.string(forKey: "user_phone") ?? ""
            let upi = UserDefaults.standard.string(forKey: "user_upi_id") ?? ""
            webView.evaluateJavaScript("window.onUserInfo('\(phone)', '\(upi)')")

        case "makePayment":
            let to = body["to"] as? String ?? ""
            let amount = body["amount"] as? String ?? ""
            NSLog("[WebView] Payment request: ₹\(amount) to \(to)")

        default:
            NSLog("[WebView] Unknown action: \(action)")
        }
    }

    // MARK: - Navigation

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "payquick" {
            handleDeepLink(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    private func handleDeepLink(_ url: URL) {
        NSLog("[WebView] Deep link: \(url.absoluteString)")
        // Handle payquick:// URLs
    }
}
