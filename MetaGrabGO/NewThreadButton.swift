//
//  NewThreadButton.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-02-03.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct NewThreadButton: View {
    var body: some View {
        GeometryReader { a in
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: a.size.width, height: a.size.height, alignment: .center)
                Image(systemName: "plus")
                    .resizable()
                    .cornerRadius(10)
                    .frame(width: a.size.width * 0.5, height: a.size.height * 0.5, alignment: .center)
                    .padding(5)
                    .foregroundColor(Color.white)
                    .background(Color.black.opacity(0))
            }
        }
    }
}
