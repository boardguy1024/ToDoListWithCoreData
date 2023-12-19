//
//  ContentView.swift
//  ToDoListWithCoreData
//
//  Created by paku on 2023/12/14.
//

import SwiftUI

struct ContentView: View {
 
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("To-do")
        }
    }
}
#Preview {
    ContentView()
}
 
