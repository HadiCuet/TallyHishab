import SwiftUI
import SwiftData

struct PersonListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var people: [Person]
    
    @State private var searchText = ""
    
    var filteredPeople: [Person] {
        if searchText.isEmpty {
            return people
        }
        return people.filter { person in
            person.name.localizedCaseInsensitiveContains(searchText) ||
            person.mobile.contains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if people.isEmpty {
                        ContentUnavailableView(
                            "No Contacts",
                            systemImage: "person.2",
                            description: Text("Add people to track lend and borrow transactions")
                        )
                    } else {
                        List {
                            ForEach(filteredPeople) { person in
                                NavigationLink(destination: PersonDetailView(person: person)) {
                                    PersonRowView(person: person)
                                }
                            }
                            .onDelete(perform: deletePeople)
                        }
                        .searchable(text: $searchText, prompt: "Search by name or mobile")
                    }
                }
                
                NavigationLink {
                    AddPersonView()
                } label: {
                    Image(systemName: "plus")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
                }
                .padding(24)
            }
            .navigationTitle("People")
        }
    }
    
    private func deletePeople(at offsets: IndexSet) {
        for index in offsets {
            let person = filteredPeople[index]
            modelContext.delete(person)
        }
    }
}

struct PersonRowView: View {
    let person: Person
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(person.name)
                    .font(.headline)
                
                if let relationship = person.relationship, !relationship.isEmpty {
                    Text("(\(relationship))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(person.mobile)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(person.balanceDescription)
                .font(.caption)
                .foregroundStyle(person.netBalance > 0 ? .green : (person.netBalance < 0 ? .red : .secondary))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PersonListView()
        .modelContainer(for: [Person.self, Transaction.self], inMemory: true)
}