//
//  WorkItem.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/05.
//

import Foundation

struct WorkItem: Hashable, Sendable {
    
    typealias ID = UUID
    
    var id: ID
    var parentID: WorkItemGroup.ID
    var name: String
    var schedule: ClosedRange<Date>
}
