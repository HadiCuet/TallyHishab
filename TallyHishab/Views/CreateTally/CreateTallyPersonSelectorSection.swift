import SwiftUI

/// A single section that handles:
/// - Searching and selecting an existing `Person`
/// - Optionally creating a new `Person` inline
/// - Triggering the contacts picker (delegated to the parent via `showingContactPicker` binding)
struct CreateTallyPersonSelectorSection: View {
    let filteredPeople: [Person]
    let isNewPersonValid: Bool

    @Binding var searchText: String
    @Binding var selectedPerson: Person?

    @Binding var showingCreatePersonSection: Bool

    @Binding var newPersonName: String
    @Binding var newPersonMobile: String
    @Binding var newPersonRelationship: String

    @Binding var showingContactPicker: Bool

    let addAction: () -> Void

    var body: some View {
        Section {
            if let person = selectedPerson {
                selectedPersonRow(person)
            } else {
                searchAndResults

                if filteredPeople.isEmpty {
                    createNewToggle
                }

                if showingCreatePersonSection {
                    newPersonForm
                }
            }
        } header: {
            Text("Select Person")
        } footer: {
            if selectedPerson == nil {
                Text("Search existing contacts by name or mobile number")
            }
        }
    }

    @ViewBuilder
    private func selectedPersonRow(_ person: Person) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.headline)
                Text(person.mobile)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let relationship = person.relationship, !relationship.isEmpty {
                    Text(relationship)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button("Change") {
                selectedPerson = nil
                searchText = ""
                showingCreatePersonSection = false
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }

    private var searchAndResults: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search by name or mobile", text: $searchText)
                .textContentType(.telephoneNumber)

            if !searchText.isEmpty && !filteredPeople.isEmpty {
                ForEach(filteredPeople.prefix(5)) { person in
                    Button {
                        selectedPerson = person
                        searchText = ""
                        showingCreatePersonSection = false
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(person.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(person.mobile)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private var createNewToggle: some View {
        Button {
            showingCreatePersonSection.toggle()

            if showingCreatePersonSection && !searchText.isEmpty {
                // Pre-fill if search text looks like a phone number
                if searchText.first?.isNumber == true || searchText.first == "+" {
                    newPersonMobile = searchText
                } else {
                    newPersonName = searchText
                }
            }
        } label: {
            Label(
                showingCreatePersonSection ? "Hide Create Person" : "Create New Person",
                systemImage: showingCreatePersonSection ? "minus.circle" : "plus.circle"
            )
        }
    }

    private var newPersonForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                showingContactPicker = true
            } label: {
                Label("Pick from Contacts", systemImage: "person.crop.circle.badge.plus")
            }

            TextField("Name", text: $newPersonName)
                .textContentType(.name)
                .autocorrectionDisabled()

            TextField("Mobile Number", text: $newPersonMobile)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)

            TextField("Relationship (Optional)", text: $newPersonRelationship)
                .autocorrectionDisabled()

            Button(action: addAction) {
                Label("Add & Select Person", systemImage: "checkmark.circle.fill")
            }
            .disabled(!isNewPersonValid)
        }
    }
}
