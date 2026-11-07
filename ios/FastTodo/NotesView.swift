import SwiftUI

struct NotesView: View {
    var store: AppStore
    @Binding var path: [NoteItem]
    @State private var text = ""

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Заметки")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.ink)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                HStack(spacing: 8) {
                    TextField("Короткая заметка", text: $text, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .foregroundStyle(AppTheme.ink)
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
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 20)

                if store.notes.isEmpty {
                    Text("Заметок пока нет")
                        .foregroundStyle(AppTheme.inkMuted)
                        .padding(.horizontal, 20)
                }

                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(store.notes) { note in
                            Button {
                                path.append(note)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(note.text)
                                        .foregroundStyle(AppTheme.ink)
                                        .multilineTextAlignment(.leading)
                                    Text(note.createdAt, format: .dateTime.hour().minute())
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.inkMuted)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                            }
                            .buttonStyle(.plain)
                            .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.96)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 110)
                }
            }
            .background(Color(red: 1, green: 0.90, blue: 0.78).ignoresSafeArea())
            .navigationDestination(for: NoteItem.self) { item in
                NoteDetailView(store: store, item: store.note(id: item.id) ?? item)
            }
        }
    }
}
