import SwiftUI

struct MotivationView: View {
    
    @StateObject private var viewModel = MotivationViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    Spacer(minLength: 60)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(.orange)
                            .symbolEffect(.pulse)
                        
                        Text(viewModel.currentQuote)
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(
                        LinearGradient(
                            colors: [.orange.opacity(0.2), .red.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .orange.opacity(0.3), radius: 10)
                    .padding(.horizontal, 12)
                    
                    VStack(spacing: 12) {
                        Text("Ты сегодня уже сделал шаг вперёд")
                            .font(.title3.bold())
                            .foregroundStyle(.secondary)
                        
                        Text("Продолжай — результат ближе, чем кажется")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 12)
                    
                    Button {
                        viewModel.loadRandomQuote()
                    } label: {
                        Text("Новая цитата")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.vertical, 40)
            }
            .navigationTitle("Motivation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}

#Preview {
    MotivationView()
}
