import SwiftUI

struct CoverHost<List: View, Detail: View>: View {
    var isPresented: Bool
    var onClose: () -> Void
    @ViewBuilder var list: List
    @ViewBuilder var detail: Detail

    @State private var dragX: CGFloat = 0
    @State private var width: CGFloat = 390
    @State private var dragging = false

    private var progress: CGFloat {
        guard isPresented, width > 0 else { return 0 }
        return max(0, min(1, 1 - dragX / width))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                list
                    .offset(x: isPresented ? -geo.size.width * 0.3 * progress : 0)
                    .allowsHitTesting(!isPresented)

                if isPresented {
                    detail
                        .offset(x: dragX)
                        .gesture(swipeGesture)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear { width = geo.size.width }
            .onChange(of: geo.size.width) { _, newWidth in
                width = newWidth
            }
            .onChange(of: isPresented) { _, open in
                if open {
                    dragX = geo.size.width
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                        dragX = 0
                    }
                }
            }
        }
        .environment(\.coverDismiss, CoverDismissAction(close: dismissCover))
    }

    private func dismissCover() {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
            dragX = width
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(220))
            onClose()
            dragX = 0
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                let horizontal = value.translation.width > abs(value.translation.height)
                guard horizontal else { return }
                dragging = true
                dragX = max(0, value.translation.width)
            }
            .onEnded { value in
                let translation = max(0, value.translation.width)
                let projected = max(0, value.predictedEndTranslation.width)
                let passed = translation > width * 0.28 || projected > width * 0.5
                if passed {
                    Haptics.selection()
                    dismissCover()
                } else {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                        dragX = 0
                    }
                }
                dragging = false
            }
    }
}

private struct CoverDismissKey: EnvironmentKey {
    static let defaultValue = CoverDismissAction(close: {})
}

struct CoverDismissAction {
    var close: () -> Void
}

extension EnvironmentValues {
    var coverDismiss: CoverDismissAction {
        get { self[CoverDismissKey.self] }
        set { self[CoverDismissKey.self] = newValue }
    }
}

struct GlassBackButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.body.weight(.bold))
                .foregroundStyle(AppTheme.ink)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .liquidGlass(in: Circle())
    }
}
