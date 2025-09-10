//
//  UIScrollView+.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/10.
//

import UIKit

extension UIScrollView {
    
    /// Returns the content offset adjusted for `adjustedContentInset`.
    ///
    /// It is calibrated so that `.zero` is returned when scrolled to the top-left edge.
    /// For example, if `adjustedContentInset.top` is 100, then when `contentOffset.y` is -100,
    /// the `y` value of this property becomes 0; when `contentOffset.y` is -30, it is adjusted to 70.
    var adjustedContentOffset: CGPoint {
        .init(
            x: contentOffset.x + adjustedContentInset.left,
            y: contentOffset.y + adjustedContentInset.top
        )
    }
}
