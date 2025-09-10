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
    typealias WorkItemGroupSectionState = GanttChartView.WorkItemGroupSectionState
    
    weak var dataSource: (any GanttChartViewLayoutDataSource)?
    
    // MARK: Layout attributes
    
    struct LayoutAttributes {
        
        typealias Dictionary = [
            IndexPath: UICollectionViewLayoutAttributes
        ]
        
        var items = Dictionary()
        var supplementaryViews = [ElementKind: Dictionary]()
        var decorationViews = [ElementKind: Dictionary]()
        
        /// Extracts and returns the layout attributes for the visible elements in the specified rectangle.
        func forVisibleElements(
            in rect: CGRect
        ) -> [UICollectionViewLayoutAttributes] {
            let attributesForVisibleItems = items.values
                .filter { $0.frame.intersects(rect) }
            let attributesForVisibleSupplementaryViews = supplementaryViews.values
                .flatMap(\.values)
                .filter { $0.frame.intersects(rect) }
            let attributesForVisibleDecorationViews = decorationViews.values
                .flatMap(\.values)
                .filter { $0.frame.intersects(rect) }
            
            return attributesForVisibleItems
            + attributesForVisibleSupplementaryViews
            + attributesForVisibleDecorationViews
        }
    }
    
    private var layoutAttributes = LayoutAttributes()
    
    // MARK: Layout references
    
    /// The layout information that serves as a reference for each element’s layout.
    struct LayoutReferences: Equatable {
        
        struct DateReference: Equatable {
            /// - Note: This is an initial value.
            ///         The actual `origin.y` of the date cell will be updated for pinning.
            var initialCellFrame: CGRect
        }
        
        struct WorkItemGroupReference: Equatable {
            var headerMinY: CGFloat
        }
        
        struct WorkItemReference: Equatable {
            var cellMinY: CGFloat
        }
        
        weak var collectionView: UICollectionView?
        
        var isInvalidated = true
        
        var dates: [Date: DateReference] = [:]
        var workItemGroups: [WorkItemGroup.ID: WorkItemGroupReference] = [:]
        var workItems: [WorkItem.ID: WorkItemReference] = [:]
        
        var contentSize: CGSize = .zero
        
        /// Invalidates all reference values.
        mutating func invalidate() {
            isInvalidated = true
            dates.removeAll(keepingCapacity: true)
            workItemGroups.removeAll(keepingCapacity: true)
            workItems.removeAll(keepingCapacity: true)
            contentSize = .zero
            assert(
                self == LayoutReferences(
                    collectionView: collectionView
                )
            )
        }
    }
    
    private lazy var references = LayoutReferences(
        collectionView: collectionView
    )
    
    enum ZIndex {
        // Top pinned header area
        static var dateCell: Int { 1100 }
        static var topPinnedHeaderSeparator: Int { 1010 }
        static var topPinnedHeaderBackground: Int { 1000 }
        
        // Content area
        static var workItemGroupHeaderSeparator: Int { 310 }
        static var workItemGroupHeader: Int { 300 }
        static var workItemCell: Int { 200 }
        static var backgroundSeparator: Int { 100 }
    }
    
    // MARK: States
    
    private var expandedWorkItemGroupIDs: Set<WorkItemGroup.ID> = []
    
    func workItemGroupSectionState(
        for groupID: WorkItemGroup.ID
    ) -> WorkItemGroupSectionState {
        expandedWorkItemGroupIDs.contains(groupID)
        ? .expanded
        : .collapsed
    }
    
    // MARK: - Overrides
    
    override var collectionViewContentSize: CGSize {
        references.contentSize
    }
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        
        // Register decoration views
        register(
            GanttChartTopPinnedHeaderBackground.self,
            forDecorationViewOfKind: ElementKind
                .topPinnedHeaderBackground
                .rawValue
        )
        for level in GanttChartView.ElevationLevel.allCases {
            for edge in Edge.allCases {
                register(
                    GanttChartSeparator.self,
                    forDecorationViewOfKind: ElementKind
                        .separator(for: edge, on: level)
                        .rawValue
                )
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepare() {
        guard let dataSource else { return }
        
        let sectionIDs = dataSource.sectionIDs(in: self)
        let itemIDs = dataSource.itemIDs(in: self)
        
        // Calculate reference values for layout if needed
        if references.isInvalidated {
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
            references.prepare(
                workItemGroups: workItemGroups,
                itemIDs: itemIDs,
                expandedWorkItemGroupIDs: expandedWorkItemGroupIDs
            )
        }
        
        // Prepare layout attributes
        prepareLayoutAttributesForTopPinnedHeader()
        
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
    
    // MARK: Invalidation
    
    override func invalidateLayout(
        with context: UICollectionViewLayoutInvalidationContext
    ) {
        if context.invalidateEverything
            || context.invalidateDataSourceCounts {
            references.invalidate()
        }
        super.invalidateLayout(with: context)
    }
    
    override func shouldInvalidateLayout(
        forBoundsChange newBounds: CGRect
    ) -> Bool {
        // Invalidate layout to pin elements
        true
    }
    
    // MARK: - Methods
    
    func toggleWorkItemGroupSectionExpansion(
        for groupID: WorkItemGroup.ID
    ) {
        if expandedWorkItemGroupIDs.contains(groupID) {
            expandedWorkItemGroupIDs.remove(groupID)
        } else {
            expandedWorkItemGroupIDs.insert(groupID)
        }
    }
}

// MARK: - Preparation -

extension GanttChartViewLayout {
    
    private func prepareLayoutAttributesForTopPinnedHeader() {
        // Use a unique and stable IndexPath
        let indexPath = IndexPath(index: -1)
        layoutAttributes.insert(
            forDecorationViewOf: .topPinnedHeaderBackground,
            at: indexPath
        ) { background in
            let header = references.topPinnedHeader()
            background.frame = header.frame
            background.zIndex = ZIndex.topPinnedHeaderBackground
        }
    }
    
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
            let sectionHeader = groupSection.header
            layoutAttributes.insert(
                forSupplementaryViewOf: .workItemGroupHeader,
                at: indexPath
            ) { header in
                header.frame = sectionHeader.frame
                header.zIndex = ZIndex.workItemGroupHeader
            }
            layoutAttributes.insert(
                forDecorationViewOf: .separator(
                    for: .top,
                    on: .contentArea
                ),
                at: indexPath
            ) { separator in
                separator.frame = sectionHeader.topSeparatorFrame
                separator.zIndex = ZIndex.workItemGroupHeaderSeparator
            }
            layoutAttributes.insert(
                forDecorationViewOf: .separator(
                    for: .bottom,
                    on: .contentArea
                ),
                at: indexPath
            ) { separator in
                separator.frame = sectionHeader.bottomSeparatorFrame
                separator.zIndex = ZIndex.workItemGroupHeaderSeparator
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
            let dateColumn = references.dateColumn(for: date)
            layoutAttributes.insert(forCellAt: indexPath) { cell in
                cell.frame = dateColumn.dateCellFrame
                cell.zIndex = ZIndex.dateCell
            }
            layoutAttributes.insert(
                forDecorationViewOf: .separator(
                    for: .leading,
                    on: .topPinnedHeader
                ),
                at: indexPath
            ) { separator in
                separator.frame = dateColumn.leadingSeparatorFrames.onTopPinnedHeader
                separator.zIndex = ZIndex.topPinnedHeaderSeparator
            }
            layoutAttributes.insert(
                forDecorationViewOf: .separator(
                    for: .leading,
                    on: .contentArea
                ),
                at: indexPath
            ) { separator in
                separator.frame = dateColumn.leadingSeparatorFrames.onContentArea
                separator.zIndex = ZIndex.backgroundSeparator
            }
        case .workItem(let workItemID):
            layoutAttributes.insert(forCellAt: indexPath) { cell in
                let workItem = dataSource.ganttChartViewLayout(
                    self,
                    workItemWith: workItemID
                )
                let row = references.workItemRow(for: workItem)
                cell.frame = row.workItemCellFrame
                cell.zIndex = ZIndex.workItemCell
            }
        }
    }
}

#Preview {
    ContentView()
}
