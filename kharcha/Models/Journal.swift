//
//  Journal.swift
//  kharcha
//
//  Created by Charanjit Singh on 24.01.23.
//

import Foundation
import Combine

struct DateJournal: Identifiable {
    let id = UUID()
    let date: Date
    let entries: [JournalEntry]
}

final class Journal: ObservableObject {
    @Published var groupedByDate: [DateJournal] = []
    let entries = loadJournal()
    
    init() {
        var groups: [Date: [JournalEntry]] = [:];
        
        for entry in entries {
            let date = entry.date
            groups[date] = groups[date] ?? []
            groups[date]?.append(entry)
        }
        
        for (date, entries) in groups {
            groupedByDate.append(DateJournal(date: date, entries: entries))
        }
        
        groupedByDate = groupedByDate.sorted(by: { $0.date > $1.date })
    }
}
                       
func loadJournal() -> [JournalEntry] {
    let filename = "main.ledger"
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        fatalError("\(filename) should be available in main bundle")
    }
    
    var journalText = ""
    do {
        journalText = try String(contentsOf: file)
    } catch {
        fatalError("Could not read \(filename) from main bundle:\n\(error)")
    }

    do {
       return try parseJournal(journalText)
    } catch {
        fatalError("Failed to parse journal: \(error)")
    }
}

func parseJournal(_ text: String) throws -> [JournalEntry] {
    let lines = text.split(whereSeparator: \.isNewline)
    var currentEntryText: String = ""
    var entries: [JournalEntry] = []

    for (lineNumber, line) in lines.enumerated() {
        if line.starts(with: try Regex("\\d\\d\\d\\d-\\d\\d?-\\d\\d?"))
            && !line.trimmingCharacters(in: .whitespaces).starts(with: ";")
            && currentEntryText.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        {
            guard let entry = parseJournalEntry(currentEntryText) else {
                throw JournalParseError.InvalidEntry(currentEntryText, lineNumber)
            }
            entries.append(entry)
            currentEntryText = ""
        }
        currentEntryText += line + "\n"
    }

    return entries
}

func parseJournalEntry(_ text: String) -> JournalEntry? {
    let lines = text
        .trimmingCharacters(in: .whitespaces)
        .split(omittingEmptySubsequences: true, whereSeparator: \.isNewline)

    var date: Date = Date()
    var description = ""
    var transactions: [Transaction] = []

    for (index, line) in lines.enumerated() {
        if index == 0 {
            let frags = line.split(whereSeparator: \.isWhitespace)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let pDate = dateFormatter.date(from: String(frags[0])) {
                date = pDate
            } else { return nil}

            description = frags.dropFirst().joined(separator: " ")
        }

        let frags = line.trimmingCharacters(in: .whitespaces).split(separator: "    ").map{ $0.trimmingCharacters(in: .whitespaces)}
        
        if frags.count == 0 { continue }
        
        var amount = 0.0
        if frags.count > 1, let pAmount = Double(frags[1]) {
            amount = pAmount
        }
        transactions.append(Transaction(account: String(frags[0]), amount: amount))
    }

    return JournalEntry(
        description: description,
        date: date,
        transactions: transactions
    )
}
