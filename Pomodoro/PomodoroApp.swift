//
//  PomodoroApp.swift
//  Pomodoro
//
//  Created by Francisco Zapata on 14/4/26.
//

import SwiftUI

@main
struct PomodoroApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                NSApp.terminate(nil)
            }
        }
    }
}