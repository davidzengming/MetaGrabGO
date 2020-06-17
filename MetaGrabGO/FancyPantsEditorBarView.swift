//
//  FancyPantsEditorBarView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-01-06.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI
import Combine

struct FancyPantsEditorView: View {
    @Binding var existedTextStorage: NSTextStorage
    @Binding var desiredHeight: CGFloat
    
    @Binding var newTextStorage: NSTextStorage
    @Binding var isEditable: Bool
    @Binding var isFirstResponder: Bool
    @Binding var didBecomeFirstResponder: Bool
    @Binding var showFancyPantsEditorBar: Bool
    
    @State private var keyboardHeight: CGFloat = 0
    
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
    @State var isAttributesEditorOn: Bool = false
    
    var submit: ((CGFloat) -> Void)?
    var width: CGFloat
    var height: CGFloat
    var togglePickedCommentId: ((CommentDataStore?, CGFloat) -> Void)?
    var mainCommentContainerWidth: CGFloat?
    
    func toggleAttributesEditor() {
        self.isAttributesEditorOn = !self.isAttributesEditorOn
    }
    
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
    
    // conditionally publishes changes only fancy bar view is omni bar (reply bar)
    var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        ).eraseToAnyPublisher()
    }
    
    var body: some View {
        Group {
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
            } else {
                VStack(spacing: 0) {
                    
                    if self.keyboardHeight != 0 {
                        // hack for clear clickable background
                        Color.black
                            .opacity(0.0001)
                            .onTapGesture {
                                self.togglePickedCommentId!(nil, CGFloat(0))
                                self.isFirstResponder = false
                                UIApplication.shared.endEditing()
                        }
                        .frame(height: self.height - max((self.keyboardHeight == 0 ? 50 * 0.75: self.desiredHeight + 20) + 20, 60) - CGFloat(self.keyboardHeight + (self.isAttributesEditorOn ? 40 : 0)))
                    }
                    
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
                            .frame(height: self.keyboardHeight == 0 ? 50 * 0.75 : self.desiredHeight + 20)
                            .background(Color(red: 238 / 255, green: 238 / 255, blue: 238 / 255))
                            .cornerRadius(25)
                            .padding(.vertical, 10)
                            .padding(.bottom, self.keyboardHeight == 0 ? 20 : 0)
                            .padding(.leading, 20)
                            .padding(.trailing, self.keyboardHeight == 0 ? 20 : 0)
                        
                        if self.keyboardHeight != 0 {
                            Button(action: self.toggleAttributesEditor) {
                                Image(systemName: "text.cursor")
                                    .resizable()
                                    .padding(10)
                                    .frame(width: 40, height: 40, alignment: .center)
                                    .background(self.isAttributesEditorOn ? Color(.darkGray) : Color(.lightGray))
                                    .foregroundColor(Color.white)
                                    .cornerRadius(8)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 10)
                            }
                            
                            Button(action: { self.submit!(self.mainCommentContainerWidth!) }) {
                                Text("Submit")
                                    .bold()
                                    .padding(.horizontal, 5)
                                    .frame(height: 40, alignment: .center)
                                    .background(self.hasText ? Color.blue : Color(.lightGray))
                                    .foregroundColor(Color.white)
                                    .cornerRadius(8)
                                    .padding(.vertical, 10)
                            }
                            .padding(.trailing, 20)
                        }
                    }
                    .background(Color.white)
                    
                    if self.isEditable == true && self.keyboardHeight != 0 && self.isAttributesEditorOn {
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
                        .frame(width: self.width - 20 * 2, height: 40, alignment: .leading)
                        .background(Color.white)
                    }
                }
                .onReceive(self.keyboardHeightPublisher) { self.keyboardHeight = $0 }
            }
        }
        
    }
}
