import SwiftUI

struct FocusView: View {
    
    @StateObject private var viewModel = FocusViewModel()
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Focus")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            LoadingView()
            
        case .loaded(let state):
            FocusMainContentView(state: state, viewModel: viewModel)
            
        case .idle:
            Text("Загрузка...")
            
        case .error:
            if let error = viewModel.error {
                ErrorView(error: error) {
                    viewModel.startSession()
                }
            }
        }
    }
}

private struct FocusMainContentView: View {
    
    let state: FocusState
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        if viewModel.isInGame {
            FocusGameView(viewModel: viewModel)
                .transition(.opacity)
        } else {
            VStack(spacing: 40) {
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .foregroundStyle(.gray.opacity(0.2))
                        .frame(width: 280, height: 280)
                    
                    Circle()
                        .trim(from: 0, to: progress(for: state))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .foregroundStyle(state.phase == .work ? Color.blue : Color.green)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 280, height: 280)
                    
                    VStack(spacing: 8) {
                        Text(timeString(state.remainingSeconds))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        
                        Text(state.phase.title)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        
                        Text("Цикл \(state.currentCycle) • Сегодня: \(state.totalCyclesToday)")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                HStack(spacing: 24) {
                    Button("Сброс") {
                        viewModel.resetSession()
                    }
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Button(buttonTitle(for: state)) {
                        viewModel.pauseOrResume()
                    }
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(state.phase == .work ? Color.orange : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                
                if state.phase == .shortBreak || state.phase == .longBreak {
                    Button {
                        viewModel.startBreakGame()
                    } label: {
                        HStack {
                            Text("Играть в перерыве!")
                                .font(.title3.bold())
                            Image(systemName: "gamecontroller.fill")
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .purple.opacity(0.4), radius: 10)
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .transition(.opacity)
        }
    }
    
    private func progress(for state: FocusState) -> Double {
        guard state.phase.durationSeconds > 0 else { return 0 }
        return Double(state.remainingSeconds) / Double(state.phase.durationSeconds)
    }
    
    private func timeString(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
    
    private func buttonTitle(for state: FocusState) -> String {
        switch state.phase {
        case .idle: return "Начать фокус"
        case .work: return "Пауза"
        case .shortBreak, .longBreak: return "Продолжить"
        }
    }
    
}
