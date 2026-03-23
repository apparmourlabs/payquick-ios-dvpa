import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PayQuick"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))

        setupUI()
        loadBalance()
    }

    private func setupUI() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        // Balance card
        let balanceCard = UIView()
        balanceCard.backgroundColor = UIColor(red: 124/255, green: 58/255, blue: 237/255, alpha: 1)
        balanceCard.layer.cornerRadius = 16
        let balanceLabel = UILabel()
        balanceLabel.text = "₹\(UserDefaults.standard.lastBalance)"
        balanceLabel.font = .systemFont(ofSize: 36, weight: .bold)
        balanceLabel.textColor = .white
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceCard.addSubview(balanceLabel)
        let balanceTitle = UILabel()
        balanceTitle.text = "Available Balance"
        balanceTitle.font = .systemFont(ofSize: 12)
        balanceTitle.textColor = UIColor.white.withAlphaComponent(0.7)
        balanceTitle.translatesAutoresizingMaskIntoConstraints = false
        balanceCard.addSubview(balanceTitle)
        balanceCard.heightAnchor.constraint(equalToConstant: 120).isActive = true
        NSLayoutConstraint.activate([
            balanceTitle.topAnchor.constraint(equalTo: balanceCard.topAnchor, constant: 20),
            balanceTitle.leadingAnchor.constraint(equalTo: balanceCard.leadingAnchor, constant: 20),
            balanceLabel.topAnchor.constraint(equalTo: balanceTitle.bottomAnchor, constant: 4),
            balanceLabel.leadingAnchor.constraint(equalTo: balanceCard.leadingAnchor, constant: 20),
        ])
        stack.addArrangedSubview(balanceCard)

        // Quick actions
        let actions = UIStackView()
        actions.axis = .horizontal
        actions.distribution = .fillEqually
        actions.spacing = 12
        for (title, icon) in [("Send", "arrow.up.circle"), ("Receive", "arrow.down.circle"), ("Scan QR", "qrcode"), ("History", "clock")] {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.setImage(UIImage(systemName: icon), for: .normal)
            btn.tintColor = UIColor(red: 124/255, green: 58/255, blue: 237/255, alpha: 1)
            btn.titleLabel?.font = .systemFont(ofSize: 11)
            btn.backgroundColor = .secondarySystemBackground
            btn.layer.cornerRadius = 12
            btn.heightAnchor.constraint(equalToConstant: 70).isActive = true
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            btn.titleEdgeInsets = UIEdgeInsets(top: 30, left: -30, bottom: 0, right: 0)
            actions.addArrangedSubview(btn)
        }
        stack.addArrangedSubview(actions)

        // Recent transactions header
        let recentLabel = UILabel()
        recentLabel.text = "Recent Transactions"
        recentLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        stack.addArrangedSubview(recentLabel)

        // Mock transactions
        for (name, amount, type) in [("Grocery Store", "-₹450", "debit"), ("Salary Credit", "+₹45,000", "credit"), ("Electricity Bill", "-₹1,200", "debit")] {
            let row = UIView()
            row.heightAnchor.constraint(equalToConstant: 50).isActive = true
            let nameLabel = UILabel()
            nameLabel.text = name
            nameLabel.font = .systemFont(ofSize: 14)
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(nameLabel)
            let amountLabel = UILabel()
            amountLabel.text = amount
            amountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            amountLabel.textColor = type == "credit" ? .systemGreen : .label
            amountLabel.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(amountLabel)
            NSLayoutConstraint.activate([
                nameLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                nameLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                amountLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                amountLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            ])
            stack.addArrangedSubview(row)
        }

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -16),
        ])
    }

    private func loadBalance() {
        APIClient.shared.request("/account/balance") { result in
            if case .success(let json) = result, let balance = json["balance"] as? Double {
                UserDefaults.standard.lastBalance = balance
            }
        }
    }

    @objc private func logout() {
        UserDefaults.standard.clearSession()
        let loginVC = LoginViewController()
        navigationController?.setViewControllers([loginVC], animated: true)
    }
}
