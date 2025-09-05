//
//  GanttChart.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/05.
//

import SwiftUI

struct GanttChart: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GanttChartView {
        GanttChartView()
    }
    
    func updateUIView(_ uiView: GanttChartView, context: Context) {
        // NOP
    }
}

#Preview {
    ContentView()
}
