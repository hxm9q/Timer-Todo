import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle:
            Text("Добро пожаловать!")
                .font(.title2)
            
        case .loading:
            LoadingView()
            
        case .loaded(let overview):
            mainContent(overview)
            
        case .error:
            if let error = viewModel.error {
                ErrorView(error: error) {
                    Task { await viewModel.loadData() }
                }
            }
        }
    }
    
    private func mainContent(_ overview: HomeOverview) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                pomodoroCard(overview.pomodoro)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Задачи на сегодня")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(overview.tasks) { task in
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                                .font(.title2)
                                .onTapGesture {
                                    Task { await viewModel.toggleTaskCompletion(task) }
                                }
                            
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                                .foregroundColor(task.isCompleted ? .secondary : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task { await viewModel.toggleTaskCompletion(task) }
                        }
                    }
                }
                
                HStack {
                    TextField("Новая задача...", text: $viewModel.newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        Task { await viewModel.addQuickTask() }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private func pomodoroCard(_ pomodoro: PomodoroState) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 16)
                    .foregroundStyle(.gray.opacity(0.15))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: pomodoro.progress)
                    .stroke(style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .foregroundStyle(pomodoro.phase == .work ? Color.blue : Color.green)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 4) {
                    Text(timeString(from: pomodoro.remainingSeconds))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    Text(pomodoro.phase.rawValue)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                Button {
                    viewModel.startOrPausePomodoro()
                } label: {
                    Text(pomodoro.isRunning ? "Пауза" : "Старт")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(pomodoro.isRunning ? Color.orange : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Button {
                    viewModel.resetPomodoro()
                } label: {
                    Text("Сброс")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.08), radius: 12)
        .padding(.horizontal, 16)
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
}
