//
//  ContentView.swift
//  kharcha
//
//  Created by Charanjit Singh on 23.01.23.
//

import SwiftUI

struct ContentView: View {
    @State var filter: String = ""
    @EnvironmentObject var journal: Journal
    
    var body: some View {
        VStack {
            TextField("Filter by description", text: $filter)
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
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Journal())
    }
}
