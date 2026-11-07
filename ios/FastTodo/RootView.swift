import SwiftUI

enum AppTab: Hashable {
    case tasks
    case notes
    case calculator
}

struct RootView: View {
    @State private var showSplash = true
    @State private var tab: AppTab = .tasks
    @State private var store = AppStore()

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                MainShell(tab: $tab, store: store)
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .animation(.easeInOut(duration: 0.45), value: showSplash)
        .task {
            try? await Task.sleep(for: .milliseconds(2200))
            showSplash = false
        }
    }
}

struct MainShell: View {
    @Binding var tab: AppTab
    var store: AppStore

    var body: some View {
        ZStack(alignment: .bottom) {
            tabBackground
                .ignoresSafeArea()

            Group {
                switch tab {
                case .tasks:
                    TasksView(store: store)
                case .notes:
                    NotesView(store: store)
                case .calculator:
                    CalculatorView()
                }
            }
            .padding(.bottom, 96)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GlassFooter(tab: $tab)
                .padding(.horizontal, 22)
                .padding(.bottom, 10)
        }
    }

    private var tabBackground: Color {
        switch tab {
        case .tasks: Color(red: 0.93, green: 0.95, blue: 1)
        case .notes: Color(red: 1, green: 0.97, blue: 0.93)
        case .calculator: Color(red: 0.11, green: 0.12, blue: 0.16)
        }
    }
}

struct GlassFooter: View {
    @Binding var tab: AppTab

    var body: some View {
        HStack(spacing: 6) {
            footerButton("Задачи", systemImage: "checkmark.circle.fill", value: .tasks)
            footerButton("Заметки", systemImage: "note.text", value: .notes)
            footerButton("Калькулятор", systemImage: "plus.forwardslash.minus", value: .calculator)
        }
        .padding(8)
        .liquidGlass(in: Capsule())
    }

    private func footerButton(_ title: String, systemImage: String, value: AppTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                tab = value
            }
            Haptics.tap()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption2.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundStyle(tab == value ? AppTheme.indigo : .primary.opacity(0.6))
            .background {
                if tab == value {
                    Capsule()
                        .fill(.white.opacity(0.55))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
