//
//  GanttChartView+Registration.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/08.
//

import UIKit

// MARK: - Type aliases -

extension GanttChartView {
    
    // MARK: - Cell registrations
    
    typealias CellRegistration = UICollectionView.CellRegistration
    
    typealias WorkItemCellRegistration = CellRegistration<
        GanttChartWorkItemCell,
        GanttChartWorkItemCell.Configuration
    >
}

// MARK: - Cell registrations -

extension GanttChartView.WorkItemCellRegistration {
    
    init() {
        self.init { cell, _, configuration in
            cell.configure(with: configuration)
        }
    }
}
