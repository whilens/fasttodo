import SwiftUI
import UIKit

enum AppTheme {
    static let indigo = Color(red: 0.31, green: 0.275, blue: 0.898)
    static let splash = Color(red: 0.067, green: 0.094, blue: 0.153)
}

extension View {
    @ViewBuilder
    func liquidGlass<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: shape)
        } else {
            self
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.stroke(.white.opacity(0.35), lineWidth: 0.8))
                .shadow(color: .black.opacity(0.14), radius: 18, y: 10)
        }
    }
}

enum Haptics {
    static func add() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func delete() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
}
