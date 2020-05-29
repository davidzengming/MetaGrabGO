//
//  Bold.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-01-30.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct BoldEditorButton: View {
    var body: some View {
        GeometryReader { g in
            Text("B")
                .font(.system(size: g.size.height > g.size.width ? g.size.width * 0.5: g.size.height * 0.5))
        }
    }
}

struct ItalicEditorButton: View {
    var body: some View {
        GeometryReader { g in
            ZStack {
                Text("i")
                    .font(.system(size: g.size.height > g.size.width ? g.size.width * 0.5: g.size.height * 0.5))
                    .italic()
            }
        }
    }
}


struct StrikeThroughEditorButton: View {
    var body: some View {
        GeometryReader { g in
            Text("S")
                .font(.system(size: g.size.height > g.size.width ? g.size.width * 0.5: g.size.height * 0.5))
                .strikethrough()
        }
    }
}

struct BulletListEditorButton: View {
    var body: some View {
        GeometryReader { g in
            Path { path in
                let height = g.size.height
                let width = g.size.width
                
                let midY = height * 0.5
                let midX = width * 0.5
                
                let scaling = CGFloat(0.7)
                let distToTopAndBot = g.size.height > g.size.width ? g.size.width * 0.5: g.size.height * 0.5
                let diff = distToTopAndBot / 2 * scaling
                
                let botY = midY + diff
                let topY = midY - diff
                
                let leftBound = midX - diff
                let rightBound = midX + diff
                
                let firstLeftStopPoint = leftBound + (rightBound - leftBound) * 0.1
                let secondLeftStopPoint = leftBound + (rightBound - leftBound) * 0.25
                
                path.move(to: CGPoint(x: leftBound, y: topY))
                path.addLine(to: CGPoint(x: firstLeftStopPoint, y: topY))
                path.move(to: CGPoint(x: secondLeftStopPoint, y: topY))
                path.addLine(to: CGPoint(x: rightBound, y: topY))
                
                path.move(to: CGPoint(x: leftBound, y: midY))
                path.addLine(to: CGPoint(x: firstLeftStopPoint, y: midY))
                path.move(to: CGPoint(x: secondLeftStopPoint, y: midY))
                path.addLine(to: CGPoint(x: rightBound, y: midY))
                
                path.move(to: CGPoint(x: leftBound, y: botY))
                path.addLine(to: CGPoint(x: firstLeftStopPoint, y: botY))
                path.move(to: CGPoint(x: secondLeftStopPoint, y: botY))
                path.addLine(to: CGPoint(x: rightBound, y: botY))
            }
            .stroke(Color.black, lineWidth: 2)
        }
    }
}


func useProxy(_ proxy: GeometryProxy) -> some View {
    let width = proxy.size.width
    let height = proxy.size.height
    let midY = height * 0.5
    let midX = width * 0.5
    
    let scaling = CGFloat(0.7)
    let distToTopAndBot = height > width ? width * 0.5: height * 0.5
    let diff = distToTopAndBot / 2 * scaling
    
    let botY = midY + diff
    let topY = midY - diff
    
    let leftBound = midX - diff
    let rightBound = midX + diff
    
    let firstLeftStopPoint = leftBound + (rightBound - leftBound) * 0.1
    
    return ZStack {
        Text("1")
            .position(x: leftBound + (firstLeftStopPoint - leftBound) / 2, y: topY)
            .font(.system(size: height > width ? width * 0.15: height * 0.15))
        Text("2")
            .position(x: leftBound + (firstLeftStopPoint - leftBound) / 2, y: midY)
            .font(.system(size: height > width ? width * 0.15: height * 0.15))
        Text("3")
            .position(x: leftBound + (firstLeftStopPoint - leftBound) / 2, y: botY)
            .font(.system(size: height > width ? width * 0.15: height * 0.15))
    }
}


struct NumberedBulletListEditorButton: View {
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                useProxy(proxy)
            }
            
            GeometryReader { g in
                Path { path in
                    let height = g.size.height
                    let width = g.size.width
                    
                    let midY = height * 0.5
                    let midX = width * 0.5
                    
                    let scaling = CGFloat(0.7)
                    let distToTopAndBot = g.size.height > g.size.width ? g.size.width * 0.5: g.size.height * 0.5
                    let diff = distToTopAndBot / 2 * scaling
                    
                    let botY = midY + diff
                    let topY = midY - diff
                    
                    let leftBound = midX - diff
                    let rightBound = midX + diff
                    
                    let secondLeftStopPoint = leftBound + (rightBound - leftBound) * 0.25
                    
                    path.move(to: CGPoint(x: secondLeftStopPoint, y: topY))
                    path.addLine(to: CGPoint(x: rightBound, y: topY))
                    
                    path.move(to: CGPoint(x: secondLeftStopPoint, y: midY))
                    path.addLine(to: CGPoint(x: rightBound, y: midY))
                    
                    path.move(to: CGPoint(x: secondLeftStopPoint, y: botY))
                    path.addLine(to: CGPoint(x: rightBound, y: botY))
                }
                .stroke(Color.black, lineWidth: 2)
            }
        }
    }
}
