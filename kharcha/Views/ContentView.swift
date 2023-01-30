//
//  ContentView.swift
//  kharcha
//
//  Created by Charanjit Singh on 23.01.23.
//

import SwiftUI

private enum Field {
    case search
}

struct ContentView: View {
    @State var filter: String = ""
    @State var error: String = ""
    @State var showFilePicker = false
    @FocusState private var focusedField: Field?
    @EnvironmentObject var journal: Journal
    
    var body: some View {
        VStack {
            
            TextField("Filter by description", text: $filter)
                .focused($focusedField, equals: .search)
            if !error.isEmpty {
                Spacer()
                Text(error).foregroundColor(.red)
                Spacer()
            } else {
                List(journal.groupedByDate) { dateJournal in
                    let entries = filter.count != 0 ?
                    dateJournal.entries.filter({
                        $0.description.lowercased().contains(filter.lowercased())
                    }) :
                    dateJournal.entries
                    if entries.count > 0 {
                        let sectionTitle = dateJournal.date.formatted(
                            Date.FormatStyle()
                                .month(.abbreviated)
                                .day()
                                .year(.defaultDigits))
                        
                        Section(sectionTitle) {
                            ForEach(entries) { entry in
                                let spentAmount = String(
                                    format: "%.2f",
                                    entry.transactions.reduce(0) {
                                        $0 + abs($1.amount)
                                    }
                                )
                                
                                HStack {
                                    Text(entry.description)
                                    Spacer()
                                    Text(spentAmount).foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }.onTapGesture {
                    focusedField = nil
                }
            }
            Spacer()
            ControlGroup{
                Button(action: { focusedField = Field.search }) {
                    Label("Search", systemImage: "magnifyingglass")
                }
                Button(action: {
                    showFilePicker = true
                    error = ""
                }) {
                    Label("Select Ledger", systemImage: "doc.fill.badge.plus")
                }
            }.fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.data]) { (res) in
                do {
                    let fileUrl = try res.get()
                    try journal.load(fileUrl)
                } catch {
                    self.error = "Failed to load ledger"
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Journal())
    }
}
