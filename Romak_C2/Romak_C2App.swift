//
//  Romak_C2App.swift
//  Romak_C2
//
//  Created by 준호 on 4/13/25.
//

import SwiftUI
import SwiftData

// Romak_C2App.swift
@main
struct Romak_C2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Question.self)
    }
}
