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
    func ganttChartViewLayout(
        _ ganttChartViewLayout: GanttChartViewLayout,
        itemIDAt indexPath: IndexPath
    ) -> GanttChartView.ItemID?
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
        
        // TODO: Implement
        let dummyContentSize = CGSize(width: 1500, height: 1000)
        references.contentSize = dummyContentSize
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
        switch itemID {
        case .date:
            let cellSize = CGSize(width: 24, height: 48)
            let cell = UICollectionViewLayoutAttributes(
                forCellWith: indexPath
            )
            cell.frame = .init(
                origin: .init(
                    x: cellSize.width * CGFloat(indexPath.item),
                    y: 0
                ),
                size: cellSize
            )
            layoutAttributes.items[indexPath] = cell
        case .workItem:
            // TODO: Layout
            let cellSize = CGSize(width: 100, height: 36)
            let horizontalSpacing: CGFloat = 16
            let verticalSpacing: CGFloat = 8
            let cell = UICollectionViewLayoutAttributes(
                forCellWith: indexPath
            )
            cell.frame = .init(
                origin: .init(
                    x: (cellSize.width + horizontalSpacing) * CGFloat(indexPath.section - 1),
                    y: (cellSize.height + verticalSpacing) * CGFloat(indexPath.item) + 52
                ),
                size: cellSize
            )
            layoutAttributes.items[indexPath] = cell
        }
    }
}

#Preview {
    ContentView()
}
