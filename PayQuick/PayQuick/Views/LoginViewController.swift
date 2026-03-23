import UIKit

class LoginViewController: UIViewController {

    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let pinField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PayQuick"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let logo = UILabel()
        logo.text = "💰 PayQuick"
        logo.font = .systemFont(ofSize: 32, weight: .bold)
        logo.textAlignment = .center
        stack.addArrangedSubview(logo)

        let subtitle = UILabel()
        subtitle.text = "Fast & Secure UPI Payments"
        subtitle.font = .systemFont(ofSize: 14)
        subtitle.textColor = .secondaryLabel
        subtitle.textAlignment = .center
        stack.addArrangedSubview(subtitle)

        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stack.addArrangedSubview(spacer)

        configureField(emailField, placeholder: "Email", keyboard: .emailAddress)
        stack.addArrangedSubview(emailField)

        configureField(passwordField, placeholder: "Password", secure: true)
        stack.addArrangedSubview(passwordField)

        configureField(pinField, placeholder: "4-digit PIN", keyboard: .numberPad, secure: true)
        stack.addArrangedSubview(pinField)

        loginButton.setTitle("Sign In", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        loginButton.backgroundColor = UIColor(red: 124/255, green: 58/255, blue: 237/255, alpha: 1)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 12
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        stack.addArrangedSubview(loginButton)

        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = .systemRed
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        stack.addArrangedSubview(statusLabel)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])
    }

    private func configureField(_ field: UITextField, placeholder: String, keyboard: UIKeyboardType = .default, secure: Bool = false) {
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.keyboardType = keyboard
        field.isSecureTextEntry = secure
        field.autocapitalizationType = .none
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    @objc private func loginTapped() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let pin = pinField.text, !pin.isEmpty else {
            statusLabel.text = "Please fill all fields"
            return
        }

        statusLabel.text = "Signing in..."
        statusLabel.textColor = .secondaryLabel

        NSLog("[Login] Attempting login for \(email) with PIN \(pin)")

        APIClient.shared.login(email: email, password: password, pin: pin) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let token = json["token"] as? String {
                        UserDefaults.standard.authToken = token
                        UserDefaults.standard.userPin = pin
                        UserDefaults.standard.saveProfile(name: json["name"] as? String ?? "", email: email, phone: json["phone"] as? String ?? "", upiId: json["upi_id"] as? String ?? "")
                        self?.statusLabel.text = "Login successful"
                        self?.statusLabel.textColor = .systemGreen

                        // Navigate to home
                        let homeVC = HomeViewController()
                        self?.navigationController?.setViewControllers([homeVC], animated: true)
                    } else {
                        self?.statusLabel.text = json["error"] as? String ?? "Login failed"
                        self?.statusLabel.textColor = .systemRed
                    }
                case .failure(let error):
                    self?.statusLabel.text = error.localizedDescription
                    self?.statusLabel.textColor = .systemRed
                }
            }
        }
    }
}
