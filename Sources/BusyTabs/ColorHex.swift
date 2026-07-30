import AppKit
import SwiftUI

enum ColorHex {
    /// Parses "#RRGGBB" (leading '#' optional). Returns nil for anything else.
    static func components(_ hex: String) -> (r: CGFloat, g: CGFloat, b: CGFloat)? {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let value = UInt32(s, radix: 16) else { return nil }
        return (
            r: CGFloat((value >> 16) & 0xFF) / 255,
            g: CGFloat((value >> 8) & 0xFF) / 255,
            b: CGFloat(value & 0xFF) / 255
        )
    }
}

extension NSColor {
    convenience init?(hex: String) {
        guard let c = ColorHex.components(hex) else { return nil }
        self.init(srgbRed: c.r, green: c.g, blue: c.b, alpha: 1)
    }
}

extension Color {
    init(hex: String, fallback: Color = .gray) {
        guard let c = ColorHex.components(hex) else {
            self = fallback
            return
        }
        self = Color(.sRGB, red: c.r, green: c.g, blue: c.b, opacity: 1)
    }
}

/// Cyber Dogs brand accents for the panel chrome.
enum Brand {
    static let ink = Color(hex: "#0E1116")
    static let slate = Color(hex: "#1C232E")
    static let cloud = Color(hex: "#C7D0DC")
    static let viceCyan = Color(hex: "#00E5FF")
    static let offlineGray = "#8E8E93"
}
