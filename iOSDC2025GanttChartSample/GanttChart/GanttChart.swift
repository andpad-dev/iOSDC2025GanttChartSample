//
//  GanttChart.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/05.
//

import SwiftUI

@MainActor @Observable
final class GanttChartState {
    
    var loadingResult: Result<[WorkItemGroup], any Error>?
    
    /*
     NOTE:
     Cache each elements in the form of Dictionary keyed by their ID.
     These are used to efficiently retrieve elements from the IDs managed by the diffable data source.
     */
    private var cachedWorkItemGroups: [WorkItemGroup.ID: WorkItemGroup] = [:]
    private var cachedWorkItems: [WorkItem.ID: WorkItem] = [:]
    
    // MARK: - Methods
    
    func refresh() async {
        loadingResult = nil
        do {
            try await Task.sleep(for: .milliseconds(500))
            let workItemGroups = WorkItemGroup.samples
            
            // Cache
            for group in workItemGroups {
                cachedWorkItemGroups[group.id] = group
                for item in group.children {
                    cachedWorkItems[item.id] = item
                }
            }
            
            loadingResult = .success(workItemGroups)
        } catch {
            loadingResult = .failure(error)
            cachedWorkItemGroups.removeAll()
            cachedWorkItems.removeAll()
        }
    }
    
    func workItemGroup(with id: WorkItemGroup.ID) -> WorkItemGroup? {
        cachedWorkItemGroups[id]
    }
    
    func workItem(with id: WorkItem.ID) -> WorkItem? {
        cachedWorkItems[id]
    }
}

struct GanttChart: UIViewRepresentable {
    
    let state: GanttChartState
    
    func makeUIView(context: Context) -> GanttChartView {
        GanttChartView(
            workItemGroupProvider: { groupID in
                state.workItemGroup(with: groupID)!
            },
            workItemProvider: { workItemID in
                state.workItem(with: workItemID)!
            }
        )
    }
    
    func updateUIView(_ uiView: GanttChartView, context: Context) {
        switch state.loadingResult {
        case .success(let workItemGroups):
            uiView.configure(workItemGroups: workItemGroups)
        case .failure:
            uiView.configure(workItemGroups: [])
        case nil:
            break
        }
    }
}

#Preview {
    ContentView()
}
