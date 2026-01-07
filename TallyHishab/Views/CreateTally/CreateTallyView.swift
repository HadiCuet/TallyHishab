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
                createTallyTransactionTypeSection

                CreateTallyPersonSelectorSection(
                    filteredPeople: filteredPeople,
                    isNewPersonValid: isNewPersonValid,
                    searchText: $searchText,
                    selectedPerson: $selectedPerson,
                    showingCreatePersonSection: $showingCreatePersonSection,
                    newPersonName: $newPersonName,
                    newPersonMobile: $newPersonMobile,
                    newPersonRelationship: $newPersonRelationship,
                    showingContactPicker: $showingContactPicker,
                    addAction: createAndSelectPerson
                )

                createTallyAmountSection

                CreateTallyTransactionDetailsSection(
                    date: $date,
                    mode: $mode,
                    showingTransactionDatePicker: $showingTransactionDatePicker
                )

                CreateTallyReturnDateSection(
                    returnDate: $returnDate,
                    returnDateDraft: $returnDateDraft,
                    showingReturnDatePicker: $showingReturnDatePicker
                )

                Section {
                    TextField("Add a note about this transaction", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("Note (Optional)")
                }

                Section {
                    ImagePicker(imageData: $recordImage)
                } header: {
                    Text("Receipt/Record Image (Optional)")
                } footer: {
                    Text("Attach a photo of receipt, cheque, or any transaction proof")
                }

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
    
    var createTallyTransactionTypeSection: some View {
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
    }
    
    var createTallyAmountSection: some View {
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
    }
}

#Preview {
    CreateTallyView()
        .modelContainer(for: [Person.self, Transaction.self], inMemory: true)
}
