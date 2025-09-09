//
//  GanttChartView.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/05.
//

import SwiftUI
import UIKit

final class GanttChartView: UIView {
    
    enum SectionID: Hashable, Sendable {
        case dates
        case workItemGroup(WorkItemGroup.ID)
    }
    
    enum ItemID: Hashable, Sendable {
        case date(Date)
        case workItem(WorkItem.ID)
    }
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionID, ItemID>
    
    private var workItemGroupProvider: (WorkItemGroup.ID) -> WorkItemGroup
    private var workItemProvider: (WorkItem.ID) -> WorkItem
    
    // MARK: UI components
    
    private lazy var collectionView: UICollectionView = {
        let layout = GanttChartViewLayout()
        layout.dataSource = self
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        return collectionView
    }()
    
    private let dateCellRegistration = DateCellRegistration()
    private let workItemCellRegistration = WorkItemCellRegistration()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<SectionID, ItemID>(
        collectionView: collectionView
    ) { [weak self] collectionView, indexPath, itemID in
        guard let self else { return nil }
        switch itemID {
        case .date(let date):
            return collectionView.dequeueConfiguredReusableCell(
                using: dateCellRegistration,
                for: indexPath,
                item: .init(date: date)
            )
        case .workItem(let workItemID):
            let workItem = workItemProvider(workItemID)
            return collectionView.dequeueConfiguredReusableCell(
                using: workItemCellRegistration,
                for: indexPath,
                item: .init(title: workItem.name)
            )
        }
    }
    
    // MARK: - Initializers
    
    init(
        workItemGroupProvider: @escaping (WorkItemGroup.ID) -> WorkItemGroup,
        workItemProvider: @escaping (WorkItem.ID) -> WorkItem
    ) {
        self.workItemGroupProvider = workItemGroupProvider
        self.workItemProvider = workItemProvider
        super.init(frame: .zero)
        
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    // MARK: - Methods
    
    func configure(
        dates: [Date],
        workItemGroups: [WorkItemGroup]
    ) {
        var snapshot = Snapshot()
        snapshot.appendSections([.dates])
        snapshot.appendItems(
            dates.map(ItemID.date),
            toSection: .dates
        )
        for group in workItemGroups {
            let sectionID = SectionID.workItemGroup(group.id)
            snapshot.appendSections([sectionID])
            snapshot.appendItems(
                group.children.map { .workItem($0.id) },
                toSection: sectionID
            )
        }
        dataSource.apply(snapshot)
    }
}

extension GanttChartView: GanttChartViewLayoutDataSource {
    
    func ganttChartViewLayout(
        _ ganttChartViewLayout: GanttChartViewLayout,
        itemIDAt indexPath: IndexPath
    ) -> ItemID? {
        dataSource.itemIdentifier(for: indexPath)
    }
}

#Preview {
    ContentView()
}
