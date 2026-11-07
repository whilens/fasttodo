import SwiftUI
import UIKit

enum AppTheme {
    static let indigo = Color(red: 0.31, green: 0.275, blue: 0.898)
    static let splash = Color(red: 0.067, green: 0.094, blue: 0.153)
    static let ink = Color(red: 0.09, green: 0.11, blue: 0.16)
    static let inkMuted = Color(red: 0.29, green: 0.33, blue: 0.41)
    static let card = Color.white
}

extension View {
    @ViewBuilder
    func liquidGlass<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.clear.interactive(), in: shape)
        } else {
            self
                .background {
                    ZStack {
                        shape.fill(.ultraThinMaterial.opacity(0.55))
                        shape.fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.28),
                                    .white.opacity(0.04),
                                    .white.opacity(0.12),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing,
                            )
                        )
                    }
                }
                .overlay {
                    shape.strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.7), .white.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing,
                        ),
                        lineWidth: 0.8
                    )
                }
                .shadow(color: .black.opacity(0.18), radius: 24, y: 10)
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

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func delete() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
}
