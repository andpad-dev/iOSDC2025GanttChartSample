//
//  GanttChartView+ElementKind.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/09.
//

import enum SwiftUI.Edge

extension GanttChartView.ElementKind {
    
    private static var prefix: String {
        "GanttChartView.elementKind"
    }
    
    static var workItemGroupHeader: Self {
        .init(rawValue: "\(prefix).\(#function)")
    }
    
    static func separator(for edge: Edge) -> Self {
        .init(rawValue: "\(prefix).\(#function).\(edge)")
    }
}
