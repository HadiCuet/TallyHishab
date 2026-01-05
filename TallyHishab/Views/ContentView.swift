import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
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
