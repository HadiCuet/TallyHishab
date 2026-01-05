import SwiftUI
import SwiftData

struct AddPersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var mobile = ""
    @State private var relationship = ""
    @State private var showingContactPicker = false
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !mobile.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        showingContactPicker = true
                    } label: {
                        Label("Pick from Contacts", systemImage: "person.crop.circle.badge.plus")
                    }
                }
                
                Section("Person Details") {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                    
                    TextField("Mobile Number", text: $mobile)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                    TextField("Relationship (Optional)", text: $relationship)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Add Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePerson()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPicker(selectedName: $name, selectedPhone: $mobile)
            }
        }
    }
    
    private func savePerson() {
        let trimmedRelationship = relationship.trimmingCharacters(in: .whitespaces)
        let person = Person(
            name: name.trimmingCharacters(in: .whitespaces),
            mobile: mobile.trimmingCharacters(in: .whitespaces),
            relationship: trimmedRelationship.isEmpty ? nil : trimmedRelationship
        )
        modelContext.insert(person)
        dismiss()
    }
}

#Preview {
    AddPersonView()
        .modelContainer(for: Person.self, inMemory: true)
}
