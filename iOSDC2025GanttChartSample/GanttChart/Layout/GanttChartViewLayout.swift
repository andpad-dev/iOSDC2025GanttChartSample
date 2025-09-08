//
//  GanttChartViewLayout.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/08.
//

import SwiftUI
import UIKit

final class GanttChartViewLayout: UICollectionViewLayout {
    
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
    
    // MARK: - Lifecycle
    
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        // TODO: Implement
        let cellHeight: CGFloat = 36
        let spacing: CGFloat = 8
        var dummyAttributes: [UICollectionViewLayoutAttributes] = []
        for i in 0..<5 {
            let dummy = UICollectionViewLayoutAttributes(
                forCellWith: IndexPath(item: i, section: 0)
            )
            dummy.frame = .init(
                x: 20,
                y: (cellHeight + spacing) * CGFloat(i),
                width: 300,
                height: cellHeight
            )
            dummyAttributes.append(dummy)
        }
        return dummyAttributes
    }
}

#Preview {
    ContentView()
}
