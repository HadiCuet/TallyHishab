//
//  CreateTallyReturnDateSection.swift
//  TallyHishab
//
//  Created by Sazib on 1/7/26.
//

import SwiftUI

struct CreateTallyReturnDateSection: View {
    @Binding var returnDate: Date?
    @Binding var returnDateDraft: Date
    @Binding var showingReturnDatePicker: Bool

    var body: some View {
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
    }
}
