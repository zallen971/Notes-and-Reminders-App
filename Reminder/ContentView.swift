import SwiftUI
import Foundation
import UserNotifications

// MARK: - Models
struct Note: Identifiable, Codable, Equatable, Hashable  {
    var id = UUID()
    var content: String
}

struct Reminder: Identifiable, Codable {
    var id = UUID()
    var content: String
    var date: Date
}

// MARK: - DataManager
class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Save notes to file
    func saveNotes(notes: [Note]) {
        let fileURL = getDocumentsDirectory().appendingPathComponent("notes.json")
        
        if let encoded = try? JSONEncoder().encode(notes) {
            do {
                try encoded.write(to: fileURL)
            } catch {
                print("Error saving notes: \(error.localizedDescription)")
            }
        }
    }
    
    // Load notes from file
    func loadNotes() -> [Note] {
        let fileURL = getDocumentsDirectory().appendingPathComponent("notes.json")
        
        if let data = try? Data(contentsOf: fileURL),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: data) {
            return decodedNotes
        }
        
        return [] // Return an empty array if no data exists
    }
    
    // Save reminders to file
    func saveReminders(reminders: [Reminder]) {
        let fileURL = getDocumentsDirectory().appendingPathComponent("reminders.json")
        
        if let encoded = try? JSONEncoder().encode(reminders) {
            do {
                try encoded.write(to: fileURL)
            } catch {
                print("Error saving reminders: \(error.localizedDescription)")
            }
        }
    }
    
    // Load reminders from file
    func loadReminders() -> [Reminder] {
        let fileURL = getDocumentsDirectory().appendingPathComponent("reminders.json")
        
        if let data = try? Data(contentsOf: fileURL),
           let decodedReminders = try? JSONDecoder().decode([Reminder].self, from: data) {
            return decodedReminders
        }
        
        return [] // Return an empty array if no data exists
    }
}



// MARK: - ContentView
struct ContentView: View {
    @State private var isEditingNote: Bool = false
    
    var body: some View {
        ZStack {
            TabView {
                // Notes Section
                NavigationView {
                    NotesView(isEditingNote: $isEditingNote)
                }
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                
                // Reminders Section
                NavigationView {
                    RemindersView()
                }
                .tabItem {
                    Label("Reminders", systemImage: "alarm")
                }
            }
            .opacity(isEditingNote ? 0 : 1)
            
            if isEditingNote {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}


// MARK: - NotesView
struct NotesView: View {
    @Binding var isEditingNote: Bool // bind to ContentView's state
    @State private var notes: [Note] = []
    @State private var newNoteContent: String = ""
    @State private var newNote: Note = Note(content: "")
    @State private var isCreatingNewNote: Bool = false
    
    var body: some View {
        NavigationStack {  // Wrap the entire view in NavigationStack
            VStack {
                Button(action: {
                    newNoteContent = ""
                    isCreatingNewNote = true
                }) {
                    Text("Add a new note...")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
                
                List {
                    ForEach(notes) { note in
                        NavigationLink(destination: EditNoteView(note: $notes[notes.firstIndex(where: { $0.id == note.id })!], onSave: saveEditedNote)) {
                            Text(note.content.split(separator: "\n").first?.description ?? "")
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .onDelete(perform: deleteNote)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Notes")
            .sheet(isPresented: $isCreatingNewNote) {
                VStack {
                    Text("Create a new note")
                        .font(.headline)
                        .padding()
                    
                    TextEditor(text: $newNoteContent)
                        .frame(minHeight: 200)
                        .padding()
                    
                    Button("Save") {
                        // save the new note
                        if !newNoteContent.isEmpty {
                            let newNote = Note(content: newNoteContent)
                            notes.append(newNote)
                            saveNotes()
                        }
                        isCreatingNewNote = false // dismiss the sheet
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .onAppear(perform: loadNotes)
        }
    }
    
    private func saveNotes() {
        DataManager.shared.saveNotes(notes: notes)
    }
    
    private func saveEditedNote(updatedNote: Note) {
        if let index = notes.firstIndex(where: {$0.id == updatedNote.id}) {
            notes[index] = updatedNote
            saveNotes() // Save the updated notes list
        }
    }
    
    private func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        DataManager.shared.saveNotes(notes: notes) // Save after delete
    }
    
    private func loadNotes() {
        notes = DataManager.shared.loadNotes()
    }
}




// MARK: - Edit Note View
struct EditNoteView: View {
    @Binding var note: Note
    var onSave: ((Note) -> Void)? // callback for saving a new note
    @Environment(\.presentationMode) var presentationMode // to dismiss the view when the editing is done
    
    var body: some View {
        VStack {
            // wrap the TextField in a scroll view to make it the whole screen
            ScrollView {
                TextEditor(text: $note.content)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .frame(minHeight: 200, alignment: .leading) // ensures text field takes the whole screen
            }
            
            Button(action: {
                if let onSave = onSave {
                    onSave(note) // pass the updated note to the callback
                }
                presentationMode.wrappedValue.dismiss() // dismiss the view after saving
            }) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top)
        }
        .navigationTitle("Edit Note")
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - RemindersView
struct RemindersView: View {
    @State private var reminders: [Reminder] = []
    @State private var newReminderContent: String = ""
    @State private var reminderDate: Date = Date()
    @State private var isDatePickerVisible: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter a reminder", text: $newReminderContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    if !newReminderContent.isEmpty {
                        isDatePickerVisible = true
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            
            if isDatePickerVisible {
                DatePicker(
                    "Set Reminder Time",
                    selection: $reminderDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .padding()
                
                Button(action: {
                    addReminder()
                    isDatePickerVisible = false
                }) {
                    Text("Set Reminder")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            List {
                ForEach(reminders) { reminder in
                    VStack(alignment: .leading) {
                        Text(reminder.content)
                            .font(.headline)
                        Text("Reminder set for: \(formattedDate(reminder.date))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: deleteReminder)
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Reminders")
        .onAppear {
            requestNotificationPermissions()
            loadReminders()
        }
    }
    
    private func showDatePicker() {
        if !newReminderContent.isEmpty {
            isDatePickerVisible = true
        }
    }
    
    private func addReminder() {
        guard !newReminderContent.isEmpty else { return }
        let newReminder = Reminder(content: newReminderContent, date: reminderDate)
        reminders.append(newReminder)
        DataManager.shared.saveReminders(reminders: reminders) // Save to file
        
        // schedule the notification
        scheduleReminder(for: newReminder)
        
        
        newReminderContent = ""
        
        
    }
    
    private func deleteReminder(at offsets: IndexSet) {
        reminders.remove(atOffsets: offsets)
        DataManager.shared.saveReminders(reminders: reminders) // Save after delete
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else if granted {
                print("Notification permissions granted")
            } else {
                print("Notification permissions denied")
            }
        }
    }
    
    private func scheduleReminder(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = reminder.content
        content.sound = .default
        
        // use an instance of calendar to call dateComponents
        let calendar = Calendar.current
        let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDateComponents,
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error setting the reminder: \(error.localizedDescription)")
            } else {
                print("The reminder has been successfully set")
            }
        }
    }
    
    private func loadReminders() {
        reminders = DataManager.shared.loadReminders()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - App Entry Point
@main
struct NoteTakingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
