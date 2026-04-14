//
//  ContentView.swift
//  Pomodoro
//
//  Created by Francisco Zapata on 14/4/26.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var pomodoroModel = PomodoroModel()
    @State private var originalWindowFrame: NSRect?
    
    var body: some View {
        ZStack {
            VStack {
                Text(pomodoroModel.sessionTitle)
                    .font(.title)
                    .foregroundColor(pomodoroModel.sessionColor)
                    .padding()

                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(pomodoroModel.sessionColor)

                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(pomodoroModel.progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(pomodoroModel.sessionColor)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: pomodoroModel.progress)

                    Text(pomodoroModel.timeFormatted)
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(timerColor)
                }
                .frame(width: 250, height: 250)
                .padding()

                HStack(spacing: 30) {
                    Button(action: {
                        if pomodoroModel.isRunning {
                            pomodoroModel.pauseTimer()
                        } else {
                            pomodoroModel.startTimer()
                        }
                    }) {
                        Image(systemName: pomodoroModel.isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(pomodoroModel.sessionColor)
                    }

                    Button(action: {
                        pomodoroModel.skipToNext()
                    }) {
                        Image(systemName: "forward.end.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(pomodoroModel.sessionColor)
                    }
                }
                .padding()

                Button(action: {
                    pomodoroModel.showSettings = true
                }) {
                    Label("Ajustes", systemImage: "gear")
                        .font(.title2)
                }
                .padding()
                .sheet(isPresented: $pomodoroModel.showSettings) {
                    SettingsView(pomodoroModel: pomodoroModel)
                }
            }
            .padding()
            .onChange(of: pomodoroModel.isInBreakMode) { _, isInBreak in
                print("Break mode changed: \(isInBreak)")
                if isInBreak {
                    activateBreakMode()
                } else {
                    deactivateBreakMode()
                }
            }
        }
    }
    
    private var timerColor: Color {
        if pomodoroModel.isInBreakMode {
            return pomodoroModel.sessionColor
        }
        return pomodoroModel.sessionColor
    }
    
    private func activateBreakMode() {
        DispatchQueue.main.async {
            print("Activating break mode...")
            guard let window = NSApp.windows.first else { 
                print("No windows found")
                return 
            }
            
            print("Found window: \(window.frame)")
            if self.originalWindowFrame == nil {
                self.originalWindowFrame = window.frame
            }
            
            if let screen = NSScreen.main {
                window.setFrame(screen.frame, display: true)
                window.level = .screenSaver
                window.backgroundColor = NSColor.black.withAlphaComponent(0.5)
                window.isOpaque = false
                window.hasShadow = false
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.makeKeyAndOrderFront(nil)
                
                NSApp.activate(ignoringOtherApps: true)
                print("Window activated for break mode")
            }
        }
    }
    
    private func deactivateBreakMode() {
        DispatchQueue.main.async {
            print("Deactivating break mode...")
            guard let window = NSApp.windows.first else { return }
            
            if let originalFrame = self.originalWindowFrame {
                window.setFrame(originalFrame, display: true)
            }
            window.level = .normal
            window.backgroundColor = .windowBackgroundColor
            window.isOpaque = true
            window.hasShadow = true
            window.collectionBehavior = [.fullScreenAuxiliary]
            
            window.miniaturize(nil)
            print("Window minimized to background")
        }
    }
}