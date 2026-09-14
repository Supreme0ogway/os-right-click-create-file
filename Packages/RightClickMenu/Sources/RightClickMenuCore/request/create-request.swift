import Foundation

/// One ask from the Finder extension to the app: make a file of this type, here.
///
/// The extension runs in a sandbox and is not allowed to write anywhere, so it asks
/// the app instead. The ask travels as an address, which also starts the app when it
/// is not already running.
///
/// Reading one is deliberately strict. Anything on the machine can send an address, so
/// a request that is not exactly right is refused rather than guessed at.

/// A request to create one new file.
public struct CreateRequest: Hashable, Sendable {

    /// The type of file to make.
    public let typeId: FileTypeIdentifier

    /// The folder to make it in, as an absolute path.
    public let folderPath: String

    /// Builds a request.
    ///
    /// - Parameters:
    ///   - typeId: The type of file to make.
    ///   - folderPath: Where to make it, as an absolute path.
    public init(typeId: FileTypeIdentifier, folderPath: String) {
        self.typeId = typeId
        self.folderPath = folderPath
    }

    /// Reads a request out of an address, refusing anything that is not one.
    ///
    /// - Parameter url: The address the app was opened with.
    /// - Returns: The request, or `nil` when the address is not a well formed one.
    public init?(url: URL) {
        guard url.scheme == BundleConstants.urlScheme else { return nil }
        guard url.host() == RequestConstants.createAction else { return nil }

        let fields = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        guard let typeText = fields.first(where: { $0.name == RequestConstants.typeField })?.value,
              let folder = fields.first(where: { $0.name == RequestConstants.folderField })?.value,
              let typeId = try? FileTypeIdentifier(typeText),
              folder.hasPrefix(ScopeConstants.rootPath)
        else { return nil }

        self.typeId = typeId
        self.folderPath = folder
    }

    /// The request written as an address the app can be opened with.
    public var url: URL {
        var components = URLComponents()
        components.scheme = BundleConstants.urlScheme
        components.host = RequestConstants.createAction
        components.queryItems = [
            URLQueryItem(name: RequestConstants.typeField, value: typeId.text),
            URLQueryItem(name: RequestConstants.folderField, value: folderPath),
        ]
        return components.url ?? URL(filePath: ScopeConstants.rootPath)
    }
}
