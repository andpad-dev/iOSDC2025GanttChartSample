//
//  ContentView.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/05.
//

import SwiftUI

struct ContentView: View {
    
    @State private var ganttChartState = GanttChartState()
    
    var body: some View {
        NavigationStack {
            GanttChart(state: ganttChartState)
                .ignoresSafeArea()
                .navigationTitle("ガントチャート")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackgroundVisibility(
                    .visible,
                    for: .navigationBar
                )
                .task {
                    await ganttChartState.refresh()
                }
        }
    }
}

#Preview {
    ContentView()
}
