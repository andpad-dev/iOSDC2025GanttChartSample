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
