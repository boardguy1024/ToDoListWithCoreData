//
//  Home.swift
//  ToDoListWithCoreData
//
//  Created by paku on 2023/12/14.
//

import SwiftUI
import CoreData

struct Home: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate: Date = .init()
    @State private var showPendingTesks: Bool = true
    @State private var showCompletedTesks: Bool = true

    var body: some View {
        List {
            
            // メインカレンダー
            DatePicker(selection: $selectedDate, displayedComponents: [.date]) {
                Text("aaa")
            }
            .labelsHidden() // 左のlabelを非表示
            .datePickerStyle(.graphical) //カレンダを表示状態にする
           
            
            CustomFilteringDataView(selectedDate: $selectedDate) { pendingTasks, completedTasks in
                
                // For PendingTask
                if pendingTasks.isEmpty {
                    Text("保留中のタスクがありません")
                        .font(.caption)
                        .foregroundStyle(.gray)
                } else  {
                    DisclosureGroup(isExpanded: $showPendingTesks) {
                        ForEach(pendingTasks) {
                            TaskRow(task: $0, isPendingTask: true)
                        }
                    } label: {
                        Text("保留中のタスク - (\(pendingTasks.count))")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                
                if completedTasks.isEmpty {
                    Text("完了済みタスクがありません")
                        .font(.caption)
                        .foregroundStyle(.gray)
                } else {
                    // For ComppletedTask
                    DisclosureGroup(isExpanded: $showCompletedTesks) {
                        ForEach(completedTasks) {
                            TaskRow(task: $0, isPendingTask: false)
                        }
                    } label: {
                        Text("完了したタスク - (\(completedTasks.count))")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
        }
        .toolbar(content: {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    do {
                        let newTask = TaskEntity(context: viewContext)
                        newTask.id = .init()
                        newTask.date = self.selectedDate
                        // Start with pending data
                        newTask.isCompleted = false
                        
                        try viewContext.save()
                        
                        // pednging
                        showPendingTesks = true
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("タスクを追加")
                    }
                    .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        })
    }
}

#Preview {
    ContentView()
}

struct TaskRow: View {
    @StateObject var task: TaskEntity
    var isPendingTask: Bool
    
    @Environment(\.self) private var env
    @FocusState private var showKeyboard: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                task.isCompleted.toggle()
                save()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("タスクを入力", text: .init(
                    get: { return task.title ?? "" },
                    set: { task.title = $0 }))
                .focused($showKeyboard)
                .onSubmit {
                    removeEmptyTask()
                    save()
                }
                .foregroundStyle(isPendingTask ? Color.primary : Color.gray)
                .strikethrough(!isPendingTask, pattern: .solid, color: .primary)
                
                // .omit - 省略する・除外する
                // shorten - 短くする
                // 例 - 13:45
                Text((task.date ?? .init()).formatted(date: .omitted, time: .shortened))
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .overlay {
                        DatePicker(selection: .init(
                            get: { return task.date ?? Date() },
                            set: {
                                task.date = $0
                                
                                // Saving date when ever it's updated
                                save()
                            }), displayedComponents: [.hourAndMinute]) {
                            }
                            .labelsHidden()
                            .blendMode(.destinationOver)
                            //.offset(x: 80)
                        
                    }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .onAppear {
            if (task.title ?? "").isEmpty {
                showKeyboard = true
            }
        }
        // sceneの変化あった場合、
        // .active - appがforegroundで動作している場合
        // .inactive - appが activeでもbackgroundでもない場合
        // .background - appがBackgroundにある状態
        .onChange(of: env.scenePhase) { oldValue, newValue in
            // アプリがBackgroundになった場合、
            // emptyTaskは削除する
            if newValue != .active {
                // Checking if it's empty
                removeEmptyTask()
                
                save()
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // destructive - 破壊的 : つまり赤で表示される
            Button(role: .destructive) {
                //削除直後にui更新がされないので mainスレッドで実行するように
                DispatchQueue.main.async {
                    env.managedObjectContext.delete(task)
                    save()
                }
               
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
    
    func save() {
        do {
            try env.managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeEmptyTask() {
        if (task.title ?? "").isEmpty {
            // Removing Empty Task
            env.managedObjectContext.delete(task)
        }
    }
}
