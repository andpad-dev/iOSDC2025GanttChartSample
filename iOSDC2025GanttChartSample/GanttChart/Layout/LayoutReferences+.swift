//
//  LayoutReferences+.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/09.
//

import SwiftUI

// MARK: - References -

@MainActor
extension GanttChartViewLayout.LayoutReferences {
    
    /// The offset for pinning elements during scrolling.
    var offsetToPinElement: CGPoint {
        // Pin elements by shifting them by the same amount as the scroll
        collectionView?.adjustedContentOffset ?? .zero
    }
    
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
    
    var separatorThickness: CGFloat {
        1 / (collectionView?.traitCollection.displayScale ?? 1)
    }
}

// MARK: - Preparation -

@MainActor
extension GanttChartViewLayout.LayoutReferences {
    
    typealias ZIndex = GanttChartViewLayout.ZIndex
    
    mutating func prepare(
        workItemGroups: [WorkItemGroup],
        itemIDs: [GanttChartView.ItemID],
        expandedWorkItemGroupIDs: Set<WorkItemGroup.ID>
    ) {
        guard let collectionView else { return }
        
        let minimumContentSize = collectionView.effectiveSize
        let finalContentSize: CGSize
        defer {
            contentSize = finalContentSize
            isInvalidated = false
        }
        
        let (dateAreaBottomY, lastDate) = prepareDateArea(with: itemIDs)
        guard let lastDate else {
            finalContentSize = minimumContentSize
            return
        }
        
        // Update this value incrementally while calculating each element's Y-coordinate
        var bottomY = dateAreaBottomY
        
        prepareWorkItemArea(
            updatingBottomY: &bottomY,
            with: workItemGroups,
            expandedWorkItemGroupIDs: expandedWorkItemGroupIDs
        )
        
        finalContentSize = .init(
            width: max(
                dates[lastDate]!.initialCellFrame.maxX,
                minimumContentSize.width
            ),
            height: max(
                bottomY,
                minimumContentSize.height
            )
        )
    }
    
    private mutating func prepareDateArea(
        with itemIDs: [GanttChartView.ItemID]
    ) -> (dateAreaBottomY: CGFloat, lastDate: Date?) {
        var previousDate: Date?
        for case .date(let date) in itemIDs {
            let minX: CGFloat = if let previousDate {
                // itemIDs are assumed to be sorted by date
                dates[previousDate]!.initialCellFrame.maxX + separatorThickness
            } else {
                0.0
            }
            let frame = CGRect(
                origin: .init(x: minX, y: 0),
                size: dateCellSize
            )
            dates[date] = .init(initialCellFrame: frame)
            previousDate = date
        }
        return (
            dateAreaBottomY: dateCellSize.height,
            lastDate: previousDate
        )
    }
    
    private mutating func prepareWorkItemArea(
        updatingBottomY bottomY: inout CGFloat,
        with groups: [WorkItemGroup],
        expandedWorkItemGroupIDs: Set<WorkItemGroup.ID>
    ) {
        let verticalSpacing = 4.0
        for group in groups {
            bottomY += separatorThickness // Header top separator
            workItemGroups[group.id] = .init(headerMinY: bottomY)
            
            bottomY += workItemGroupHeaderSize.height
            + separatorThickness // Header bottom separator
            + verticalSpacing
            
            if expandedWorkItemGroupIDs.contains(group.id) {
                for (offset, workItem) in group.children.enumerated() {
                    workItems[workItem.id] = .init(
                        cellMinY: bottomY,
                        zIndex: ZIndex.workItemCell(offset: offset)
                    )
                    bottomY += workItemCellHeight + verticalSpacing
                }
            } else {
                for (offset, workItem) in group.children.enumerated() {
                    workItems[workItem.id] = .init(
                        cellMinY: bottomY,
                        zIndex: ZIndex.workItemCell(offset: offset)
                    )
                }
                bottomY += workItemCellHeight + verticalSpacing
            }
        }
    }
}

// MARK: - Frames for each elements -

@MainActor
extension GanttChartViewLayout.LayoutReferences {
    
    struct FramesForEachElevationLevel: Equatable {
        /// A frame of an element on the top pinned header.
        var onTopPinnedHeader: CGRect
        
        /// A frame of an element on the content area.
        var onContentArea: CGRect
    }
    
    // MARK: - Top pinned header
    
    struct TopPinnedHeader {
        var frame: CGRect
    }
    
    func topPinnedHeader() -> TopPinnedHeader {
        TopPinnedHeader(
            frame: .init(
                x: offsetToPinElement.x,
                y: offsetToPinElement.y,
                width: collectionView?.bounds.width ?? 0,
                height: dateCellSize.height
            )
        )
    }
    
    // MARK: - Date area
    
    struct DateColumn: Equatable {
        var dateCellFrame: CGRect
        var leadingSeparatorFrames: FramesForEachElevationLevel
    }
    
    func dateColumn(for date: Date) -> DateColumn {
        var cellFrame = dates[date]!.initialCellFrame
        cellFrame.origin.y = offsetToPinElement.y
        
        let leadingSeparatorOnHeaderFrame = CGRect(
            x: cellFrame.minX - separatorThickness,
            y: cellFrame.minY,
            width: separatorThickness,
            height: dateCellSize.height
        )
        let leadingSeparatorOnContentFrame = CGRect(
            x: leadingSeparatorOnHeaderFrame.minX,
            y: leadingSeparatorOnHeaderFrame.maxY,
            width: leadingSeparatorOnHeaderFrame.width,
            height: contentSize.height
        )
        
        return DateColumn(
            dateCellFrame: cellFrame,
            leadingSeparatorFrames: .init(
                onTopPinnedHeader: leadingSeparatorOnHeaderFrame,
                onContentArea: leadingSeparatorOnContentFrame
            )
        )
    }
    
    // MARK: - Work item area
    
    struct WorkItemGroupSection {
        
        struct Header {
            var frame: CGRect
            var topSeparatorFrame: CGRect
            var bottomSeparatorFrame: CGRect
        }
        
        var header: Header
    }
    
    func workItemGroupSection(
        for workItemGroup: WorkItemGroup
    ) -> WorkItemGroupSection {
        let headerFrame = CGRect(
            origin: .init(
                x: offsetToPinElement.x,
                y: workItemGroups[workItemGroup.id]!.headerMinY
            ),
            size: workItemGroupHeaderSize
        )
        let topSeparatorFrame = CGRect(
            x: headerFrame.minX,
            y: headerFrame.minY - separatorThickness,
            width: headerFrame.width,
            height: separatorThickness
        )
        var bottomSeparatorFrame = topSeparatorFrame
        bottomSeparatorFrame.origin.y = headerFrame.maxY
        return WorkItemGroupSection(
            header: .init(
                frame: headerFrame,
                topSeparatorFrame: topSeparatorFrame,
                bottomSeparatorFrame: bottomSeparatorFrame
            )
        )
    }
    
    struct WorkItemRow {
        var workItemCellFrame: CGRect
    }
    
    func workItemRow(for workItem: WorkItem) -> WorkItemRow {
        let schedule = workItem.schedule
        let minX = dates[schedule.lowerBound]!.initialCellFrame.minX
        let maxX = dates[schedule.upperBound]!.initialCellFrame.maxX - 1
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
