//
//  Transaction.swift
//  kharcha
//
//  Created by Charanjit Singh on 23.01.23.
//

import Foundation

struct Transaction {
    var account: String
    var amount: Double
}

struct JournalEntry: Identifiable {
    let id = UUID()
    var description: String
    var date: Date
    var transactions: [Transaction]
}

enum JournalParseError: Error {
    case InvalidEntry(_ entry: String, _ lineNumber: Int)
}
