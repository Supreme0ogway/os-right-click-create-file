import RightClickMenuShared

/// Choosing a name for a new file that does not tread on one already there.
///
/// Counts up the way the Finder does, so `Untitled.txt` is followed by `Untitled 2.txt`.
/// Knows nothing about disks: it is handed the names already in the folder and works
/// the answer out, which is what makes it testable without touching a file.

/// Why a name could not be chosen.
public enum FileNamerError: Error, Equatable, Sendable {

    /// Every name up to the limit was taken.
    case noFreeName

    /// The base name could not be part of a file name at all.
    case unusableName
}

/// Picks the first name in a folder that nothing else has.
public enum FileNamer {

    /// Finds the first free name for a new file.
    ///
    /// Tries the plain name first, then counts up. Names are compared without regard
    /// to case, because a mac disk normally cannot tell `notes.txt` from `Notes.TXT`.
    ///
    /// - Parameters:
    ///   - base: The name before the extension, such as `Untitled`. Blank falls back.
    ///   - fileExtension: The extension with no dot. Empty makes a name with no dot.
    ///   - takenNames: The names already in the folder.
    /// - Returns: A file name, extension included, that is not in `takenNames`.
    /// - Throws: ``FileNamerError/unusableName`` when the base cannot name a file, or
    ///   ``FileNamerError/noFreeName`` when everything up to the limit is taken.
    public static func firstFreeName(
        base: String,
        fileExtension: String,
        takenNames: Set<String>
    ) throws -> String {
        let cleanBase = usableBase(base)
        guard !cleanBase.isEmpty else { throw FileNamerError.unusableName }

        let taken = Set(takenNames.map { $0.lowercased() })
        let plain = join(base: cleanBase, fileExtension: fileExtension)
        guard taken.contains(plain.lowercased()) else { return plain }

        let first = FileNamerConstants.firstSuffix
        let lastSuffix = first + FileNamerConstants.maximumAttempts
        for suffix in first..<lastSuffix {
            let numbered = cleanBase + FileNamerConstants.suffixSeparator + String(suffix)
            let candidate = join(base: numbered, fileExtension: fileExtension)
            guard taken.contains(candidate.lowercased()) else { return candidate }
        }
        throw FileNamerError.noFreeName
    }

    private static func usableBase(_ base: String) -> String {
        let trimmed = base.trimmed
        let forbidden = FileNamerConstants.forbiddenCharacters
        let holdsForbidden = trimmed.contains { forbidden.contains($0) }
        guard !holdsForbidden else { return "" }

        let isOnlyDots = !trimmed.isEmpty
            && trimmed.allSatisfy { String($0) == ExtensionConstants.dot }
        guard !isOnlyDots else { return "" }

        return trimmed.isEmpty ? LegendConstants.fallbackBaseName : trimmed
    }

    private static func join(base: String, fileExtension: String) -> String {
        let clean = fileExtension.trimmed
        guard !clean.isEmpty else { return base }
        return base + ExtensionConstants.dot + clean
    }
}
