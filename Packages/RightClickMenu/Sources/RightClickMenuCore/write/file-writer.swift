import Foundation

/// Making the file the user asked for.
///
/// The one place in the app that puts a new file on a disk. It picks a name nothing
/// else is using, writes the type's template into it, and says where it landed.
///
/// Deliberately not the place that decides whether it is allowed to write there. That
/// is the operating system's answer, and it arrives as a thrown error.

/// Why a file could not be written.
public enum FileWriterError: Error, Equatable, Sendable {

    /// Nothing is at the chosen path.
    case folderIsMissing

    /// Something is at the chosen path, but it is a file, not a folder.
    case notAFolder

    /// A name could not be chosen. Carries the reason.
    case cannotChooseName(FileNamerError)

    /// The disk refused the write. Carries what it said.
    case writeRefused(String)
}

/// Writes one new file of a chosen type into a chosen folder.
///
/// - Note: Holds a file manager, which is not safe to hand between threads. Make one
///   where it is used rather than sharing it.
public struct FileWriter {

    private let fileManager: FileManager

    /// Builds a writer.
    ///
    /// - Parameter fileManager: The file manager to work through. Defaults to the shared one.
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    /// Creates a new file of this type inside this folder.
    ///
    /// The name counts up past anything already there, so nothing is ever overwritten.
    ///
    /// - Parameters:
    ///   - type: The type of file to make. Its template becomes the contents.
    ///   - folder: The folder to write into. It must already exist.
    /// - Returns: Where the new file landed.
    /// - Throws: ``FileWriterError`` saying which step failed and why.
    @discardableResult
    public func createFile(ofType type: FileType, in folder: URL) throws -> URL {
        try checkIsAFolder(folder)

        let taken = Set((try? fileManager.contentsOfDirectory(atPath: folder.path)) ?? [])
        let name = try chooseName(for: type, avoiding: taken)
        let destination = folder.appending(path: name)

        do {
            try Data(type.template.utf8).write(to: destination, options: .withoutOverwriting)
        } catch {
            throw FileWriterError.writeRefused(error.localizedDescription)
        }
        return destination
    }

    private func checkIsAFolder(_ folder: URL) throws {
        var isFolder: ObjCBool = false
        let exists = fileManager.fileExists(atPath: folder.path, isDirectory: &isFolder)
        guard exists else { throw FileWriterError.folderIsMissing }
        guard isFolder.boolValue else { throw FileWriterError.notAFolder }
    }

    private func chooseName(for type: FileType, avoiding taken: Set<String>) throws -> String {
        do {
            return try FileNamer.firstFreeName(
                base: type.defaultBaseName,
                fileExtension: type.fileExtension,
                takenNames: taken
            )
        } catch let error as FileNamerError {
            throw FileWriterError.cannotChooseName(error)
        }
    }
}
