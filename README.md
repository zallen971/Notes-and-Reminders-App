# NoteTakingApp

A simple note-taking and reminder app built with SwiftUI. This app allows users to create, edit, and delete notes, as well as set reminders with notifications.

## Features

- **Notes:**
  - Create, edit, and delete notes.
  - View notes in a list format.
  - Persistent storage of notes using JSON encoding/decoding.
  
- **Reminders:**
  - Add reminders with custom content and time.
  - Set up local notifications to remind the user at the specified time.
  - Persistent storage of reminders using JSON encoding/decoding.
  
- **Data Persistence:**
  - Notes and reminders are stored locally in the device's document directory.

## Technologies Used

- **SwiftUI**: For building the user interface.
- **UserNotifications**: For scheduling and managing reminders with local notifications.
- **JSON**: For saving notes and reminders in the document directory.
- **FileManager**: For file handling in the local document directory.

## Requirements

- iOS 14.0 or later
- Xcode 12 or later

## Setup and Installation

1. Clone this repository to your local machine.

   ```bash
   git clone https://github.com/yourusername/NoteTakingApp.git
2. Open the project in Xcode.

3. Build and run the app on a simulator or a physical device.

4. Grant notification permissions when prompted.

## Usage
Notes Section:
To create a new note, tap the "Add a new note..." button, enter your note content, and save it.
To edit a note, tap on a note from the list, make your changes, and save.
To delete a note, swipe left on the note and tap "Delete."
Reminders Section:
To create a reminder, enter the reminder content and choose a date and time.
Once a reminder is set, a notification will appear at the scheduled time.
Handling Notifications
The app requests notification permissions from the user on launch.
If permissions are granted, reminders will trigger notifications at the specified times.
File Structure
bash

NoteTakingApp/
├── ContentView.swift      --- Main view containing the TabView

├── Models.swift           --- Data models for Notes and Reminders

├── DataManager.swift      --- Singleton for handling data persistence

├── NotesView.swift        --- View for managing and displaying notes

├── RemindersView.swift    --- View for managing and displaying reminders

├── EditNoteView.swift     --- View for editing individual notes

├── App.swift              --- Main entry point of the app

├── Assets/                --- App assets (images, icons)

└── Info.plist             --- App configuration



## Future Improvements
Support for syncing data with cloud storage.
Enhanced UI/UX improvements such as themes or better navigation.
Add the ability to mark reminders as completed.
License
This project is open source and available under the MIT License.

## Acknowledgements
SwiftUI documentation
Apple Developer resources for UserNotifications
