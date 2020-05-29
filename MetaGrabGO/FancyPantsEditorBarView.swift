//
//  FancyPantsEditorBarView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-01-06.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct FancyPantsEditorView: View {
    @EnvironmentObject var keyboardHeightDataStore: KeyboardHeightDataStore
    
    @Binding var existedTextStorage: NSTextStorage
    @Binding var desiredHeight: CGFloat
    
    @Binding var newTextStorage: NSTextStorage
    @Binding var isEditable: Bool
    @Binding var isFirstResponder: Bool
    @Binding var didBecomeFirstResponder: Bool
    @Binding var showFancyPantsEditorBar: Bool
    
    var isNewContent: Bool
    var isThread: Bool
    var threadId: Int?
    var commentId: Int?
    var isOmniBar: Bool
    
    @State var isBold: Bool = false
    @State var isItalic: Bool = false
    @State var isStrikethrough: Bool = false
    @State var isDashBulletList: Bool = false
    @State var isNumberedBulletList: Bool = false
    @State var didChangeBold: Bool = false
    @State var didChangeItalic: Bool = false
    @State var didChangeStrikethrough: Bool = false
    @State var didChangeBulletList: Bool = false
    @State var didChangeNumberedBulletList: Bool = false
    
    @State var hasText: Bool = false
    
    var submit: (() -> Void)?
    
    func toggleBold() {
        self.isBold = !self.isBold
    }
    
    func turnOnDidChangeBold() {
        self.didChangeBold = true
    }
    
    func toggleItalic() {
        self.isItalic = !self.isItalic
    }
    
    func turnOnDidChangeItalic() {
        self.didChangeItalic = true
    }
    
    func toggleStrikethrough() {
        self.isStrikethrough = !self.isStrikethrough
    }
    
    func turnOnDidChangeStrikethrough() {
        self.didChangeStrikethrough = true
    }
    
    func toggleBulletList() {
        self.isDashBulletList = !self.isDashBulletList
    }
    
    func turnOnDidChangeBulletList() {
        self.didChangeBulletList = true
    }
    
    func toggleNumberBulletList() {
        self.isNumberedBulletList = !self.isNumberedBulletList
    }
    
    func turnOnDidChangeNumberedBulletList() {
        self.didChangeNumberedBulletList = true
    }
    
    func toggleFancyPantsEditorBar() {
        self.showFancyPantsEditorBar = !self.showFancyPantsEditorBar
    }
    
    var body: some View {
        GeometryReader { a in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    if self.isOmniBar == false {
                        TextView(
                            existedTextStorage: self.$existedTextStorage,
                            desiredHeight: self.$desiredHeight,
                            newTextStorage: self.$newTextStorage,
                            isBold: self.$isBold,
                            isItalic: self.$isItalic,
                            isStrikethrough: self.$isStrikethrough,
                            isDashBulletList: self.$isDashBulletList,
                            isNumberedBulletList: self.$isNumberedBulletList,
                            didChangeBold: self.$didChangeBold,
                            didChangeItalic: self.$didChangeItalic,
                            didChangeStrikethrough: self.$didChangeStrikethrough,
                            didChangeBulletList: self.$didChangeBulletList,
                            didChangeNumberedBulletList: self.$didChangeNumberedBulletList,
                            isEditable: self.$isEditable,
                            isFirstResponder: self.$isFirstResponder,
                            didBecomeFirstResponder: self.$didBecomeFirstResponder,
                            isNewContent: self.isNewContent,
                            isThread: self.isThread,
                            threadId:self.threadId,
                            commentId: self.commentId,
                            isOmniBar: self.isOmniBar,
                            hasText: self.$hasText
                        )
                            .padding(.vertical, self.isEditable || self.isNewContent ? 10 : 0)
                            .padding(.horizontal, self.isEditable || self.isNewContent ? 20 : 0)
                        
                    } else { // Omnibar view
                        HStack(alignment: .bottom, spacing: 0) {
                            TextView(
                                existedTextStorage: self.$existedTextStorage,
                                desiredHeight: self.$desiredHeight,
                                newTextStorage: self.$newTextStorage,
                                isBold: self.$isBold,
                                isItalic: self.$isItalic,
                                isStrikethrough: self.$isStrikethrough,
                                isDashBulletList: self.$isDashBulletList,
                                isNumberedBulletList: self.$isNumberedBulletList,
                                didChangeBold: self.$didChangeBold,
                                didChangeItalic: self.$didChangeItalic,
                                didChangeStrikethrough: self.$didChangeStrikethrough,
                                didChangeBulletList: self.$didChangeBulletList,
                                didChangeNumberedBulletList: self.$didChangeNumberedBulletList,
                                isEditable: self.$isEditable,
                                isFirstResponder: self.$isFirstResponder,
                                didBecomeFirstResponder: self.$didBecomeFirstResponder,
                                isNewContent: self.isNewContent,
                                isThread: self.isThread,
                                threadId:self.threadId,
                                commentId: self.commentId,
                                isOmniBar: self.isOmniBar,
                                hasText: self.$hasText
                            )
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .frame(width: self.keyboardHeightDataStore.keyboardHeight == 0 ? a.size.width * 0.5 : a.size.width * 0.7, height: self.keyboardHeightDataStore.keyboardHeight == 0 ? 50 * 0.75 : self.desiredHeight + 20)
                                .background(Color(red: 238 / 255, green: 238 / 255, blue: 238 / 255))
                                .cornerRadius(25)
                                .padding(.vertical, 10)
                                .padding(.leading, 20)
                            
                            Spacer()

                            if self.keyboardHeightDataStore.keyboardHeight != 0 {
                                Button(action: self.submit!, label: {
                                    Text("Submit")
                                        .frame(width: a.size.width * 0.17, height: 40, alignment: .center)
                                        .background(self.hasText ? Color.blue : Color(red: 160 / 255, green: 206 / 255, blue: 235 / 255))
                                        .foregroundColor(Color.white)
                                        .cornerRadius(8)
                                        .padding(.trailing, 20)
                                        .padding(.vertical, 10)
                                })
                            }
                        }
                    }
                }
                
                if self.isEditable == true && self.keyboardHeightDataStore.keyboardHeight != 0 && self.isOmniBar == true {
                    HStack(spacing: 0) {
                        Button(action: {
                            self.turnOnDidChangeBold()
                            self.toggleBold()
                        }) {
                            Image(systemName: "bold")
                                .resizable()
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .foregroundColor(self.isBold ? .black : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 60, height: 40, alignment: .center)
                        
                        Spacer()
                        
                        Button(action: {
                            self.turnOnDidChangeItalic()
                            self.toggleItalic()
                        }) {
                            Image(systemName: "italic")
                                .resizable()
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .foregroundColor(self.isItalic ? .black : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 60, height: 40, alignment: .center)
                        
                        Spacer()
                        
                        Button(action: {
                            self.turnOnDidChangeStrikethrough()
                            self.toggleStrikethrough()
                        }) {
                            Image(systemName: "strikethrough")
                                .resizable()
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .foregroundColor(self.isStrikethrough ? .black : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 60, height: 40, alignment: .center)
                        
                        Spacer()
                        
                        Button(action: {
                            self.turnOnDidChangeBulletList()
                            self.toggleBulletList()
                        }) {
                            Image(systemName: "list.bullet")
                                .resizable()
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .foregroundColor(self.isDashBulletList ? .black : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 60, height: 40, alignment: .center)
                        
                        Spacer()
                        
                        Button(action: {
                            self.turnOnDidChangeNumberedBulletList()
                            self.toggleNumberBulletList()
                        }) {
                            Image(systemName: "list.number")
                                .resizable()
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .foregroundColor(self.isNumberedBulletList ? .black : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 60, height: 40, alignment: .center)
                    }
                    .frame(width: a.size.width * 0.9, height: 40, alignment: .leading)
                    .padding(.horizontal)
                }
            }
        }
    }
}
