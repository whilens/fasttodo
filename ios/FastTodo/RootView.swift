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
    @State private var innerWidth: CGFloat = 0
    @State private var fingerX: CGFloat?
    @State private var dragging = false

    private let inset: CGFloat = 6
    private let pillInset: CGFloat = 4

    private var selectedIndex: Int {
        AppTab.allCases.firstIndex(of: tab) ?? 0
    }

    private var itemWidth: CGFloat {
        innerWidth > 0 ? innerWidth / CGFloat(AppTab.allCases.count) : 0
    }

    private var pillWidth: CGFloat {
        max(0, itemWidth - pillInset * 2)
    }

    private var highlightX: CGFloat {
        if dragging, let fingerX, itemWidth > 0 {
            let center = min(max(fingerX, itemWidth / 2), innerWidth - itemWidth / 2)
            return center - pillWidth / 2
        }
        return CGFloat(selectedIndex) * itemWidth + pillInset
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if pillWidth > 0 {
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: pillWidth, height: 54)
                    .scaleEffect(dragging ? 1.06 : 1)
                    .offset(x: highlightX)
            }

            HStack(spacing: 0) {
                ForEach(AppTab.allCases) { item in
                    let active = item == tab || (dragging && tab(at: fingerX ?? 0) == item)
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
                    .scaleEffect(active ? 1.08 : 1)
                    .foregroundStyle(active ? AppTheme.indigo : AppTheme.ink.opacity(0.75))
                    .contentShape(Rectangle())
                }
            }
        }
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear { innerWidth = geo.size.width }
                    .onChange(of: geo.size.width) { _, width in
                        innerWidth = width
                    }
            }
        }
        .contentShape(Rectangle())
        .gesture(tabGesture)
        .padding(inset)
        .liquidGlass(in: Capsule())
        .animation(dragging ? nil : .spring(response: 0.36, dampingFraction: 0.8), value: highlightX)
        .animation(.spring(response: 0.28, dampingFraction: 0.78), value: tab)
    }

    private var tabGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard innerWidth > 0 else { return }
                let moved = hypot(value.translation.width, value.translation.height) > 10
                if moved {
                    dragging = true
                    fingerX = value.location.x
                    let next = tab(at: value.location.x)
                    if next != tab {
                        tab = next
                        Haptics.selection()
                    }
                }
            }
            .onEnded { value in
                tab = tab(at: value.location.x)
                let wasDragging = dragging
                dragging = false
                fingerX = nil
                if !wasDragging {
                    Haptics.tap()
                }
            }
    }

    private func tab(at x: CGFloat) -> AppTab {
        guard innerWidth > 0 else { return tab }
        let clamped = min(max(x, 0), innerWidth - 1)
        let index = Int(clamped / itemWidth)
        return AppTab.allCases[min(max(index, 0), AppTab.allCases.count - 1)]
    }
}
