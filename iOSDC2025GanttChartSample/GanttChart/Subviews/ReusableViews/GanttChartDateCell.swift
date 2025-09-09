//
//  GanttChartDateCell.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/09.
//

import SwiftUI
import UIKit

final class GanttChartDateCell: UICollectionViewCell {
    
    struct Configuration {
        var date: Date
    }
    
    func configure(with configuration: Configuration) {
        let date = configuration.date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let weekdayValue = calendar.component(.weekday, from: date)
        let weekdaySymbol = calendar.veryShortWeekdaySymbols[weekdayValue - 1]
        contentConfiguration = UIHostingConfiguration {
            VStack(spacing: 0) {
                Text("\(day)")
                    .frame(maxHeight: .infinity)
                Divider()
                Text(weekdaySymbol)
                    .frame(maxHeight: .infinity)
            }
            .font(.subheadline)
        }
        .margins(.all, 0)
    }
}

#Preview {
    ContentView()
}
