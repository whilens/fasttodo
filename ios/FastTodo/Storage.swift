import Foundation

struct TodoItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}

struct NoteItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var text: String
    var createdAt: Date

    init(id: UUID = UUID(), text: String, createdAt: Date = .now) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

@Observable
final class AppStore {
    private let todosKey = "fasttodo.todos"
    private let notesKey = "fasttodo.notes"

    var todos: [TodoItem] = []
    var notes: [NoteItem] = []

    init() {
        todos = Self.load(todosKey)
        notes = Self.load(notesKey)
    }

    func addTodo(_ title: String) {
        let value = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        todos.insert(TodoItem(title: value), at: 0)
        saveTodos()
    }

    func deleteTodo(_ item: TodoItem) {
        todos.removeAll { $0.id == item.id }
        saveTodos()
    }

    func addNote(_ text: String) {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        notes.insert(NoteItem(text: value), at: 0)
        saveNotes()
    }

    func deleteNote(_ item: NoteItem) {
        notes.removeAll { $0.id == item.id }
        saveNotes()
    }

    func updateTodo(_ item: TodoItem, title: String) {
        let value = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, let index = todos.firstIndex(where: { $0.id == item.id }) else { return }
        todos[index].title = value
        saveTodos()
    }

    func updateNote(_ item: NoteItem, text: String) {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, let index = notes.firstIndex(where: { $0.id == item.id }) else { return }
        notes[index].text = value
        saveNotes()
    }

    func todo(id: UUID) -> TodoItem? {
        todos.first { $0.id == id }
    }

    func note(id: UUID) -> NoteItem? {
        notes.first { $0.id == id }
    }

    private func saveTodos() { Self.save(todos, key: todosKey) }
    private func saveNotes() { Self.save(notes, key: notesKey) }

    private static func load<T: Decodable>(_ key: String) -> [T] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([T].self, from: data)) ?? []
    }

    private static func save<T: Encodable>(_ value: [T], key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
