//
//  CreateTallyTransactionDetailsSection.swift
//  TallyHishab
//
//  Created by Sazib on 1/7/26.
//

import SwiftUI

struct CreateTallyTransactionDetailsSection: View {
    @Binding var date: Date
    @Binding var mode: PaymentMode
    @Binding var showingTransactionDatePicker: Bool

    var body: some View {
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
    }
}
