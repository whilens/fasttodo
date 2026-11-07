import SwiftUI

struct SplashView: View {
    @State private var pulse = false
    @State private var spin = false

    var body: some View {
        ZStack {
            AppTheme.splash.ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .trim(from: 0.08, to: 0.86)
                        .stroke(AppTheme.indigo, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 108, height: 108)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .animation(.linear(duration: 1.1).repeatForever(autoreverses: false), value: spin)

                    Circle()
                        .fill(AppTheme.indigo)
                        .frame(width: 64, height: 64)
                        .scaleEffect(pulse ? 1.08 : 0.9)
                        .overlay {
                            Text("✓")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                        .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: pulse)
                }

                Text("FastTodo")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .opacity(pulse ? 1 : 0.6)

                Text("Собираем ваши задачи…")
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .onAppear {
            pulse = true
            spin = true
        }
    }
}
