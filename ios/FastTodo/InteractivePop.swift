import SwiftUI

struct InteractivePop<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder var content: Content

    @State private var dragX: CGFloat = 0
    @State private var dragging = false

    var body: some View {
        GeometryReader { geo in
            content
                .frame(width: geo.size.width, height: geo.size.height)
                .offset(x: max(0, dragX))
                .shadow(color: .black.opacity(dragX > 0 ? 0.22 : 0), radius: 18, x: -8)
                .gesture(popGesture(width: geo.size.width))
        }
        .background(AppTheme.card)
        .ignoresSafeArea(edges: .bottom)
    }

    private func popGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                let fromEdge = value.startLocation.x < 28 || dragging
                let horizontal = abs(value.translation.width) > abs(value.translation.height)
                guard fromEdge, horizontal else { return }
                dragging = true
                dragX = max(0, value.translation.width)
            }
            .onEnded { value in
                let shouldPop = value.translation.width > width * 0.28
                    || value.predictedEndTranslation.width > width * 0.45
                if shouldPop {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                        dragX = width
                    }
                    Haptics.selection()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        dismiss()
                    }
                } else {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
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
