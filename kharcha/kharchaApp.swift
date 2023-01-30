//
//  kharchaApp.swift
//  kharcha
//
//  Created by Charanjit Singh on 23.01.23.
//

import SwiftUI

@main
struct kharchaApp: App {
    @StateObject private var journal = Journal()
    
    var body: some Scene {
        WindowGroup { 
            ContentView().environmentObject(journal)
        }
    }
}
