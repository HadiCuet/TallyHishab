import SwiftUI

/// A self-contained section that handles:
/// - Searching and selecting an existing `Person`
/// - Creating a new `Person` inline
/// - Picking from Contacts (optional)
///
/// This view owns all UI state required for the flow and returns the selected `Person` via `selectedPerson`.
struct CreateTallyPersonSelectorSection: View {
    let people: [Person]

    @Binding var selectedPerson: Person?

    /// Creates and persists a person, returning the newly created `Person`.
    /// (The parent decides how persistence is done, e.g. via SwiftData ModelContext.)
    let createPerson: (_ name: String, _ mobile: String, _ relationship: String?) -> Person

    // UI State (owned here)
    @State private var searchText = ""
    @State private var showingCreatePersonSection = false

    @State private var newPersonName = ""
    @State private var newPersonMobile = ""
    @State private var newPersonRelationship = ""

    @State private var showingContactPicker = false

    private var filteredPeople: [Person] {
        guard !searchText.isEmpty else { return people }
        return people.filter { person in
            person.name.localizedCaseInsensitiveContains(searchText) ||
            person.mobile.contains(searchText)
        }
    }

    private var isNewPersonValid: Bool {
        !newPersonName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !newPersonMobile.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Section {
            if let person = selectedPerson {
                selectedPersonRow(person)
            } else {
                searchAndResults

                // Show create option when no results match the search
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
        .sheet(isPresented: $showingContactPicker) {
            ContactPicker(selectedName: $newPersonName, selectedPhone: $newPersonMobile)
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
                resetLocalState(keepSearch: false)
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
                        resetLocalState(keepSearch: false)
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

            if showingCreatePersonSection {
                prefillNewPersonFieldsFromSearchIfNeeded()
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

            Button {
                addAndSelectPerson()
            } label: {
                Label("Add & Select Person", systemImage: "checkmark.circle.fill")
            }
            .disabled(!isNewPersonValid)
        }
    }

    private func addAndSelectPerson() {
        let name = newPersonName.trimmingCharacters(in: .whitespaces)
        let mobile = newPersonMobile.trimmingCharacters(in: .whitespaces)
        let relationshipTrimmed = newPersonRelationship.trimmingCharacters(in: .whitespaces)
        let relationship = relationshipTrimmed.isEmpty ? nil : relationshipTrimmed

        let person = createPerson(name, mobile, relationship)
        selectedPerson = person

        resetLocalState(keepSearch: false)
    }

    private func prefillNewPersonFieldsFromSearchIfNeeded() {
        guard !searchText.isEmpty else { return }

        // Pre-fill if search text looks like a phone number
        if searchText.first?.isNumber == true || searchText.first == "+" {
            if newPersonMobile.trimmingCharacters(in: .whitespaces).isEmpty {
                newPersonMobile = searchText
            }
        } else {
            if newPersonName.trimmingCharacters(in: .whitespaces).isEmpty {
                newPersonName = searchText
            }
        }
    }

    private func resetLocalState(keepSearch: Bool) {
        if !keepSearch {
            searchText = ""
        }

        showingCreatePersonSection = false

        newPersonName = ""
        newPersonMobile = ""
        newPersonRelationship = ""

        showingContactPicker = false
    }
}
