import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
            
            CreateTallyView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
            
            PersonListView()
                .tabItem {
                    Label("People", systemImage: "person.2.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Person.self, Transaction.self], inMemory: true)
}
