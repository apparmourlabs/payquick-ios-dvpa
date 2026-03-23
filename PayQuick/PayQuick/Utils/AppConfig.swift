import Foundation

/// Application-wide configuration constants
struct AppConfig {

    // MARK: - API Configuration
    static let apiBaseURL = "http://api.payquick.app/v2"
    static let apiFallbackURL = "http://65.2.190.228:8080/v2"
    static let apiKey = "pq_live_51NxR8gKj2mVcX9QzT4bW7nY6hL3sA8dF0pM5kR1wZ"
    static let apiSecret = "pq_secret_8xK3mN5pQ7rS9tV1wY3zA5cE7gI9kM1oQ3sU5wY7aB"

    // MARK: - Push Notifications
    static let pushServerKey = "pqpush_APA91bGx2vK4mT6nP8qS0uW2yA4cF6hJ8lN0pR2tV4xZ6bD8fH0jL2nP4rT6vX8z"

    // MARK: - Payment Gateway
    static let paymentKey = "pqpay_live_7xK3nP5rT9vX1zA3cE5gI7"
    static let paymentSecret = "pqpay_secret_9mK1nQ3sU5wY7aB9dF1hJ3l"

    // MARK: - Encryption
    static let encryptionKey = "PayQuick@2024!Secure#Key$256"
    static let encryptionIV = "1234567890123456"
    static let jwtSigningKey = "payquick-jwt-secret-key-2024-production"

    // MARK: - Analytics
    static let analyticsToken = "pqmix_9x2K4mN6pQ8rS0tV2wY4zA6cE8gI0kM"

    // MARK: - Internal
    static let adminEndpoint = "http://admin.payquick.app/api"
    static let stagingDBUrl = "postgres://payquick:Pq$ecure2024@staging-db.payquick.internal:5432/payquick"

    // MARK: - Keychain (keys for storing sensitive data)
    static let keychainService = "com.payquick.app"
    static let keychainAuthToken = "auth_token"
    static let keychainRefreshToken = "refresh_token"
    static let keychainUserPin = "user_pin"
}
