import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
            
            FocusView()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }
        
            MotivationView()
                .tabItem {
                    Label("Motivation", systemImage: "lightbulb")
                }
            
            FAQView()
                .tabItem {
                    Label("FAQ", systemImage: "questionmark.circle")
                }
        }
    }
    
}
