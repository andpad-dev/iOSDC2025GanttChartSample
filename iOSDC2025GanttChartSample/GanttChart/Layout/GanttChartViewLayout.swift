//
//  GanttChartViewLayout.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/08.
//

import SwiftUI
import UIKit

@MainActor
protocol GanttChartViewLayoutDataSource: AnyObject {
    
    func itemIDs(
        in ganttChartViewLayout: GanttChartViewLayout
    ) -> [GanttChartView.ItemID]
    
    func ganttChartViewLayout(
        _ ganttChartViewLayout: GanttChartViewLayout,
        itemIDAt indexPath: IndexPath
    ) -> GanttChartView.ItemID?
    
    func ganttChartViewLayout(
        _ ganttChartViewLayout: GanttChartViewLayout,
        workItemWith id: WorkItem.ID
    ) -> WorkItem
}

final class GanttChartViewLayout: UICollectionViewLayout {
    
    weak var dataSource: (any GanttChartViewLayoutDataSource)?
    
    // MARK: Layout attributes
    
    struct LayoutAttributes {
        
        typealias Dictionary = [
            IndexPath: UICollectionViewLayoutAttributes
        ]
        
        var items = Dictionary()
        
        /// Extracts and returns the layout attributes for the visible elements in the specified rectangle.
        func forVisibleElements(
            in rect: CGRect
        ) -> [UICollectionViewLayoutAttributes] {
            let attributesForVisibleItems = items.values
                .filter { $0.frame.intersects(rect) }
            return attributesForVisibleItems
        }
    }
    
    private var layoutAttributes = LayoutAttributes()
    
    // MARK: Layout references
    
    /// The layout information that serves as a reference for each element’s layout.
    struct LayoutReferences {
        
        struct DateReference {
            var cellFrame: CGRect
        }
        
        struct WorkItemReference {
            var cellMinY: CGFloat
        }
        
        var dates: [Date: DateReference] = [:]
        var workItems: [WorkItem.ID: WorkItemReference] = [:]
        
        var contentSize: CGSize = .zero
    }
    
    private var references = LayoutReferences()
    
    // MARK: - Overrides
    
    override var collectionViewContentSize: CGSize {
        references.contentSize
    }
    
    // MARK: - Lifecycle
    
    override func prepare() {
        guard let dataSource, let collectionView else { return }
        
        let itemIDs = dataSource.itemIDs(in: self)
        references.prepare(with: itemIDs)
        
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                let itemID = dataSource.ganttChartViewLayout(
                    self,
                    itemIDAt: indexPath
                )!
                prepareLayoutAttributes(for: itemID, at: indexPath)
            }
        }
    }
    
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        layoutAttributes.forVisibleElements(in: rect)
    }
}

extension GanttChartViewLayout {
    
    private func prepareLayoutAttributes(
        for itemID: GanttChartView.ItemID,
        at indexPath: IndexPath
    ) {
        guard let dataSource else { return }
        switch itemID {
        case .date(let date):
            layoutAttributes.insert(forCellAt: indexPath) { cell in
                let column = references.dateColumn(for: date)
                cell.frame = column.dateCellFrame
            }
        case .workItem(let workItemID):
            layoutAttributes.insert(forCellAt: indexPath) { cell in
                let workItem = dataSource.ganttChartViewLayout(
                    self,
                    workItemWith: workItemID
                )
                let row = references.workItemRow(for: workItem)
                cell.frame = row.workItemCellFrame
            }
        }
    }
}

#Preview {
    ContentView()
}
