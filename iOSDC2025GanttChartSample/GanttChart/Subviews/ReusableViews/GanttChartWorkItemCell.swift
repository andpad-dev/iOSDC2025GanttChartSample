//
//  GanttChartWorkItemCell.swift
//  iOSDC2025GanttChartSample
//
//  Created by 西悠作 on 2025/09/08.
//

import SwiftUI
import UIKit

final class GanttChartWorkItemCell: UICollectionViewCell {
    
    struct Configuration {
        var title: String
    }
    
    func configure(with configuration: Configuration) {
        contentConfiguration = UIHostingConfiguration {
            Text(configuration.title)
                .font(.headline)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .leading
                )
                .padding(.horizontal, 6)
                .background(.yellow)
                .clipShape(.rect(cornerRadius: 4))
        }
        .margins(.all, 0)
    }
}

#Preview {
    ContentView()
}
