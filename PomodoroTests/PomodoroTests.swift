//
//  PomodoroTests.swift
//  PomodoroTests
//
//  Created by Francisco Zapata on 14/4/26.
//

import Testing
@testable import Pomodoro

struct PomodoroTests {

    @Test func completesFullPomodoroCycleInOrder() {
        let model = PomodoroModel()
        model.focusTime = 25
        model.shortBreakTime = 5
        model.longBreakTime = 15
        model.timeRemaining = model.focusTime

        let expectedSequence = [
            ("Descanso Corto", 5, false, 0),
            ("Enfoque", 25, true, 1),
            ("Descanso Corto", 5, false, 1),
            ("Enfoque", 25, true, 2),
            ("Descanso Corto", 5, false, 2),
            ("Enfoque", 25, true, 3),
            ("Descanso Largo", 15, false, 3),
            ("Enfoque", 25, true, 0),
        ]

        for expected in expectedSequence {
            model.completeCurrentSession()

            #expect(model.sessionTitle == expected.0)
            #expect(model.timeRemaining == expected.1)
            #expect(model.isFocusSession == expected.2)
            #expect(model.focusSessionsCompleted == expected.3)
        }
    }

    @Test func manualSkipKeepsTimerRunningWhenAlreadyRunning() {
        let model = PomodoroModel()
        model.isRunning = true

        model.skipToNext()

        #expect(model.isRunning)
        model.pauseTimer()
    }

}
