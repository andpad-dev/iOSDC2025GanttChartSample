//
//  LayoutAttributes+.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/09.
//

import UIKit

extension GanttChartViewLayout.LayoutAttributes {
    
    @discardableResult
    mutating func insert(
        forCellAt indexPath: IndexPath,
        configurator: (UICollectionViewLayoutAttributes) -> Void
    ) -> UICollectionViewLayoutAttributes {
        let cell = UICollectionViewLayoutAttributes(
            forCellWith: indexPath
        )
        configurator(cell)
        items[indexPath] = cell
        return cell
    }
}
