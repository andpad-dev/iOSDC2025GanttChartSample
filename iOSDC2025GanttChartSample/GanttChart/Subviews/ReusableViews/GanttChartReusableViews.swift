//
//  GanttChartReusableViews.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/09.
//

import SwiftUI
import UIKit

class GanttChartReusableView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
    }
    
    func setUpViews() {}
}

// MARK: - Supplementary views -

final class GanttChartWorkItemGroupHeaderView: GanttChartReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    override func setUpViews() {
        backgroundColor = .secondarySystemBackground
        
        // Subviews
        addSubview(titleLabel)
        
        // Layout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func configure(workItemGroup: WorkItemGroup) {
        titleLabel.text = workItemGroup.name
    }
}

// MARK: - Decoration views -

final class GanttChartSeparator: GanttChartReusableView {
    
    override func setUpViews() {
        isUserInteractionEnabled = false
        backgroundColor = .opaqueSeparator
    }
}

#Preview {
    ContentView()
}
