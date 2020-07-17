//
//  FancyPantsEditorBarView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-01-06.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI
import Combine

var hasBottomNotch: Bool {
    if #available(iOS 11.0, *), let keyWindow = UIApplication.shared.keyWindow, keyWindow.safeAreaInsets.bottom > 0 {
        return true
    }
    return false
}

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
    
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var isStrikethrough: Bool = false
    @State private var isDashBulletList: Bool = false
    @State private var isNumberedBulletList: Bool = false
    @State private var didChangeBold: Bool = false
    @State private var didChangeItalic: Bool = false
    @State private var didChangeStrikethrough: Bool = false
    @State private var didChangeBulletList: Bool = false
    @State private var didChangeNumberedBulletList: Bool = false
    
    @State private var hasText: Bool = false
    @State private var isAttributesEditorOn: Bool = false
    
    var submit: ((CGFloat) -> Void)?
    var width: CGFloat
    var height: CGFloat
    var togglePickedCommentId: ((CommentDataStore?, CGFloat) -> Void)?
    var mainCommentContainerWidth: CGFloat?

    private func toggleAttributesEditor() {
        self.isAttributesEditorOn = !self.isAttributesEditorOn
    }
    
    private func toggleBold() {
        self.isBold = !self.isBold
    }
    
    private func turnOnDidChangeBold() {
        self.didChangeBold = true
    }
    
    private func toggleItalic() {
        self.isItalic = !self.isItalic
    }
    
    private func turnOnDidChangeItalic() {
        self.didChangeItalic = true
    }
    
    private func toggleStrikethrough() {
        self.isStrikethrough = !self.isStrikethrough
    }
    
    private func turnOnDidChangeStrikethrough() {
        self.didChangeStrikethrough = true
    }
    
    private func toggleBulletList() {
        self.isDashBulletList = !self.isDashBulletList
    }
    
    private func turnOnDidChangeBulletList() {
        self.didChangeBulletList = true
    }
    
    private func toggleNumberBulletList() {
        self.isNumberedBulletList = !self.isNumberedBulletList
    }
    
    private func turnOnDidChangeNumberedBulletList() {
        self.didChangeNumberedBulletList = true
    }
    
    private func toggleFancyPantsEditorBar() {
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
                            .background(Color(UIColor(named: "omniBarBackgroundColor")!))
                            .cornerRadius(25)
                            .padding(.vertical, 10)
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
                            
                            Button(action: {
                                self.submit!(self.mainCommentContainerWidth!)
                                self.isFirstResponder = false
                            }) {
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
                    .background(Color(UIColor(named: "omniBarPrimaryBackgroundColor")!)
                        .shadow(radius: 0.2)
                    )
                    .padding(.bottom, self.keyboardHeight == 0 && hasBottomNotch ? 20 : 0)
                    .background(Color(UIColor(named: "pseudoTertiaryBackground")!))
                    
                    if self.isEditable == true && self.keyboardHeight != 0 && self.isAttributesEditorOn {
                        
                        HStack {
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
                        }
                        .frame(width: self.width)
                        .background(Color(UIColor(named: "omniBarPrimaryBackgroundColor")!))
                    }
                }
                .onReceive(self.keyboardHeightPublisher) { self.keyboardHeight = $0 }
            }
        }
        
    }
}
