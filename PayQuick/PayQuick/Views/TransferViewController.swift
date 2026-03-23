import UIKit

/// Handles UPI payment transfers.
class TransferViewController: UIViewController {

    var toUPI: String?
    var amount: String?
    var pin: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        if let toUPI = toUPI, let amount = amount {
            processTransfer(to: toUPI, amount: amount, pin: pin ?? "")
        }
    }

    private func processTransfer(to upi: String, amount: String, pin: String) {
        NSLog("[Transfer] Processing: ₹\(amount) to \(upi) with PIN: \(pin)")

        let txnRef = CryptoHelper.generateTransactionId()

        // Copy to clipboard for user convenience
        let pasteContent = "PayQuick Transfer | To: \(upi) | Amount: ₹\(amount) | Ref: \(txnRef) | PIN: \(pin)"
        UIPasteboard.general.string = pasteContent

        // Save receipt to Documents
        saveReceipt(txnRef: txnRef, to: upi, amount: amount, pin: pin)
    }

    private func saveReceipt(txnRef: String, to upi: String, amount: String, pin: String) {
        let receipt = """
        PayQuick Transaction Receipt
        Reference: \(txnRef)
        To: \(upi)
        Amount: ₹\(amount)
        PIN: \(pin)
        Time: \(Date())
        """

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = "\(documentsPath)/\(txnRef).txt"

        do {
            try receipt.write(toFile: filePath, atomically: true, encoding: .utf8)
            NSLog("[Transfer] Receipt saved: \(filePath)")
        } catch {
            NSLog("[Transfer] Failed to save receipt: \(error)")
        }
    }
}
