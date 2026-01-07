import SwiftUI
import SwiftData

struct AddPersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var mobile = ""
    @State private var email = ""
    @State private var relationship = ""
    @State private var showingContactPicker = false
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !mobile.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                    
                    TextField("Email (Optional)", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    TextField("Relationship (Optional)", text: $relationship)
                        .autocorrectionDisabled()
                }
            }
            
            Button {
                savePerson()
            } label: {
                Text("Save")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            .disabled(!isValid)
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationTitle("Add Person")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingContactPicker) {
            ContactPicker(selectedName: $name, selectedPhone: $mobile)
        }
    }
    
    private func savePerson() {
        let trimmedRelationship = relationship.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        
        let person = Person(
            name: name.trimmingCharacters(in: .whitespaces),
            mobile: mobile.trimmingCharacters(in: .whitespaces),
            email: trimmedEmail.isEmpty ? nil : trimmedEmail,
            relationship: trimmedRelationship.isEmpty ? nil : trimmedRelationship
        )
        modelContext.insert(person)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddPersonView()
            .modelContainer(for: Person.self, inMemory: true)
    }
}