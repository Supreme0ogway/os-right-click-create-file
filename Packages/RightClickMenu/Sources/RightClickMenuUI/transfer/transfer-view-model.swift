import Foundation
import Observation

/// Writing the file types out to a file, and reading them back in.
///
/// A file that cannot be read leaves the list exactly as it was and says so. Nothing
/// is half brought in: either the whole file was a list of file types or none of it was.
@MainActor
@Observable
public final class TransferViewModel {

    /// The store the types are written out of and read back into.
    public let store: RecordStore<Legend>

    /// What went wrong the last time, if anything did.
    public private(set) var problem: String?

    /// Builds the model.
    ///
    /// - Parameter store: The one copy of the file types.
    public init(store: RecordStore<Legend>) {
        self.store = store
    }

    /// What a written out file should be called.
    public var suggestedFileName: String { LegendTransfer.suggestedFileName }

    /// Writes every file type out to a file.
    ///
    /// - Parameter destination: Where to write it.
    public func export(to destination: URL) {
        do {
            try LegendTransfer.data(for: store.value).write(to: destination)
            problem = nil
        } catch {
            problem = error.localizedDescription
        }
    }

    /// Reads file types in from a file and adds them to the list.
    ///
    /// - Parameter source: The file to read.
    public func importFrom(_ source: URL) {
        guard let data = try? Data(contentsOf: source),
              let incoming = try? LegendTransfer.legend(from: data)
        else {
            problem = UIText.fileIsDamaged
            return
        }

        do {
            try store.save(LegendTransfer.joining(incoming, into: store.value))
            problem = nil
        } catch {
            problem = error.localizedDescription
        }
    }

    /// Takes the last message away.
    public func clearProblem() {
        problem = nil
    }
}
