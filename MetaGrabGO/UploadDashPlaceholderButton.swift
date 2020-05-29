//
//  UploadDashPlaceholderButton.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-02-06.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct UploadDashPlaceholderButton: View {
    var body: some View {
        GeometryReader { a in
            Path { path in
                let width = a.size.width
                let height = a.size.height
                
                let leftBound = CGFloat(0)
                let rightBound = width
                let top = CGFloat(0)
                let bot = height
                
                //                let midX = rightBound / 2
                //                let midY = bot / 2
                //                let plusSignScale = CGFloat(0.5)
                
                path.move(to: CGPoint(x: leftBound, y: top))
                path.addLine(to: CGPoint(x: rightBound, y: top))
                path.addLine(to: CGPoint(x: rightBound, y: bot))
                path.addLine(to: CGPoint(x: leftBound, y: bot))
                path.addLine(to: CGPoint(x: leftBound, y: top))
            }
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            
            Path { path in
                let width = a.size.width
                let height = a.size.height
                
                //                let leftBound = CGFloat(0)
                let rightBound = width
                //                let top = CGFloat(0)
                let bot = height
                
                let midX = rightBound / 2
                let midY = bot / 2
                
                let plusSignScale = CGFloat(0.5)
                
                path.move(to: CGPoint(x: midX, y: midY))
                path.addLine(to: CGPoint(x: midX, y: midY - midY * plusSignScale))
                path.move(to: CGPoint(x: midX, y: midY))
                path.addLine(to: CGPoint(x: midX, y: midY + midY * plusSignScale))
                path.move(to: CGPoint(x: midX, y: midY))
                path.addLine(to: CGPoint(x: midX - midX * plusSignScale, y: midY))
                path.move(to: CGPoint(x: midX, y: midY))
                path.addLine(to: CGPoint(x: midX + midX * plusSignScale, y: midY))
                
            }
            .stroke(style: StrokeStyle(lineWidth: 2))
        }
    }
}
