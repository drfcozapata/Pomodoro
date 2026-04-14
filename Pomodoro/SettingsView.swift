import SwiftUI

struct SettingsView: View {
    @ObservedObject var pomodoroModel: PomodoroModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var focusTime: String
    @State private var shortBreakTime: String
    @State private var longBreakTime: String
    
    init(pomodoroModel: PomodoroModel) {
        self.pomodoroModel = pomodoroModel
        _focusTime = State(initialValue: String(pomodoroModel.focusTime / 60))
        _shortBreakTime = State(initialValue: String(pomodoroModel.shortBreakTime / 60))
        _longBreakTime = State(initialValue: String(pomodoroModel.longBreakTime / 60))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ajustes del Pomodoro")
                .font(.title)
                .padding()
            
            Form {
                Section(header: Text("Tiempo de Enfoque (minutos)")) {
                    TextField("Minutos", text: $focusTime)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section(header: Text("Descanso Corto (minutos)")) {
                    TextField("Minutos", text: $shortBreakTime)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section(header: Text("Descanso Largo (minutos)")) {
                    TextField("Minutos", text: $longBreakTime)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .formStyle(.grouped)
            .frame(maxWidth: 400)
            
            Button(action: {
                if let focusMinutes = Int(focusTime), focusMinutes > 0 {
                    pomodoroModel.focusTime = focusMinutes * 60
                }
                if let shortBreakMinutes = Int(shortBreakTime), shortBreakMinutes > 0 {
                    pomodoroModel.shortBreakTime = shortBreakMinutes * 60
                }
                if let longBreakMinutes = Int(longBreakTime), longBreakMinutes > 0 {
                    pomodoroModel.longBreakTime = longBreakMinutes * 60
                }
                
                pomodoroModel.resetTimer()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Guardar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .buttonStyle(.plain)
        }
        .padding()
        .frame(width: 400, height: 400)
    }
}