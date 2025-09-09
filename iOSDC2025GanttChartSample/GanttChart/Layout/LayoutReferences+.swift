//
//  LayoutReferences+.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/09.
//

import SwiftUI

// MARK: - References -

extension GanttChartViewLayout.LayoutReferences {
    
    var dateCellSize: CGSize {
        .init(width: 24, height: 48)
    }
    
    var workItemGroupHeaderSize: CGSize {
        .init(
            width: collectionView?.bounds.width ?? 0,
            height: 32
        )
    }
    
    var workItemCellHeight: CGFloat {
        30
    }
}

// MARK: - Preparation -

extension GanttChartViewLayout.LayoutReferences {
    
    mutating func prepare(
        workItemGroups: [WorkItemGroup],
        itemIDs: [GanttChartView.ItemID]
    ) {
        let finalContentSize: CGSize
        defer {
            contentSize = finalContentSize
        }
        
        let (dateAreaBottomY, lastDate) = prepareDateArea(with: itemIDs)
        guard let lastDate else {
            finalContentSize = .zero
            return
        }
        
        // Update this value incrementally while calculating each element's Y-coordinate
        var bottomY = dateAreaBottomY
        
        prepareWorkItemArea(
            updatingBottomY: &bottomY,
            with: workItemGroups
        )
        
        finalContentSize = .init(
            width: dates[lastDate]!.cellFrame.maxX,
            height: bottomY
        )
    }
    
    private mutating func prepareDateArea(
        with itemIDs: [GanttChartView.ItemID]
    ) -> (dateAreaBottomY: CGFloat, lastDate: Date?) {
        var previousDate: Date?
        for case .date(let date) in itemIDs {
            let minX: CGFloat = if let previousDate {
                // itemIDs are assumed to be sorted by date
                dates[previousDate]!.cellFrame.maxX
            } else {
                0.0
            }
            let frame = CGRect(
                origin: .init(x: minX, y: 0),
                size: dateCellSize
            )
            dates[date] = .init(cellFrame: frame)
            previousDate = date
        }
        return (
            dateAreaBottomY: dateCellSize.height,
            lastDate: previousDate
        )
    }
    
    private mutating func prepareWorkItemArea(
        updatingBottomY bottomY: inout CGFloat,
        with groups: [WorkItemGroup]
    ) {
        let verticalSpacing = 4.0
        for group in groups {
            workItemGroups[group.id] = .init(headerMinY: bottomY)
            bottomY += workItemGroupHeaderSize.height + verticalSpacing
            
            for workItem in group.children {
                workItems[workItem.id] = .init(cellMinY: bottomY)
                bottomY += workItemCellHeight + verticalSpacing
            }
        }
    }
}

// MARK: - Frames for each elements -

extension GanttChartViewLayout.LayoutReferences {
    
    // MARK: - Date area
    
    struct DateColumn: Equatable {
        var dateCellFrame: CGRect
    }
    
    func dateColumn(for date: Date) -> DateColumn {
        DateColumn(
            dateCellFrame: dates[date]!.cellFrame
        )
    }
    
    // MARK: - Work item area
    
    struct WorkItemGroupSection {
        var headerFrame: CGRect
    }
    
    func workItemGroupSection(
        for workItemGroup: WorkItemGroup
    ) -> WorkItemGroupSection {
        WorkItemGroupSection(
            headerFrame: .init(
                origin: .init(
                    x: 0,
                    y: workItemGroups[workItemGroup.id]!.headerMinY
                ),
                size: workItemGroupHeaderSize
            )
        )
    }
    
    struct WorkItemRow {
        var workItemCellFrame: CGRect
    }
    
    func workItemRow(for workItem: WorkItem) -> WorkItemRow {
        let schedule = workItem.schedule
        let minX = dates[schedule.lowerBound]!.cellFrame.minX
        let maxX = dates[schedule.upperBound]!.cellFrame.maxX
        return WorkItemRow(
            workItemCellFrame: .init(
                x: minX,
                y: workItems[workItem.id]!.cellMinY,
                width: maxX - minX,
                height: workItemCellHeight
            )
        )
    }
}

#Preview {
    ContentView()
}
