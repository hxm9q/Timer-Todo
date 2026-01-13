import SwiftUI

struct TasksView: View {
    
    @StateObject private var viewModel = TasksViewModel()
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Tasks")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $viewModel.searchText, prompt: "Поиск задач...")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            ForEach(TasksViewModel.Filter.allCases, id: \.self) { filter in
                                Button(filter.rawValue) {
                                    viewModel.currentFilter = filter
                                }
                            }
                        } label: {
                            Label(viewModel.currentFilter.rawValue, systemImage: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showAddSheet) {
                    addTaskSheet
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            LoadingView()
            
        case .loaded:
            if viewModel.filteredTasks.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(viewModel.filteredTasks) { task in
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                                .font(.title2)
                                .onTapGesture {
                                    Task { await viewModel.toggleCompletion(task) }
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .strikethrough(task.isCompleted)
                                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                                
                                Text(task.priority.rawValue)
                                    .font(.caption)
                                    .foregroundColor(priorityColor(task.priority))
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await viewModel.deleteTask(task) }
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            
        case .error:
            if let error = viewModel.error {
                ErrorView(error: error) {
                    Task { await viewModel.loadTasks() }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.rectangle.portrait")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("Нет задач")
                .font(.title2)
            
            Text("Добавьте первую задачу")
                .foregroundColor(.secondary)
            
            Button("Добавить задачу") {
                viewModel.showAddSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var addTaskSheet: some View {
        NavigationStack {
            Form {
                Section("Новая задача") {
                    TextField("Название", text: $viewModel.newTitle)
                    
                    Picker("Приоритет", selection: $viewModel.newPriority) {
                        ForEach(TaskItem.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                }
            }
            .navigationTitle("Добавить задачу")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { viewModel.showAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        Task { await viewModel.addTask() }
                    }
                    .disabled(viewModel.newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func priorityColor(_ priority: TaskItem.Priority) -> Color {
        switch priority {
        case .high:   return .red
        case .medium: return .orange
        case .low:    return .blue
        }
    }
    
}
