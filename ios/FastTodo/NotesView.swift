import SwiftUI

struct NotesView: View {
    var store: AppStore
    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Заметки")
                .font(.largeTitle.bold())
                .padding(.horizontal, 20)
                .padding(.top, 16)

            HStack(spacing: 8) {
                TextField("Короткая заметка", text: $text, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...3)

                Button("Сохранить") {
                    let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !value.isEmpty else { return }
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        store.addNote(value)
                    }
                    text = ""
                    Haptics.add()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding(.horizontal, 20)

            if store.notes.isEmpty {
                Text("Заметок пока нет")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
            }

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(store.notes) { note in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(note.text)
                            HStack {
                                Text(note.createdAt, format: .dateTime.hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Button("Удалить") {
                                    withAnimation(.easeInOut) { store.deleteNote(note) }
                                    Haptics.delete()
                                }
                                .font(.caption)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                        .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.96)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
