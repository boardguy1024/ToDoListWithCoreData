//
//  CustomFilteringDataView.swift
//  ToDoListWithCoreData
//
//  Created by paku on 2023/12/14.
//

import SwiftUI
import CoreData

struct CustomFilteringDataView<Content: View>: View {
    
    var content: ([TaskEntity], [TaskEntity]) -> Content
    @FetchRequest private var result: FetchedResults<TaskEntity>
    @Binding private var selectedDate: Date
    
    init(selectedDate: Binding<Date>, @ViewBuilder content: @escaping ([TaskEntity], [TaskEntity]) -> Content) {
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate.wrappedValue)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        
        // 抽出条件は NSPredicateを使う
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startOfDay, endOfDay])
        
        _result = FetchRequest(
            entity: TaskEntity.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.date, ascending: false)],
            predicate: predicate,
            animation: .easeIn(duration: 0.25))
        
        self.content = content
        self._selectedDate = selectedDate
    }

    var body: some View {
        content(separateTasks().0, separateTasks().1)
            .onChange(of: selectedDate) { oldValue, newValue in
                
                // Clearing Old Predicate
                result.nsPredicate = nil
                
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: newValue)
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
                let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startOfDay, endOfDay])

                // Assigning New Predicate
                result.nsPredicate = predicate
            }
    }
    
    func separateTasks() -> ([TaskEntity], [TaskEntity]) {
        let pendingTasks = result.filter { $0.isCompleted == false }
        let completedTasks = result.filter { $0.isCompleted }
        
        return (pendingTasks, completedTasks)
    }
}

#Preview {
    ContentView()
}
