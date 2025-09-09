//
//  GanttChartView+ElementKind.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/09.
//

extension GanttChartView.ElementKind {
    
    private static var prefix: String {
        "GanttChartView.elementKind"
    }
    
    static var workItemGroupHeader: Self {
        .init(rawValue: "\(prefix).\(#function)")
    }
}
