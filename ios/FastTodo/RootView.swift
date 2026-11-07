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
    @State private var openedTodo: TodoItem?
    @State private var openedNote: NoteItem?

    private var showsFooter: Bool {
        openedTodo == nil && openedNote == nil
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            tabBackground
                .ignoresSafeArea()

            Group {
                switch tab {
                case .tasks:
                    TasksView(store: store, opened: $openedTodo)
                case .notes:
                    NotesView(store: store, opened: $openedNote)
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
    @State private var fingerX: CGFloat?

    private var selectedIndex: Int {
        AppTab.allCases.firstIndex(of: tab) ?? 0
    }

    private var itemWidth: CGFloat {
        barWidth > 0 ? barWidth / CGFloat(AppTab.allCases.count) : 0
    }

    private var highlightCenter: CGFloat {
        if let fingerX, itemWidth > 0 {
            return min(max(fingerX, itemWidth / 2), barWidth - itemWidth / 2)
        }
        return itemWidth * (CGFloat(selectedIndex) + 0.5)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if itemWidth > 0 {
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: itemWidth - 8, height: 54)
                    .scaleEffect(fingerX == nil ? 1 : 1.08)
                    .offset(x: highlightCenter - (itemWidth - 8) / 2)
            }

            HStack(spacing: 0) {
                ForEach(AppTab.allCases) { item in
                    let active = abs(highlightCenter - center(of: item)) < itemWidth / 2
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
                    .scaleEffect(active ? 1.1 : 1)
                    .foregroundStyle(active ? AppTheme.indigo : AppTheme.ink.opacity(0.75))
                    .contentShape(Rectangle())
                    .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.8), value: active)
                }
            }
        }
        .padding(6)
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
        .animation(fingerX == nil ? .spring(response: 0.38, dampingFraction: 0.78) : nil, value: highlightCenter)
    }

    private func center(of item: AppTab) -> CGFloat {
        guard let index = AppTab.allCases.firstIndex(of: item) else { return 0 }
        return itemWidth * (CGFloat(index) + 0.5)
    }

    private var telegramDrag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard barWidth > 0 else { return }
                fingerX = value.location.x
                let next = tab(at: value.location.x)
                if next != tab {
                    tab = next
                    Haptics.selection()
                }
            }
            .onEnded { value in
                tab = tab(at: value.location.x)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.76)) {
                    fingerX = nil
                }
            }
    }

    private func tab(at x: CGFloat) -> AppTab {
        guard barWidth > 0 else { return tab }
        let clamped = min(max(x, 0), barWidth - 1)
        let index = Int(clamped / itemWidth)
        return AppTab.allCases[min(max(index, 0), AppTab.allCases.count - 1)]
    }
}
