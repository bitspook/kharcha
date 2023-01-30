//
//  TransactionRow.swift
//  kharcha
//
//  Created by Charanjit Singh on 23.01.23.
//

import SwiftUI

struct TransactionRow: View {
    var body: some View {
        HStack {
            Text("Tomatoes 2Kg")
            Spacer()
            Text("€ 2.39").foregroundColor(.gray)
        }
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRow()
    }
}
