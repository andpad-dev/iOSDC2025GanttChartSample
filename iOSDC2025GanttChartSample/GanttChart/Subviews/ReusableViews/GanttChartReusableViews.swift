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
    
    typealias State = GanttChartView.WorkItemGroupSectionState
    
    var tapHandler: ((GanttChartWorkItemGroupHeaderView) -> Void)?
    
    private let titleButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .label
        configuration.baseBackgroundColor = .secondarySystemBackground
        configuration.contentInsets.leading = 8
        configuration.titleLineBreakMode = .byTruncatingTail
        configuration.image = .init(systemName: "chevron.right")
        configuration.imagePadding = 8
        configuration.preferredSymbolConfigurationForImage = .init(scale: .small)
            .applying(
                UIImage.SymbolConfiguration(weight: .semibold)
            )
            .applying(
                UIImage.SymbolConfiguration(hierarchicalColor: .secondaryLabel)
            )
        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = .secondarySystemBackground
        configuration.background = background
        let button = UIButton(configuration: configuration)
        button.contentHorizontalAlignment = .leading
        button.imageView!.contentMode = .center
        return button
    }()
    
    override func setUpViews() {
        // Subviews
        addSubview(titleButton)
        
        titleButton.addAction(.init { [weak self] _ in
            guard let self else { return }
            tapHandler?(self)
        }, for: .primaryActionTriggered)
        
        // Layout
        titleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // titleButton.edges == self.edges
            titleButton.topAnchor.constraint(equalTo: topAnchor),
            titleButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func configure(
        workItemGroup: WorkItemGroup,
        state: State,
        tapHandler: @escaping (GanttChartWorkItemGroupHeaderView) -> Void
    ) {
        self.tapHandler = tapHandler
        
        var titleConfiguration = titleButton.configuration!
        titleConfiguration.title = workItemGroup.name
        titleConfiguration.attributedTitle!.font = .preferredFont(
            forTextStyle: .headline
        )
        titleButton.configuration = titleConfiguration
        updateState(with: state)
    }
    
    func updateState(with state: State) {
        // Rotate the chevron
        titleButton.imageView!.transform = .init(
            rotationAngle: state == .expanded ? .pi / 2 : 0
        )
    }
}

// MARK: - Decoration views -

final class GanttChartTopPinnedHeaderBackground: GanttChartReusableView {
    
    override func setUpViews() {
        isUserInteractionEnabled = false
        
        // Subviews
        let toolbar = UIToolbar() // The same blur effect as the navigation bar
        toolbar.delegate = self
        addSubview(toolbar)
        
        // Layout
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // toolbar.edges == self.edges
            toolbar.topAnchor.constraint(equalTo: topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

extension GanttChartTopPinnedHeaderBackground: UIToolbarDelegate {
    
    func position(for bar: any UIBarPositioning) -> UIBarPosition {
        .top // for the bottom separator
    }
}

final class GanttChartSeparator: GanttChartReusableView {
    
    override func setUpViews() {
        isUserInteractionEnabled = false
        backgroundColor = .opaqueSeparator
    }
}

#Preview {
    ContentView()
}
