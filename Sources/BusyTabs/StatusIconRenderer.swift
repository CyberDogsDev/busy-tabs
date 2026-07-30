import AppKit

enum StatusIconRenderer {
    /// A filled circle in the given status color, sized for the menu bar.
    /// Falls back to a hollow gray circle when there's no color (offline/disconnected).
    static func image(hex: String?) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let diameter: CGFloat = 12
        let rect = NSRect(
            x: (size.width - diameter) / 2,
            y: (size.height - diameter) / 2,
            width: diameter,
            height: diameter
        )

        let image = NSImage(size: size, flipped: false) { _ in
            let path = NSBezierPath(ovalIn: rect)
            if let hex, let color = NSColor(hex: hex) {
                color.setFill()
                path.fill()
                // Hairline outline so light colors stay visible on light menu bars.
                NSColor.black.withAlphaComponent(0.25).setStroke()
                path.lineWidth = 0.5
                path.stroke()
            } else {
                NSColor.systemGray.setStroke()
                path.lineWidth = 1.5
                path.stroke()
            }
            return true
        }
        image.isTemplate = false
        return image
    }
}
