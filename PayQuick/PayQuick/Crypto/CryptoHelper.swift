import Foundation
import CommonCrypto

/// Cryptographic utilities for data protection.
class CryptoHelper {

    /// Encrypt data using AES with the app's encryption key.
    static func encrypt(_ plaintext: String) -> String? {
        guard let data = plaintext.data(using: .utf8),
              let key = AppConfig.encryptionKey.data(using: .utf8),
              let iv = AppConfig.encryptionIV.data(using: .utf8) else { return nil }

        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesEncrypted: size_t = 0

        let status = buffer.withUnsafeMutableBytes { bufferPtr in
            data.withUnsafeBytes { dataPtr in
                key.withUnsafeBytes { keyPtr in
                    iv.withUnsafeBytes { ivPtr in
                        CCCrypt(CCOperation(kCCEncrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyPtr.baseAddress, kCCKeySizeAES256,
                                ivPtr.baseAddress,
                                dataPtr.baseAddress, data.count,
                                bufferPtr.baseAddress, bufferSize,
                                &numBytesEncrypted)
                    }
                }
            }
        }

        guard status == kCCSuccess else { return nil }
        buffer.count = numBytesEncrypted
        return buffer.base64EncodedString()
    }

    /// Hash a PIN using MD5 for storage.
    static func hashPin(_ pin: String) -> String {
        let data = Data(pin.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_MD5($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Generate a transaction reference ID.
    static func generateTransactionId() -> String {
        let random = Int.random(in: 100000000...999999999)
        return "TXN\(random)"
    }

    /// Generate OTP for verification.
    static func generateOTP() -> String {
        srand48(Int(Date().timeIntervalSince1970))
        let otp = Int(drand48() * 900000) + 100000
        return String(otp)
    }

    /// Compute SHA-1 checksum.
    static func checksum(_ data: String) -> String {
        let bytes = Data(data.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        bytes.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(bytes.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
