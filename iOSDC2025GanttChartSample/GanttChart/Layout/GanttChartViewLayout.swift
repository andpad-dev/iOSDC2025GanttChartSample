//
//  GanttChartViewLayout.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/08.
//

import SwiftUI
import UIKit

final class GanttChartViewLayout: UICollectionViewLayout {
    
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
    }
    
    private var references = LayoutReferences()
    
    // MARK: - Lifecycle
    
    override func prepare() {
        guard let collectionView else { return }
        
        // TODO: Implement
        let cellSize = CGSize(width: 100, height: 36)
        let horizontalSpacing: CGFloat = 16
        let verticalSpacing: CGFloat = 8
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                let dummy = UICollectionViewLayoutAttributes(
                    forCellWith: indexPath
                )
                dummy.frame = .init(
                    origin: .init(
                        x: (cellSize.width + horizontalSpacing) * CGFloat(section),
                        y: (cellSize.height + verticalSpacing) * CGFloat(item)
                    ),
                    size: cellSize
                )
                layoutAttributes.items[indexPath] = dummy
            }
        }
    }
    
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        layoutAttributes.forVisibleElements(in: rect)
    }
}

#Preview {
    ContentView()
}
