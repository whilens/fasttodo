import SwiftUI

struct TasksView: View {
    var store: AppStore
    @Binding var opened: TodoItem?
    @State private var text = ""
    @State private var bounceAdd = false

    var body: some View {
        CoverHost(isPresented: opened != nil, onClose: { opened = nil }) {
            taskList
        } detail: {
            if let item = opened {
                TaskDetailView(store: store, item: store.todo(id: item.id) ?? item)
            }
        }
    }

    private var taskList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Задачи")
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.ink)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            HStack(spacing: 8) {
                TextField("Новая задача", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(AppTheme.ink)
                    .submitLabel(.done)
                    .onSubmit(add)

                Button("Добавить") { add() }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.indigo)
                    .foregroundStyle(.white)
                    .scaleEffect(bounceAdd ? 0.86 : 1)
            }
            .padding(.horizontal, 20)

            if store.todos.isEmpty {
                Text("Пока нет задач")
                    .foregroundStyle(AppTheme.inkMuted)
                    .padding(.horizontal, 20)
                    .transition(.opacity)
            }

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Array(store.todos.enumerated()), id: \.element.id) { index, item in
                        TaskRow(item: item, index: index, onOpen: {
                            opened = item
                        }, onDelete: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                store.deleteTodo(item)
                            }
                            Haptics.delete()
                        })
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
        .background(Color(red: 0.82, green: 0.87, blue: 1).ignoresSafeArea())
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
    let onOpen: () -> Void
    let onDelete: () -> Void
    @State private var shown = false

    var body: some View {
        HStack {
            Button(action: onOpen) {
                Text(item.title)
                    .foregroundStyle(AppTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button("Удалить", action: onDelete)
                .buttonStyle(.bordered)
                .foregroundStyle(AppTheme.ink)
        }
        .padding(14)
        .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
