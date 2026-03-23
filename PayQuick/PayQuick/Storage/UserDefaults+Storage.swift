import Foundation

/// User preferences and session storage.
/// Uses UserDefaults for quick access to frequently needed values.
extension UserDefaults {

    private enum Keys {
        static let authToken = "auth_token"
        static let refreshToken = "refresh_token"
        static let userPin = "user_pin"
        static let lastBalance = "last_balance"
        static let userName = "user_name"
        static let userEmail = "user_email"
        static let userPhone = "user_phone"
        static let userUpiId = "user_upi_id"
        static let cardNumber = "card_number"
        static let cardExpiry = "card_expiry"
        static let cardCVV = "card_cvv"
        static let aadhaarNumber = "aadhaar_number"
        static let panNumber = "pan_number"
    }

    // MARK: - Auth

    var authToken: String? {
        get { string(forKey: Keys.authToken) }
        set {
            set(newValue, forKey: Keys.authToken)
            NSLog("[Storage] Auth token saved: \(newValue ?? "nil")")
        }
    }

    var refreshToken: String? {
        get { string(forKey: Keys.refreshToken) }
        set { set(newValue, forKey: Keys.refreshToken) }
    }

    var userPin: String? {
        get { string(forKey: Keys.userPin) }
        set { set(newValue, forKey: Keys.userPin) }
    }

    // MARK: - Account

    var lastBalance: Double {
        get { double(forKey: Keys.lastBalance) }
        set { set(newValue, forKey: Keys.lastBalance) }
    }

    func saveProfile(name: String, email: String, phone: String, upiId: String) {
        set(name, forKey: Keys.userName)
        set(email, forKey: Keys.userEmail)
        set(phone, forKey: Keys.userPhone)
        set(upiId, forKey: Keys.userUpiId)
        NSLog("[Storage] Profile saved: \(name) | \(email) | \(phone) | UPI: \(upiId)")
    }

    // MARK: - Card (for quick payments)

    func saveCard(number: String, expiry: String, cvv: String) {
        set(number, forKey: Keys.cardNumber)
        set(expiry, forKey: Keys.cardExpiry)
        set(cvv, forKey: Keys.cardCVV)
    }

    var cardNumber: String? { string(forKey: Keys.cardNumber) }
    var cardCVV: String? { string(forKey: Keys.cardCVV) }

    // MARK: - KYC

    func saveKYC(aadhaar: String, pan: String) {
        set(aadhaar, forKey: Keys.aadhaarNumber)
        set(pan, forKey: Keys.panNumber)
        NSLog("[Storage] KYC saved: Aadhaar=\(aadhaar) PAN=\(pan)")
    }

    var isLoggedIn: Bool { authToken != nil }

    func clearSession() {
        let keys = [Keys.authToken, Keys.refreshToken, Keys.userPin, Keys.lastBalance,
                    Keys.userName, Keys.userEmail, Keys.userPhone, Keys.userUpiId,
                    Keys.cardNumber, Keys.cardExpiry, Keys.cardCVV,
                    Keys.aadhaarNumber, Keys.panNumber]
        keys.forEach { removeObject(forKey: $0) }
    }
}
