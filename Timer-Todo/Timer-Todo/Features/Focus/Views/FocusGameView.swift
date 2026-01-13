import SwiftUI

struct FocusGameView: View {
    
    @ObservedObject var viewModel: FocusViewModel
    @State private var scale: CGFloat = 1.0
    
    private var remainingSeconds: Int {
        guard case .loaded(let s) = viewModel.viewState else { return 0 }
        return s.remainingSeconds
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Перерыв! Собирай энергию времени")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 280, height: 280)
                
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .scaleEffect(scale)
                    .frame(width: 240, height: 240)
                    .animation(.easeOut(duration: 0.2), value: scale)
                
                VStack {
                    Text("🔥")
                        .font(.system(size: 120))
                    
                    Text("\(viewModel.gameState.score)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
            }
            .gesture(
                TapGesture()
                    .onEnded {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            scale = 1.3
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            scale = 1.0
                        }
                        viewModel.addScore()
                    }
            )
            
            Text("Осталось времени: \(timeString(remainingSeconds))")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Button("Завершить перерыв") {
                viewModel.endGame()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private func timeString(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
    
}
