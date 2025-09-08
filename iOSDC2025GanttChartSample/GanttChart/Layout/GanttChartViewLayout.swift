//
//  GanttChartViewLayout.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/08.
//

import SwiftUI
import UIKit

final class GanttChartViewLayout: UICollectionViewLayout {
    
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        // TODO: Implement
        let dummy = UICollectionViewLayoutAttributes(
            forCellWith: IndexPath(item: 0, section: 0)
        )
        dummy.frame = .init(x: 20, y: 40, width: 300, height: 36)
        return [dummy]
    }
}

#Preview {
    ContentView()
}
