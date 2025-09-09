//
//  LayoutAttributes+.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/09.
//

import UIKit

extension GanttChartViewLayout.LayoutAttributes {
    
    typealias ElementKind = GanttChartView.ElementKind
    
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
    
    @discardableResult
    mutating func insert(
        forSupplementaryViewOf elementKind: ElementKind,
        at indexPath: IndexPath,
        configurator: (UICollectionViewLayoutAttributes) -> Void
    ) -> UICollectionViewLayoutAttributes {
        let supplementaryView = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: elementKind.rawValue,
            with: indexPath
        )
        configurator(supplementaryView)
        supplementaryViews[elementKind, default: [:]][indexPath] = supplementaryView
        return supplementaryView
    }
    
    @discardableResult
    mutating func insert(
        forDecorationViewOf elementKind: ElementKind,
        at indexPath: IndexPath,
        configurator: (UICollectionViewLayoutAttributes) -> Void
    ) -> UICollectionViewLayoutAttributes {
        let decorationView = UICollectionViewLayoutAttributes(
            forDecorationViewOfKind: elementKind.rawValue,
            with: indexPath
        )
        configurator(decorationView)
        decorationViews[elementKind, default: [:]][indexPath] = decorationView
        return decorationView
    }
}
