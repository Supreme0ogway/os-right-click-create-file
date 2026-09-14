import Foundation
import Security

/// Which team signed the running bundle.
///
/// The folder the app and the Finder extension share is named after the team that
/// signed them, so the name cannot be written down in advance without tying the source
/// to one developer. Asking the running bundle instead means anybody can build this
/// with their own account and change nothing.
///
/// - Note: An unsigned build has no team, and then there is no shared folder and the
///   menu shows nothing. That is a build problem, not something a user can fix.
public enum SigningTeam {

    /// The team that signed the running bundle, or `nil` when it is unsigned.
    public static let identifier: String? = readIdentifier()

    private static func readIdentifier() -> String? {
        var code: SecCode?
        guard SecCodeCopySelf(SecCSFlags(), &code) == errSecSuccess, let code else { return nil }

        var staticCode: SecStaticCode?
        guard SecCodeCopyStaticCode(code, SecCSFlags(), &staticCode) == errSecSuccess,
              let staticCode
        else { return nil }

        var information: CFDictionary?
        let flags = SecCSFlags(rawValue: kSecCSSigningInformation)
        guard SecCodeCopySigningInformation(staticCode, flags, &information) == errSecSuccess,
              let found = information as? [String: Any]
        else { return nil }

        return found[kSecCodeInfoTeamIdentifier as String] as? String
    }
}
