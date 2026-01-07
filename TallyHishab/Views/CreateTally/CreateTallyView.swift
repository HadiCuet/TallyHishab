import SwiftUI
import SwiftData

struct CreateTallyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var allPeople: [Person]
    
    // Person selection/creation
    @State private var searchText = ""
    @State private var selectedPerson: Person?
    @State private var showingCreatePersonSection = false
    @State private var newPersonName = ""
    @State private var newPersonMobile = ""
    @State private var newPersonRelationship = ""
    @State private var showingContactPicker = false
    
    // Transaction details
    @State private var transactionType: TransactionType = .borrow
    @State private var amount: Double = 0
    @State private var date = Date()
    @State private var mode: PaymentMode = .cash
    @State private var returnDate: Date? = nil
    @State private var recordImage: Data?
    @State private var note = ""

    // Date picker presentation
    @State private var showingTransactionDatePicker = false
    @State private var showingReturnDatePicker = false

    // Used to drive the return-date DatePicker (since it can’t bind to an optional directly)
    @State private var returnDateDraft = Date()
    
    // UI State
    @State private var showingSuccessAlert = false
    @State private var savedTransactionType: TransactionType = .lend
    
    var filteredPeople: [Person] {
        if searchText.isEmpty {
            return allPeople
        }
        return allPeople.filter { person in
            person.name.localizedCaseInsensitiveContains(searchText) ||
            person.mobile.contains(searchText)
        }
    }
    
    var isNewPersonValid: Bool {
        !newPersonName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !newPersonMobile.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isFormValid: Bool {
        selectedPerson != nil && amount > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Transaction Type Selection
                Section {
                    Picker("Transaction Type", selection: $transactionType) {
                        Label("Borrow", systemImage: "arrow.down.circle.fill")
                            .tag(TransactionType.borrow)
                        
                        Label("Lend", systemImage: "arrow.up.circle.fill")
                        .tag(TransactionType.lend)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                } header: {
                    Text("What do you want to do?")
                }
                
                // Person Selection Section
                Section {
                    if let person = selectedPerson {
                        // Selected person display
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
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 4)
                    } else {
                        // Search field
                        TextField("Search by name or mobile", text: $searchText)
                            .textContentType(.telephoneNumber)
                        
                        // Filtered results
                        if !searchText.isEmpty && !filteredPeople.isEmpty {
                            ForEach(filteredPeople.prefix(5)) { person in
                                Button {
                                    selectedPerson = person
                                    searchText = ""
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
                        
                        // Show create option when no results match the search
                        if filteredPeople.isEmpty {
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
                    }
                } header: {
                    Text("Select Person")
                } footer: {
                    if selectedPerson == nil {
                        Text("Search existing contacts by name or mobile number")
                    }
                }
                
                // Create New Person Section (expandable)
                if showingCreatePersonSection && selectedPerson == nil {
                    Section {
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
                            createAndSelectPerson()
                        } label: {
                            Label("Add & Select Person", systemImage: "checkmark.circle.fill")
                        }
                        .disabled(!isNewPersonValid)
                    } header: {
                        Text("New Person Details")
                    }
                }
                
                // Amount Section
                Section {
                    HStack {
                        Text("৳")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        TextField("Amount", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                    }
                } header: {
                    Text("Amount")
                }
                
                // Transaction Details Section
                Section {
                    Button {
                        showingTransactionDatePicker = true
                    } label: {
                        HStack {
                            Text("Transaction Date")
                            Spacer()
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Picker("Payment Mode", selection: $mode) {
                        ForEach(PaymentMode.allCases, id: \.self) { paymentMode in
                            Text(paymentMode.rawValue).tag(paymentMode)
                        }
                    }
                } header: {
                    Text("Transaction Details")
                }
                
                // Return Date Section
                Section {
                    Button {
                        // If the value is currently nil, initialize a sensible default before opening.
                        let today = Calendar.current.startOfDay(for: Date())
                        if let existing = returnDate {
                            returnDateDraft = max(existing, today)
                        } else {
                            returnDateDraft = today
                        }
                        showingReturnDatePicker = true
                    } label: {
                        HStack {
                            Text("Return By")
                            Spacer()
                            if let returnDate {
                                Text(returnDate.formatted(date: .abbreviated, time: .omitted))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Not set")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Return Date (Optional)")
                } footer: {
                    Text("Tap to set a reminder date for when the money should be returned")
                }
                
                // Note Section
                Section {
                    TextField("Add a note about this transaction", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("Note (Optional)")
                }
                
                // Receipt Image Section
                Section {
                    ImagePicker(imageData: $recordImage)
                } header: {
                    Text("Receipt/Record Image (Optional)")
                } footer: {
                    Text("Attach a photo of receipt, cheque, or any transaction proof")
                }
                
                // Save Button
                Section {
                    Button {
                        saveTally()
                    } label: {
                        HStack {
                            Spacer()
                            Label(
                                transactionType == .lend ? "Record Lend" : "Record Borrow",
                                systemImage: transactionType == .lend ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
                            )
                            .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                    .listRowBackground(isFormValid ? (transactionType == .lend ? Color.green : Color.red) : Color.gray.opacity(0.3))
                    .foregroundStyle(.white)
                }
            }
            .navigationTitle("Create Tally")
            .sheet(isPresented: $showingContactPicker) {
                ContactPicker(selectedName: $newPersonName, selectedPhone: $newPersonMobile)
            }
            .sheet(isPresented: $showingTransactionDatePicker) {
                NavigationStack {
                    VStack {
                        DatePicker(
                            "Transaction Date",
                            selection: $date,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingTransactionDatePicker = false
                            }
                        }
                    }
                    .onChange(of: date) { _, _ in
                        showingTransactionDatePicker = false
                    }
                }
                .presentationDetents([.large])
            }
            .sheet(isPresented: $showingReturnDatePicker) {
                NavigationStack {
                    VStack {
                        DatePicker(
                            "Return By",
                            selection: $returnDateDraft,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                // Persist whatever is currently selected.
                                returnDate = returnDateDraft
                                showingReturnDatePicker = false
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Clear") {
                                returnDate = nil
                                showingReturnDatePicker = false
                            }
                        }
                    }
                    .onChange(of: returnDateDraft) { _, newValue in
                        // Auto-dismiss as soon as the user picks a date.
                        returnDate = newValue
                        showingReturnDatePicker = false
                    }
                }
                .presentationDetents([.medium])
            }
            .alert("Tally Created!", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    resetForm()
                }
            } message: {
                if let person = selectedPerson {
                    Text("Successfully recorded \(savedTransactionType == .lend ? "lend to" : "borrow from") \(person.name)")
                } else {
                    Text("Transaction recorded successfully")
                }
            }
        }
    }
    
    private func createAndSelectPerson() {
        let trimmedRelationship = newPersonRelationship.trimmingCharacters(in: .whitespaces)
        let person = Person(
            name: newPersonName.trimmingCharacters(in: .whitespaces),
            mobile: newPersonMobile.trimmingCharacters(in: .whitespaces),
            relationship: trimmedRelationship.isEmpty ? nil : trimmedRelationship
        )
        modelContext.insert(person)
        selectedPerson = person
        showingCreatePersonSection = false
        
        // Clear new person fields
        newPersonName = ""
        newPersonMobile = ""
        newPersonRelationship = ""
        searchText = ""
    }
    
    private func saveTally() {
        guard let person = selectedPerson else { return }
        
        let transaction = Transaction(
            amount: amount,
            date: date,
            mode: mode,
            recordImage: recordImage,
            returnDate: returnDate,
            type: transactionType,
            note: note.isEmpty ? nil : note
        )
        transaction.person = person
        modelContext.insert(transaction)
        
        savedTransactionType = transactionType
        showingSuccessAlert = true
    }
    
    private func resetForm() {
        selectedPerson = nil
        searchText = ""
        transactionType = .lend
        amount = 0
        date = Date()
        mode = .cash
        returnDate = nil
        recordImage = nil
        note = ""
        showingCreatePersonSection = false
        newPersonName = ""
        newPersonMobile = ""
        newPersonRelationship = ""
    }
}

#Preview {
    CreateTallyView()
        .modelContainer(for: [Person.self, Transaction.self], inMemory: true)
}
