import Foundation
import Security
import CryptoKit

// MARK: - Keychain Error
enum KeychainError: LocalizedError {
    case duplicateItem
    case itemNotFound
    case unexpectedData
    case unhandledError(OSStatus)
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .duplicateItem:
            return "El elemento ya existe en Keychain"
        case .itemNotFound:
            return "Elemento no encontrado en Keychain"
        case .unexpectedData:
            return "Datos inesperados en Keychain"
        case .unhandledError(let status):
            return "Error de Keychain: \(status)"
        case .encodingError:
            return "Error al codificar datos"
        case .decodingError:
            return "Error al decodificar datos"
        }
    }
}

// MARK: - Security Manager
/// Gestor de seguridad para datos financieros sensibles
final class SecurityManager {
    static let shared = SecurityManager()
    
    private let serviceName = "com.appfinanciera.keychain"
    private let encryptionKey: SymmetricKey
    
    private init() {
        // Generar o recuperar clave de encriptación
        if let existingKey = SecurityManager.loadEncryptionKey() {
            self.encryptionKey = existingKey
        } else {
            let newKey = SymmetricKey(size: .bits256)
            self.encryptionKey = newKey
            SecurityManager.saveEncryptionKey(newKey)
        }
    }
    
    // MARK: - Keychain Operations
    
    /// Guarda un valor seguro en Keychain
    func saveSecure<T: Encodable>(_ value: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        let encryptedData = try encrypt(data)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: encryptedData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Intentar eliminar si ya existe
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status)
        }
    }
    
    /// Recupera un valor seguro de Keychain
    func loadSecure<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unhandledError(status)
        }
        
        guard let encryptedData = result as? Data else {
            throw KeychainError.unexpectedData
        }
        
        let decryptedData = try decrypt(encryptedData)
        return try JSONDecoder().decode(T.self, from: decryptedData)
    }
    
    /// Elimina un valor de Keychain
    func deleteSecure(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status)
        }
    }
    
    /// Verifica si existe un valor en Keychain
    func existsSecure(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Encryption
    
    /// Encripta datos usando AES-GCM
    private func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
        guard let combined = sealedBox.combined else {
            throw KeychainError.encodingError
        }
        return combined
    }
    
    /// Desencripta datos usando AES-GCM
    private func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: encryptionKey)
    }
    
    // MARK: - Key Management
    
    private static let keyIdentifier = "com.appfinanciera.encryption.key"
    
    private static func saveEncryptionKey(_ key: SymmetricKey) {
        let keyData = key.withUnsafeBytes { Data($0) }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyIdentifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private static func loadEncryptionKey() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyIdentifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let keyData = result as? Data else {
            return nil
        }
        
        return SymmetricKey(data: keyData)
    }
    
    // MARK: - Secure Data Wiping
    
    /// Elimina todos los datos seguros de la aplicación
    func wipeAllSecureData() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Secure Storage Keys
enum SecureStorageKey: String {
    case apiToken = "api_token"
    case userCredentials = "user_credentials"
    case biometricEnabled = "biometric_enabled"
    case lastSyncDate = "last_sync_date"
    case encryptedFinancialData = "encrypted_financial_data"
}

// MARK: - Secure Logger
/// Logger seguro que no expone datos financieros en producción
struct SecureLogger {
    static func log(_ message: String, level: LogLevel = .info) {
        #if DEBUG
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("[\(timestamp)] [\(level.rawValue.uppercased())] \(message)")
        #endif
    }
    
    static func logError(_ error: Error, context: String = "") {
        #if DEBUG
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("[\(timestamp)] [ERROR] \(context): \(error.localizedDescription)")
        #else
        // En producción, enviar a servicio de logging sin datos sensibles
        #endif
    }
    
    /// Redacta información financiera sensible para logging
    static func redactFinancialInfo(_ value: Double) -> String {
        #if DEBUG
        return String(format: "%.2f", value)
        #else
        return "***.**"
        #endif
    }
    
    enum LogLevel: String {
        case debug, info, warning, error
    }
}

// MARK: - Data Masking
extension String {
    /// Enmascara información sensible (ej: números de cuenta)
    var masked: String {
        guard count > 4 else { return String(repeating: "*", count: count) }
        let visibleSuffix = suffix(4)
        let maskedPrefix = String(repeating: "*", count: count - 4)
        return maskedPrefix + visibleSuffix
    }
}

extension Double {
    /// Formatea cantidad monetaria de forma segura
    var secureFormatted: String {
        #if DEBUG
        return CurrencyFormatter.shared.format(self)
        #else
        // En producción, considerar si mostrar o enmascarar
        return CurrencyFormatter.shared.format(self)
        #endif
    }
}

// MARK: - Biometric Authentication
import LocalAuthentication

class BiometricAuthManager {
    static let shared = BiometricAuthManager()
    
    private let context = LAContext()
    
    private init() {}
    
    /// Verifica si la autenticación biométrica está disponible
    var isBiometricAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Tipo de biometría disponible
    var biometricType: LABiometryType {
        return context.biometryType
    }
    
    /// Autentica al usuario con biometría
    func authenticate(reason: String = "Autenticar para acceder a datos financieros") async -> Bool {
        guard isBiometricAvailable else { return false }
        
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch {
            SecureLogger.logError(error, context: "BiometricAuth")
            return false
        }
    }
}

