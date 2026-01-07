import SwiftUI
import SwiftData

struct CreateTallyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Person.name, order: .forward)]) private var allPeople: [Person]

    @StateObject private var vm = CreateTallyViewModel()

    var body: some View {
        NavigationStack {
            Form {
                createTallyTransactionTypeSection

                CreateTallyPersonSelectorSection(
                    people: allPeople,
                    selectedPerson: $vm.selectedPerson,
                    createPerson: { name, mobile, relationship in
                        vm.createPerson(using: modelContext, name: name, mobile: mobile, relationship: relationship)
                    }
                )

                createTallyAmountSection

                CreateTallyTransactionDetailsSection(
                    date: $vm.date,
                    mode: $vm.mode,
                    showingTransactionDatePicker: $vm.showingTransactionDatePicker
                )

                CreateTallyReturnDateSection(
                    returnDate: $vm.returnDate,
                    returnDateDraft: $vm.returnDateDraft,
                    showingReturnDatePicker: $vm.showingReturnDatePicker
                )

                Section {
                    TextField("Add a note about this transaction", text: $vm.note, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("Note (Optional)")
                }

                Section {
                    ImagePicker(imageData: $vm.recordImage)
                } header: {
                    Text("Receipt/Record Image (Optional)")
                } footer: {
                    Text("Attach a photo of receipt, cheque, or any transaction proof")
                }

                Section {
                    Button {
                        vm.saveTally(using: modelContext)
                    } label: {
                        HStack {
                            Spacer()

                            Label(
                                vm.transactionType == .lend ? "Record Lend" : "Record Borrow",
                                systemImage: vm.transactionType == .lend ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
                            )
                            .font(.headline)

                            Spacer()
                        }
                    }
                    .disabled(!vm.isFormValid)
                    .listRowBackground(vm.isFormValid ? (vm.transactionType == .lend ? Color.green : Color.red) : Color.gray.opacity(0.3))
                    .foregroundStyle(.white)
                }
            }
            .navigationTitle("Create Tally")
            .sheet(isPresented: $vm.showingTransactionDatePicker) {
                NavigationStack {
                    VStack {
                        DatePicker(
                            "Transaction Date",
                            selection: $vm.date,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                vm.dismissTransactionDatePicker()
                            }
                        }
                    }
                    .onChange(of: vm.date) { _, _ in
                        vm.dismissTransactionDatePicker()
                    }
                }
                .presentationDetents([.large])
            }
            .sheet(isPresented: $vm.showingReturnDatePicker) {
                NavigationStack {
                    VStack {
                        DatePicker(
                            "Return By",
                            selection: $vm.returnDateDraft,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                vm.didChangeReturnDateDraft(vm.returnDateDraft)
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Clear") {
                                vm.clearReturnDate()
                            }
                        }
                    }
                    .onChange(of: vm.returnDateDraft) { _, newValue in
                        vm.didChangeReturnDateDraft(newValue)
                    }
                }
                .presentationDetents([.medium])
            }
            .alert("Tally Created!", isPresented: $vm.showingSuccessAlert) {
                Button("OK") {
                    vm.resetForm()
                }
            } message: {
                if let person = vm.selectedPerson {
                    let actionText = vm.savedTransactionType == .lend ? "lend to" : "borrow from"
                    Text("Successfully recorded \(actionText) \(person.name)")
                } else {
                    Text("Transaction recorded successfully")
                }
            }
        }
    }

    var createTallyTransactionTypeSection: some View {
        Section {
            Picker("Transaction Type", selection: $vm.transactionType) {
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
                TextField("Amount", value: $vm.amount, format: .number)
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
