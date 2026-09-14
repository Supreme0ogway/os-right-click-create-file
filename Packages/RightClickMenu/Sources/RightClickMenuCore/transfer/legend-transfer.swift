import Foundation

/// Taking a list of file types out of the app and bringing one back in.
///
/// Written as plain JSON, the same shape the app keeps on disk, so a list can be kept
/// as a backup, put in a repository, or handed to somebody else.
///
/// Bringing a list in adds to what is already there rather than replacing it. A type
/// that shares an id with one already in the list takes its place and keeps it, so
/// bringing the same file in twice changes nothing the second time.

/// Why a list of file types could not be read.
public enum LegendTransferError: Error, Equatable, Sendable {

    /// The file was not a list of file types, or was damaged.
    case cannotBeRead
}

/// Writes a list of file types out, and reads one back in.
public enum LegendTransfer {

    /// What a written out file is called by default.
    public static let suggestedFileName = TransferConstants.suggestedFileName

    /// Turns a list of file types into the contents of a file.
    ///
    /// - Parameter legend: The types to write out.
    /// - Returns: The file's contents, as sorted and spaced JSON.
    /// - Throws: Whatever the encoder throws, which nothing here is expected to cause.
    public static func data(for legend: Legend) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(legend)
    }

    /// Reads a list of file types out of a file's contents.
    ///
    /// - Parameter data: What was in the file.
    /// - Returns: The types it held.
    /// - Throws: ``LegendTransferError/cannotBeRead`` for anything that is not a list
    ///   of file types, damaged or otherwise.
    public static func legend(from data: Data) throws -> Legend {
        guard let legend = try? JSONDecoder().decode(Legend.self, from: data) else {
            throw LegendTransferError.cannotBeRead
        }
        return legend
    }

    /// Puts a list that came in together with the one already there.
    ///
    /// - Parameters:
    ///   - incoming: The types that came in.
    ///   - existing: The types already in the app.
    /// - Returns: The two together. A shared id keeps its place and takes the new type.
    public static func joining(_ incoming: Legend, into existing: Legend) -> Legend {
        incoming.types.reduce(existing) { legend, type in legend.adding(type) }
    }
}
