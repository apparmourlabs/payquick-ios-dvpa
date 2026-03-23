# PayQuick iOS — Damn Vulnerable Payment App

The iOS version of PayQuick — a deliberately vulnerable UPI payment app built for **mobile security training and SAST tool demonstration**.

> **WARNING:** This app contains intentional security vulnerabilities. Do NOT use any of this code in production.

## Download

- **IPA:** [PayQuick-v2.3.1-dvpa.ipa](https://github.com/apparmourlabs/payquick-ios-dvpa/releases/latest)
- **APK (Android):** [payquick-dvpa](https://github.com/apparmourlabs/payquick-dvpa/releases/latest)

## Vulnerabilities (22 across OWASP MASVS)

| Category | Count | Key Issues |
|----------|-------|------------|
| **Data Storage** | 5 | Secrets in UserDefaults, sensitive logging, clipboard exposure |
| **Cryptography** | 3 | Hardcoded AES key/IV, MD5 PIN hashing, weak RNG |
| **Network Security** | 3 | NSAllowsArbitraryLoads, disabled SSL pinning, trust-all certs |
| **Platform Security** | 4 | Insecure WebView, deep link injection, URL scheme abuse |
| **Code Quality** | 4 | SQL-like issues, path exposure, no obfuscation |
| **App Resilience** | 3 | No jailbreak detection, no anti-tampering |

## Scan It

Upload the IPA to [AppArmour Labs](https://apparmourlabs.com/scan) for a free security assessment.

## Building

```bash
cd PayQuick
xcodebuild build -project PayQuick.xcodeproj -scheme PayQuick \
  -sdk iphonesimulator -configuration Release \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO
```

## License

MIT — Use freely for education and security research.

## Credits

Built by [AppArmour Labs](https://apparmourlabs.com) — AI-Powered Mobile App Security Analysis.
