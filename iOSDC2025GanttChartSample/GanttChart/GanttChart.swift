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
    
    func refresh() async {
        loadingResult = nil
        do {
            try await Task.sleep(for: .milliseconds(500))
            loadingResult = .success(WorkItemGroup.samples)
        } catch {
            loadingResult = .failure(error)
        }
    }
}

struct GanttChart: UIViewRepresentable {
    
    let state: GanttChartState
    
    func makeUIView(context: Context) -> GanttChartView {
        GanttChartView()
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
