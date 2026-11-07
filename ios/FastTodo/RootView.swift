import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case tasks
    case notes
    case calculator

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tasks: "Задачи"
        case .notes: "Заметки"
        case .calculator: "Калькулятор"
        }
    }

    var icon: String {
        switch self {
        case .tasks: "checkmark.circle.fill"
        case .notes: "note.text"
        case .calculator: "plus.forwardslash.minus"
        }
    }
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
    @State private var taskPath: [TodoItem] = []
    @State private var notePath: [NoteItem] = []

    private var showsFooter: Bool {
        taskPath.isEmpty && notePath.isEmpty
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            tabBackground
                .ignoresSafeArea()

            Group {
                switch tab {
                case .tasks:
                    TasksView(store: store, path: $taskPath)
                case .notes:
                    NotesView(store: store, path: $notePath)
                case .calculator:
                    CalculatorView()
                }
            }

            GlassFooter(tab: $tab)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .opacity(showsFooter ? 1 : 0)
                .offset(y: showsFooter ? 0 : 30)
                .allowsHitTesting(showsFooter)
                .animation(.spring(response: 0.35, dampingFraction: 0.86), value: showsFooter)
        }
    }

    private var tabBackground: Color {
        switch tab {
        case .tasks: Color(red: 0.82, green: 0.87, blue: 1)
        case .notes: Color(red: 1, green: 0.90, blue: 0.78)
        case .calculator: Color(red: 0.16, green: 0.18, blue: 0.26)
        }
    }
}

struct GlassFooter: View {
    @Binding var tab: AppTab
    @State private var barWidth: CGFloat = 0
    @State private var isDragging = false

    private var selectedIndex: Int {
        AppTab.allCases.firstIndex(of: tab) ?? 0
    }

    var body: some View {
        let tabs = AppTab.allCases

        HStack(spacing: 0) {
            ForEach(tabs) { item in
                VStack(spacing: 4) {
                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: .semibold))
                    Text(item.title)
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .foregroundStyle(tab == item ? AppTheme.indigo : AppTheme.ink.opacity(0.72))
                .contentShape(Rectangle())
            }
        }
        .padding(6)
        .background(alignment: .leading) {
            if barWidth > 0 {
                Capsule()
                    .fill(.white.opacity(0.28))
                    .frame(width: itemWidth(in: barWidth) - 4, height: 52)
                    .offset(x: CGFloat(selectedIndex) * itemWidth(in: barWidth) + 2)
                    .animation(isDragging ? .interactiveSpring(response: 0.22, dampingFraction: 0.86) : .spring(response: 0.38, dampingFraction: 0.78), value: tab)
            }
        }
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear { barWidth = geo.size.width }
                    .onChange(of: geo.size.width) { _, width in
                        barWidth = width
                    }
            }
        }
        .contentShape(Capsule())
        .gesture(telegramDrag)
        .liquidGlass(in: Capsule())
    }

    private var telegramDrag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDragging = true
                guard barWidth > 0 else { return }
                let next = tab(at: value.location.x, width: barWidth)
                if next != tab {
                    tab = next
                    Haptics.selection()
                }
            }
            .onEnded { value in
                if barWidth > 0 {
                    tab = tab(at: value.location.x, width: barWidth)
                }
                isDragging = false
            }
    }

    private func itemWidth(in total: CGFloat) -> CGFloat {
        total / CGFloat(AppTab.allCases.count)
    }

    private func tab(at x: CGFloat, width: CGFloat) -> AppTab {
        let clamped = min(max(x, 0), width - 1)
        let index = Int(clamped / itemWidth(in: width))
        return AppTab.allCases[min(max(index, 0), AppTab.allCases.count - 1)]
    }
}
