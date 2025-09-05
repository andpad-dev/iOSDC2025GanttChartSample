//
//  GanttChartView.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/05.
//

import SwiftUI
import UIKit

final class GanttChartView: UIView {
    
    typealias SectionID = Int
    typealias ItemID = String
    
    private let collectionView: UICollectionView = {
        // TODO: Replace with GanttChartViewLayout
        let layout = UICollectionViewCompositionalLayout.list(
            using: .init(appearance: .insetGrouped)
        )
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        return collectionView
    }()
    
    private let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ItemID> { cell, indexPath, itemID in
        var configuration = cell.defaultContentConfiguration()
        configuration.text = itemID
        cell.contentConfiguration = configuration
    }
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<SectionID, ItemID>(
        collectionView: collectionView
    ) { [weak self] collectionView, indexPath, itemID in
        guard let self else { return nil }
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: itemID
        )
    }
    
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
        
        // Subviews
        addSubview(collectionView)
        
        // Layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                // collectionView.edges == self.edges
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        )
    }
}

#Preview {
    ContentView()
}
