import Foundation

/// Keeping one record in one JSON file.
///
/// The app writes these files and the Finder extension reads them, so they are plain
/// sorted JSON a person can open and edit. Reading never fails: a file that is missing
/// or damaged answers with the fallback, because a legend that will not load must
/// leave the menu empty rather than leave the Finder broken.
///
/// Not a store. Nothing here remembers anything or tells anybody about a change.

/// Reads and writes one record as a JSON file.
public enum RecordFile {

    /// Reads a record, answering with the fallback when there is nothing good to read.
    ///
    /// A missing file is normal: it means nobody has saved one yet. A damaged file is
    /// treated the same way on purpose, so a bad edit cannot stop the app starting.
    ///
    /// - Parameters:
    ///   - fileURL: Where the file is.
    ///   - fallback: What to answer with when the file is missing or unreadable.
    /// - Returns: The record that was read, or `fallback`.
    public static func read<Record: Decodable>(from fileURL: URL, fallback: Record) -> Record {
        guard let data = try? Data(contentsOf: fileURL) else { return fallback }
        guard let record = try? decoder.decode(Record.self, from: data) else { return fallback }
        return record
    }

    /// Writes a record, making any folder it needs on the way.
    ///
    /// The file is replaced whole, so a reader never sees half of one.
    ///
    /// - Parameters:
    ///   - record: What to write.
    ///   - fileURL: Where to write it.
    /// - Throws: Whatever the file system says when the folder or the file refuses.
    public static func write<Record: Encodable>(_ record: Record, to fileURL: URL) throws {
        let folder = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try encoder.encode(record).write(to: fileURL, options: .atomic)
    }

    private static let decoder = JSONDecoder()

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }()
}
