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
    
    func sectionIDs(
        in ganttChartViewLayout: GanttChartViewLayout
    ) -> [GanttChartView.SectionID]
    
    func itemIDs(
        in ganttChartViewLayout: GanttChartViewLayout
    ) -> [GanttChartView.ItemID]
    
    func ganttChartViewLayout(
        _ ganttChartViewLayout: GanttChartViewLayout,
        indexFor sectionID: GanttChartView.SectionID
    ) -> Int?
    
    func ganttChartViewLayout(
        _ ganttChartViewLayout: GanttChartViewLayout,
        indexPathFor itemID: GanttChartView.ItemID
    ) -> IndexPath?
    
    func ganttChartViewLayout(
        _ ganttChartViewLayout: GanttChartViewLayout,
        workItemGroupWith id: WorkItemGroup.ID
    ) -> WorkItemGroup
    
    func ganttChartViewLayout(
        _ ganttChartViewLayout: GanttChartViewLayout,
        workItemWith id: WorkItem.ID
    ) -> WorkItem
}

final class GanttChartViewLayout: UICollectionViewLayout {
    
    typealias ElementKind = GanttChartView.ElementKind
    
    weak var dataSource: (any GanttChartViewLayoutDataSource)?
    
    // MARK: Layout attributes
    
    struct LayoutAttributes {
        
        typealias Dictionary = [
            IndexPath: UICollectionViewLayoutAttributes
        ]
        
        var items = Dictionary()
        var supplementaryViews = [ElementKind: Dictionary]()
        
        /// Extracts and returns the layout attributes for the visible elements in the specified rectangle.
        func forVisibleElements(
            in rect: CGRect
        ) -> [UICollectionViewLayoutAttributes] {
            let attributesForVisibleItems = items.values
                .filter { $0.frame.intersects(rect) }
            let attributesForVisibleSupplementaryViews = supplementaryViews.values
                .flatMap(\.values)
                .filter { $0.frame.intersects(rect) }
            
            return attributesForVisibleItems
            + attributesForVisibleSupplementaryViews
        }
    }
    
    private var layoutAttributes = LayoutAttributes()
    
    // MARK: Layout references
    
    /// The layout information that serves as a reference for each element’s layout.
    struct LayoutReferences {
        
        struct DateReference {
            var cellFrame: CGRect
        }
        
        struct WorkItemGroupReference {
            var headerMinY: CGFloat
        }
        
        struct WorkItemReference {
            var cellMinY: CGFloat
        }
        
        weak var collectionView: UICollectionView?
        
        var dates: [Date: DateReference] = [:]
        var workItemGroups: [WorkItemGroup.ID: WorkItemGroupReference] = [:]
        var workItems: [WorkItem.ID: WorkItemReference] = [:]
        
        var contentSize: CGSize = .zero
    }
    
    private lazy var references = LayoutReferences(
        collectionView: collectionView
    )
    
    // MARK: - Overrides
    
    override var collectionViewContentSize: CGSize {
        references.contentSize
    }
    
    // MARK: - Lifecycle
    
    override func prepare() {
        guard let dataSource else { return }
        
        let sectionIDs = dataSource.sectionIDs(in: self)
        let workItemGroups = sectionIDs.compactMap {
            switch $0 {
            case .workItemGroup(let groupID):
                dataSource.ganttChartViewLayout(
                    self,
                    workItemGroupWith: groupID
                )
            default:
                nil
            }
        }
        let itemIDs = dataSource.itemIDs(in: self)
        references.prepare(
            workItemGroups: workItemGroups,
            itemIDs: itemIDs
        )
        
        for sectionID in sectionIDs {
            let sectionIndex = dataSource.ganttChartViewLayout(
                self,
                indexFor: sectionID
            )!
            prepareLayoutAttributes(for: sectionID, at: sectionIndex)
            
            for itemID in itemIDs {
                let indexPath = dataSource.ganttChartViewLayout(
                    self,
                    indexPathFor: itemID
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

// MARK: - Preparation -

extension GanttChartViewLayout {
    
    private func prepareLayoutAttributes(
        for sectionID: GanttChartView.SectionID,
        at index: Int
    ) {
        guard let dataSource else { return }
        let indexPath = IndexPath(index: index)
        switch sectionID {
        case .dates:
            break
        case .workItemGroup(let groupID):
            let group = dataSource.ganttChartViewLayout(
                self,
                workItemGroupWith: groupID
            )
            let groupSection = references.workItemGroupSection(
                for: group
            )
            layoutAttributes.insert(
                forSupplementaryViewOf: .workItemGroupHeader,
                at: indexPath
            ) { header in
                header.frame = groupSection.headerFrame
            }
        }
    }
    
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
