import SwiftUI

struct TaskDetailView: View {
    var store: AppStore
    let item: TodoItem
    @Environment(\.dismiss) private var dismiss
    @State private var title: String

    init(store: AppStore, item: TodoItem) {
        self.store = store
        self.item = item
        _title = State(initialValue: item.title)
    }

    var body: some View {
        InteractivePop {
            VStack(alignment: .leading, spacing: 16) {
                BackHeader(title: "Задача") { dismiss() }

                Text("Текст")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.inkMuted)

                TextField("Текст задачи", text: $title, axis: .vertical)
                    .lineLimit(3...8)
                    .padding(14)
                    .foregroundStyle(AppTheme.ink)
                    .background(Color(red: 0.96, green: 0.97, blue: 0.99), in: RoundedRectangle(cornerRadius: 16))

                Button("Сохранить") {
                    store.updateTodo(item, title: title)
                    Haptics.add()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.indigo)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AppTheme.card.ignoresSafeArea())
        }
        .navigationBarHidden(true)
    }
}

struct NoteDetailView: View {
    var store: AppStore
    let item: NoteItem
    @Environment(\.dismiss) private var dismiss
    @State private var text: String

    init(store: AppStore, item: NoteItem) {
        self.store = store
        self.item = item
        _text = State(initialValue: item.text)
    }

    var body: some View {
        InteractivePop {
            VStack(alignment: .leading, spacing: 16) {
                BackHeader(title: "Заметка") { dismiss() }

                Text(item.createdAt, format: .dateTime.day().month().hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.inkMuted)

                TextField("Текст заметки", text: $text, axis: .vertical)
                    .lineLimit(6...16)
                    .padding(14)
                    .foregroundStyle(AppTheme.ink)
                    .background(Color(red: 1, green: 0.97, blue: 0.93), in: RoundedRectangle(cornerRadius: 16))

                Button("Сохранить") {
                    store.updateNote(item, text: text)
                    Haptics.add()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(AppTheme.card.ignoresSafeArea())
        }
        .navigationBarHidden(true)
    }
}
