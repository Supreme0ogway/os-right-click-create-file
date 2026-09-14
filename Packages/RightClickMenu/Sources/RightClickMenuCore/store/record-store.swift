import Foundation

/// One reading of one record, and everything that wants it subscribes.
///
/// The legend is the obvious case: the editor, the menu and the writer all want it,
/// and if any of them kept its own copy the two would drift apart. So there is one
/// store, it holds the only copy, and it tells everybody when that copy changes.
///
/// A store nobody has saved to answers like an empty one, so the app runs on a first
/// launch with nothing set up. It never knows who is listening.

/// How to stop being told about changes.
///
/// Stops on its own when it is let go of, so a subscriber that forgets cannot leak.
@MainActor
public final class StoreSubscription {

    private var stop: (() -> Void)?

    fileprivate init(stop: @escaping () -> Void) {
        self.stop = stop
    }

    deinit {
        MainActor.assumeIsolated { stop?() }
    }

    /// Stops the subscription. Calling it again changes nothing.
    public func cancel() {
        stop?()
        stop = nil
    }
}

/// Holds one record, keeps it on disk, and tells its subscribers when it changes.
@MainActor
public final class RecordStore<Record: Codable & Equatable> {

    private let fileURL: URL
    private let fallback: Record
    private var subscribers: [Int: (Record) -> Void] = [:]
    private var nextSubscriberKey = 0

    /// What the record says right now.
    public private(set) var value: Record

    /// How many subscribers are listening. Here so a test can prove nothing leaked.
    public var subscriberCount: Int { subscribers.count }

    /// Builds a store and reads whatever is already on disk.
    ///
    /// - Parameters:
    ///   - fileURL: The file this record lives in.
    ///   - fallback: What to answer with when nothing has been saved yet.
    public init(fileURL: URL, fallback: Record) {
        self.fileURL = fileURL
        self.fallback = fallback
        self.value = RecordFile.read(from: fileURL, fallback: fallback)
    }

    /// Starts being told what the record says, now and on every change.
    ///
    /// The closure is called once straight away with the value as it stands, so a new
    /// subscriber never has to ask separately for the state it missed.
    ///
    /// - Parameter onChange: Called with the record now, and again whenever it changes.
    /// - Returns: How to stop. Letting go of it also stops.
    public func subscribe(_ onChange: @escaping (Record) -> Void) -> StoreSubscription {
        let key = nextSubscriberKey
        nextSubscriberKey += 1
        subscribers[key] = onChange
        onChange(value)

        return StoreSubscription { [weak self] in
            self?.subscribers[key] = nil
        }
    }

    /// Saves a new record, writes it to disk, and tells every subscriber.
    ///
    /// - Parameter record: What the record should say from now on.
    /// - Throws: Whatever the file system says when the write is refused. The held
    ///   value is only changed once the write has worked.
    public func save(_ record: Record) throws {
        try RecordFile.write(record, to: fileURL)
        publish(record)
    }

    /// Reads the file again, in case another process wrote it.
    ///
    /// Tells subscribers only when the record actually changed, so nothing redraws
    /// for a read that found the same thing.
    public func reload() {
        publish(RecordFile.read(from: fileURL, fallback: fallback))
    }

    private func publish(_ record: Record) {
        guard record != value else { return }
        value = record
        for onChange in subscribers.values {
            onChange(record)
        }
    }
}
