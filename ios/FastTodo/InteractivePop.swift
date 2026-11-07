import SwiftUI

/// Страница едет 1:1 за пальцем.
/// Если порог/скорость пройдены — доезжает и закрывается, иначе пружиной возвращается.
struct InteractivePop<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder var content: Content

    @State private var dragX: CGFloat = 0
    @State private var dragging = false

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            content
                .frame(width: width, height: geo.size.height)
                .offset(x: max(0, dragX))
                .highPriorityGesture(popGesture(width: width))
        }
        .background(AppTheme.card)
        .ignoresSafeArea(edges: .bottom)
    }

    private func popGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                let fromEdge = value.startLocation.x < 36 || dragging
                let horizontal = abs(value.translation.width) > abs(value.translation.height) * 0.65
                guard fromEdge, horizontal else { return }
                dragging = true
                dragX = max(0, value.translation.width)
            }
            .onEnded { value in
                let translation = max(0, value.translation.width)
                let projected = max(0, value.predictedEndTranslation.width)
                let passed = translation > width * 0.28 || projected > width * 0.5

                if passed {
                    Haptics.selection()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                        dragX = width
                    }
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(220))
                        dismiss()
                    }
                } else {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                        dragX = 0
                    }
                }
                dragging = false
            }
    }
}

struct BackHeader: View {
    let title: String
    var onBack: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                    Text("Назад")
                }
                .foregroundStyle(AppTheme.indigo)
            }
            Spacer()
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
            Spacer()
            Color.clear.frame(width: 64)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
