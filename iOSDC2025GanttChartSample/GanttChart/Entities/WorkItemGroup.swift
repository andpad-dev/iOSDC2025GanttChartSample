//
//  WorkItemGroup.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/05.
//

import Foundation

struct WorkItemGroup: Hashable, Sendable {
    
    typealias ID = UUID
    
    var id: ID
    var name: String
    var children: [WorkItem]
}

// MARK: - Sample -

extension WorkItemGroup {
    
    static let samples: [Self] = {
        var samples: [Self] = []
        for groupIndex in 0..<10 {
            let id = ID()
            let sample = Self(
                id: id,
                name: "Group \(groupIndex)",
                children: (0..<5).map { i in
                    let calendar = Calendar.current
                    let offset = i * 3 + groupIndex * 5
                    let start = calendar.date(from: .init(year: 2025, month: 9, day: 19 + offset))!
                    let end = calendar.date(from: .init(year: 2025, month: 9, day: 21 + offset))!
                    return WorkItem(
                        id: WorkItem.ID(),
                        parentID: id,
                        name: "Item \(i)",
                        schedule: start...end
                    )
                }
            )
            samples.append(sample)
        }
        return samples
    }()
}
