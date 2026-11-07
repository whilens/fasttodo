import SwiftUI

struct TasksView: View {
    var store: AppStore
    @State private var text = ""
    @State private var bounceAdd = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Задачи")
                .font(.largeTitle.bold())
                .padding(.horizontal, 20)
                .padding(.top, 16)

            HStack(spacing: 8) {
                TextField("Новая задача", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onSubmit(add)

                Button("Добавить") { add() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.indigo)
                    .scaleEffect(bounceAdd ? 0.86 : 1)
            }
            .padding(.horizontal, 20)

            if store.todos.isEmpty {
                Text("Пока нет задач")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .transition(.opacity)
            }

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Array(store.todos.enumerated()), id: \.element.id) { index, item in
                        TaskRow(item: item, index: index) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                store.deleteTodo(item)
                            }
                            Haptics.delete()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }

    private func add() {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
            store.addTodo(value)
            bounceAdd = true
        }
        text = ""
        Haptics.add()
        Task {
            try? await Task.sleep(for: .milliseconds(90))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.45)) {
                bounceAdd = false
            }
        }
    }
}

private struct TaskRow: View {
    let item: TodoItem
    let index: Int
    let onDelete: () -> Void
    @State private var shown = false

    var body: some View {
        HStack {
            Text(item.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Удалить", action: onDelete)
                .buttonStyle(.bordered)
        }
        .padding(14)
        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        .offset(x: shown ? 0 : 48)
        .opacity(shown ? 1 : 0)
        .scaleEffect(shown ? 1 : 0.92)
        .task {
            try? await Task.sleep(for: .milliseconds(min(index, 8) * 45))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                shown = true
            }
        }
    }
}
