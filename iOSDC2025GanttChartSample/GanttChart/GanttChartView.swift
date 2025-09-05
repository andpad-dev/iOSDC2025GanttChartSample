//
//  GanttChartView.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/05.
//

import UIKit

final class GanttChartView: UIView {
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
    }
    
    private func setUpViews() {
        backgroundColor = .systemBackground
    }
}
