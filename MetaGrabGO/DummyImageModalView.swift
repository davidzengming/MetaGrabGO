//
//  DummyImageModalView.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-07-08.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct DummyImageModalView: View {
    @Binding var isImageModalOn: Bool
    @Binding var threadDataStore: ThreadDataStore?
    @Binding var currentImageModalIndex: Int?
    
    var body: some View {
        Text("")
            .sheet(isPresented: self.$isImageModalOn) {
                ImageModalView(threadDataStore: self.$threadDataStore, currentImageModalIndex: self.$currentImageModalIndex)
        }
    }
}
