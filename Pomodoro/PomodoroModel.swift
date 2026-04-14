import Foundation
import Combine
import SwiftUI

class PomodoroModel: ObservableObject {
    // MARK: - Published Properties
    @Published var focusTime: Int = 25 * 60
    @Published var shortBreakTime: Int = 5 * 60
    @Published var longBreakTime: Int = 15 * 60
    
    @Published var timeRemaining: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var isFocusSession: Bool = true
    @Published var focusSessionsCompleted: Int = 0
    @Published var showSettings: Bool = false
    @Published var shouldShowBreakWindow: Bool = false
    @Published var isInBreakMode: Bool = false
    @Published var cycleCompleted: Bool = false
    
    private var periodsInCurrentCycle: Int = 0
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    init() {
        loadSettings()
        timeRemaining = focusTime
    }
    
    deinit {
        timer?.cancel()
        timer = nil
    }
    
    // MARK: - Public Methods
    func startTimer() {
        if cycleCompleted {
            resetCycle()
        }
        guard !isRunning else { return }
        isRunning = true
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func resetTimer() {
        pauseTimer()
        timeRemaining = currentSessionDuration
    }
    
    func skipToNext() {
        let shouldResume = isRunning
        pauseTimer()
        advanceToNextSession()
        saveSettings()

        if shouldResume {
            startTimer()
        }
    }
    
    func completeCurrentSession() {
        advanceToNextSession()
        saveSettings()
    }
    
    private func resetCycle() {
        cycleCompleted = false
        periodsInCurrentCycle = 0
        focusSessionsCompleted = 0
        isFocusSession = true
        isInBreakMode = false
        shouldShowBreakWindow = false
        timeRemaining = focusTime
    }
    
    func dismissBreakWindow() {
        shouldShowBreakWindow = false
        isInBreakMode = false
    }
    
    // MARK: - Private Methods
    private func updateTimer() {
        timeRemaining -= 1

        if timeRemaining <= 0 {
            completeCurrentSession()
        }
    }
    
    private func advanceToNextSession() {
        if isFocusSession {
            periodsInCurrentCycle += 1
            isFocusSession = false
            isInBreakMode = true
            shouldShowBreakWindow = true
            timeRemaining = nextBreakDuration
            return
        }
        
        let finishedLongBreak = isLongBreakSession
        isInBreakMode = false
        shouldShowBreakWindow = false
        
        if finishedLongBreak {
            cycleCompleted = true
            isRunning = false
            timer?.cancel()
            timer = nil
            focusSessionsCompleted = 0
            periodsInCurrentCycle = 0
            return
        }
        
        periodsInCurrentCycle += 1
        isFocusSession = true
        focusSessionsCompleted += 1
        timeRemaining = focusTime
    }
    
    private func loadSettings() {
        if let savedFocusTime = userDefaults.object(forKey: "focusTime") as? Int {
            focusTime = savedFocusTime
        }
        if let savedShortBreakTime = userDefaults.object(forKey: "shortBreakTime") as? Int {
            shortBreakTime = savedShortBreakTime
        }
        if let savedLongBreakTime = userDefaults.object(forKey: "longBreakTime") as? Int {
            longBreakTime = savedLongBreakTime
        }
    }
    
    private func saveSettings() {
        userDefaults.set(focusTime, forKey: "focusTime")
        userDefaults.set(shortBreakTime, forKey: "shortBreakTime")
        userDefaults.set(longBreakTime, forKey: "longBreakTime")
    }
    
    // MARK: - Computed Properties
    var timeFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progress: Double {
        return 1.0 - Double(timeRemaining) / Double(currentSessionDuration)
    }
    
    var sessionTitle: String {
        if isFocusSession {
            return "Enfoque"
        } else {
            return isLongBreakSession ? "Descanso Largo" : "Descanso Corto"
        }
    }
    
    var sessionColor: Color {
        if isFocusSession {
            return .green
        } else {
            return isLongBreakSession ? .blue : .red
        }
    }
    
    private var currentSessionDuration: Int {
        isFocusSession ? focusTime : nextBreakDuration
    }
    
    private var nextBreakDuration: Int {
        focusSessionsCompleted % 4 == 3 ? longBreakTime : shortBreakTime
    }
    
    private var isLongBreakSession: Bool {
        !isFocusSession && focusSessionsCompleted % 4 == 3
    }
}
