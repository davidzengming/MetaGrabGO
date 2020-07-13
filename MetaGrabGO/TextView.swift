//
//  TextView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-11-28.
//  Copyright © 2019 David Zeng. All rights reserved.
//

extension UIFont {
    var isBold: Bool {
        return (fontDescriptor.symbolicTraits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) > 0
    }
    
    var isItalic: Bool {
        return (fontDescriptor.symbolicTraits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) > 0
    }
}

extension NSAttributedString {
    
    func height(containerWidth: CGFloat) -> CGFloat {
        
        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.height)
    }
    
    func width(containerHeight: CGFloat) -> CGFloat {
        
        let rect = self.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: containerHeight),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.width)
    }
}

import Foundation
import SwiftUI

struct TextView: UIViewRepresentable {
    
    @Binding var existedTextStorage: NSTextStorage
    @Binding var desiredHeight: CGFloat
    
    @Binding var newTextStorage: NSTextStorage
    
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    @Binding var isStrikethrough: Bool
    @Binding var isDashBulletList: Bool
    @Binding var isNumberedBulletList: Bool
    
    @Binding var didChangeBold: Bool
    @Binding var didChangeItalic: Bool
    @Binding var didChangeStrikethrough: Bool
    @Binding var didChangeBulletList: Bool
    @Binding var didChangeNumberedBulletList: Bool
    
    @Binding var isEditable: Bool
    
    @Binding var isFirstResponder: Bool
    @Binding var didBecomeFirstResponder: Bool
    
    var isNewContent: Bool
    var isThread: Bool
    var threadId: Int?
    var commentId: Int?
    var isOmniBar: Bool
    
    @Binding var hasText: Bool
    
    func makeCoordinator() -> Coordinator {
        if isNewContent {
            return Coordinator(self, textStorage: newTextStorage)
        }
        
        return Coordinator(self, textStorage: self.existedTextStorage)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let layoutManager = NSLayoutManager()
        let containerSize = CGSize(width: 300, height: 200)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true
        layoutManager.addTextContainer(container)
        
        if isNewContent {
            newTextStorage.addLayoutManager(layoutManager)
        } else {
            self.existedTextStorage.addLayoutManager(layoutManager)
        }
        
        let myTextView = UITextView(frame: CGRect(x: 0, y:0, width: 1024, height: 768), textContainer: container)
        myTextView.delegate = context.coordinator
        if isNewContent {
            myTextView.font = TextViewHelper.getHelveticaNeueFont(isBold: isBold)
        }
        myTextView.textColor = UIColor(named: "textColor")!
        myTextView.isScrollEnabled = true
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = isEditable ? true : false
        myTextView.backgroundColor = .clear
        myTextView.textContainerInset = UIEdgeInsets.zero
        myTextView.textContainer.lineFragmentPadding = 0
        
        //        DispatchQueue.main.async {
        //            if self.isNewContent == false {
        //                let newDesiredHeight = ceil(TextViewHelper.calculateTextViewHeight(textView: myTextView))
        //                if newDesiredHeight != self.desiredHeight {
        //                    self.desiredHeight = newDesiredHeight
        //                }
        //
        //            } else {
        //                if self.isOmniBar {
        //                    self.desiredHeight = ceil(TextViewHelper.calculateTextViewHeight(textView: myTextView))
        //                }
        //            }
        //        }
        //
        return myTextView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        
        // there is a bug with this
        if self.didBecomeFirstResponder && !self.isFirstResponder {
            DispatchQueue.main.async {
                self.isFirstResponder = true
                self.didBecomeFirstResponder = false
                uiView.becomeFirstResponder()
            }
        }
        
        let leftCaretPos = uiView.selectedRange.location
        let rightCaretPos = uiView.selectedRange.location + uiView.selectedRange.length
        
        if uiView.isUserInteractionEnabled != isEditable {
            uiView.isUserInteractionEnabled = isEditable
        }
        
        if didChangeBold == true {
            if isBold == true {
                uiView.textStorage.addAttributes([.font: TextViewHelper.getHelveticaNeueFont(isBold: true, isItalic: isItalic)], range: uiView.selectedRange)
                if isItalic == true {
                    uiView.typingAttributes[NSAttributedString.Key.font] = TextViewHelper.getHelveticaNeueFont(isBold: true, isItalic: true)
                } else {
                    uiView.typingAttributes[NSAttributedString.Key.font] = TextViewHelper.getHelveticaNeueFont(isBold: true, isItalic: false)
                }
            } else {
                uiView.textStorage.addAttributes([.font: TextViewHelper.getHelveticaNeueFont(isBold: false, isItalic: isItalic)], range: uiView.selectedRange)
                
                if isItalic == true {
                    uiView.typingAttributes[NSAttributedString.Key.font] = TextViewHelper.getHelveticaNeueFont(isBold: false, isItalic: true)
                } else {
                    uiView.typingAttributes[NSAttributedString.Key.font] = TextViewHelper.getHelveticaNeueFont(isBold: false, isItalic: false)
                }
            }
            setDidChangeBold(to: false)
        }
        
        if didChangeItalic == true {
            if isItalic == true {
                uiView.textStorage.addAttributes([.font: TextViewHelper.getHelveticaNeueFont(isBold: isBold, isItalic: true)], range: uiView.selectedRange)
                
                if isBold == true {
                    uiView.typingAttributes[NSAttributedString.Key.font] = TextViewHelper.getHelveticaNeueFont(isBold: true, isItalic: true)
                } else {
                    uiView.typingAttributes[NSAttributedString.Key.font] = TextViewHelper.getHelveticaNeueFont(isBold: false, isItalic: true)
                }
            } else {
                uiView.textStorage.addAttributes([.font: TextViewHelper.getHelveticaNeueFont(isBold: isBold, isItalic: false)], range: uiView.selectedRange)
                
                if isBold == true {
                    uiView.typingAttributes[NSAttributedString.Key.font] = TextViewHelper.getHelveticaNeueFont(isBold: true, isItalic: false)
                } else {
                    uiView.typingAttributes[NSAttributedString.Key.font] = TextViewHelper.getHelveticaNeueFont(isBold: false, isItalic: false)
                }
            }
            
            setDidChangeItalic(to: false)
        }
        
        if didChangeStrikethrough == true {
            if isStrikethrough == true {
                uiView.textStorage.addAttributes([.strikethroughStyle: NSUnderlineStyle.single.rawValue], range: uiView.selectedRange)
                uiView.typingAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            } else {
                uiView.textStorage.removeAttribute(.strikethroughStyle, range: uiView.selectedRange)
                uiView.typingAttributes.removeValue(forKey: NSAttributedString.Key.strikethroughStyle)
            }
            
            setDidChangeStrikethrough(to: false)
        }
        
        if didChangeNumberedBulletList == true {
            if leftCaretPos == rightCaretPos {
                TextViewHelper.findLineAndReplaceWithBulletLine(isNumbered: true, leftCaretPos: leftCaretPos, textStorage: uiView.textStorage, uiView: uiView)
                
                uiView.typingAttributes[.paragraphStyle] = TextViewHelper.getBulletListParagraphStyle()
                uiView.typingAttributes[NSAttributedString.Key.numberedListAttribute] = true
                setDidChangeNumberedBulletList(to: false)
            } else {
                let selectedStr = uiView.textStorage.attributedSubstring(from: uiView.selectedRange)
                uiView.textStorage.replaceCharacters(in: uiView.selectedRange, with: TextViewHelper.getFormattedBulletListAttributedString(isNumbered: true, selectedStr: selectedStr))
                
                uiView.typingAttributes[.paragraphStyle] = TextViewHelper.getBulletListParagraphStyle()
                uiView.typingAttributes[NSAttributedString.Key.numberedListAttribute] = true
                setDidChangeNumberedBulletList(to: false)
            }
        }
        
        if didChangeBulletList == true {
            if leftCaretPos == rightCaretPos {
                TextViewHelper.findLineAndReplaceWithBulletLine(isNumbered: false, leftCaretPos: leftCaretPos, textStorage: uiView.textStorage, uiView: uiView)
                
                uiView.typingAttributes[.paragraphStyle] = TextViewHelper.getBulletListParagraphStyle()
                setDidChangeNumberedBulletList(to: false)
            } else {
                let selectedStr = uiView.textStorage.attributedSubstring(from: uiView.selectedRange)
                uiView.textStorage.replaceCharacters(in: uiView.selectedRange, with: TextViewHelper.getFormattedBulletListAttributedString(isNumbered: false, selectedStr: selectedStr))
                
                uiView.typingAttributes[.paragraphStyle] = TextViewHelper.getBulletListParagraphStyle()
                setDidChangeNumberedBulletList(to: false)
            }
        }
    }
    
    func setDidChangeBold(to status: Bool) {
        DispatchQueue.main.async {
            self.didChangeBold = status
        }
    }
    
    func setDidChangeItalic(to status: Bool) {
        DispatchQueue.main.async {
            self.didChangeItalic = status
        }
    }
    
    func setDidChangeStrikethrough(to status: Bool) {
        DispatchQueue.main.async {
            self.didChangeStrikethrough = status
        }
    }
    
    func setDidChangeNumberedBulletList(to status: Bool) {
        DispatchQueue.main.async {
            self.didChangeNumberedBulletList = status
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView
        var textStorage: NSTextStorage
        
        init(_ textView: TextView, textStorage: NSTextStorage) {
            self.parent = textView
            self.textStorage = textStorage
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let leftCaretPos = textView.selectedRange.location
            let k = textView.selectedRange.length
            //let rightCaretPos = leftCaretPos + k - 1
            
            if self.parent.isNumberedBulletList == true {
                let enumerateKey = NSAttributedString.Key.numberedListAttribute
                let enumerateHeaderKey = NSAttributedString.Key.numberHeaderInBulletList
                
                if text == "\n" { // new line
                    TextViewHelper.formatNewLineAndAdjustCursor(isNumbered: true, leftCaretPos: leftCaretPos, enumerateKey: enumerateKey, enumerateHeaderKey: enumerateHeaderKey, textStorage: self.textStorage, textView: textView)
                    updateTextViewHeight(textView: textView)
                    return false
                } else if text == "" && range.length == 1 && k == 0 {
                    let isRightSideCaret = TextViewHelper.isRightSideCaret(at: leftCaretPos, textStorage: self.textStorage)
                    let lineStartIndex = TextViewHelper.getListLineStart(index: leftCaretPos, isRightSideCaret: isRightSideCaret, textStorage: textStorage, enumerateHeaderKey: enumerateHeaderKey)
                    let lineNumberRangeTuple : (start: Int, end: Int) = TextViewHelper.getLineHeaderRange(enumerateHeaderKey: enumerateHeaderKey, index: lineStartIndex, textStorage: textStorage)
                    
                    if leftCaretPos == lineNumberRangeTuple.end + TextViewHelper.getBulletListIndentStr().count + 1 {
                        TextViewHelper.deleteLineBackspace(isNumbered: true, leftCaretPos: leftCaretPos, enumerateKey: enumerateKey, enumerateHeaderKey: enumerateHeaderKey, textStorage: self.textStorage, textView: textView, isRightSideCaret: isRightSideCaret, lineNumberRangeTuple: lineNumberRangeTuple)
                        updateTextViewHeight(textView: textView)
                        return false
                    }
                }
            }
            
            if self.parent.isDashBulletList == true {
                let enumerateKey = NSAttributedString.Key.dashListAttribute
                let enumerateHeaderKey = NSAttributedString.Key.dashHeaderInBulletList
                
                if text == "\n" {
                    TextViewHelper.formatNewLineAndAdjustCursor(isNumbered: false, leftCaretPos: leftCaretPos, enumerateKey: enumerateKey, enumerateHeaderKey: enumerateHeaderKey, textStorage: self.textStorage, textView: textView)
                    
                    updateTextViewHeight(textView: textView)
                    return false
                } else if text == "" && range.length == 1 && k == 0 {
                    let isRightSideCaret = TextViewHelper.isRightSideCaret(at: leftCaretPos, textStorage: self.textStorage)
                    let lineStartIndex = TextViewHelper.getListLineStart(index: leftCaretPos, isRightSideCaret: isRightSideCaret, textStorage: textStorage, enumerateHeaderKey: enumerateHeaderKey)
                    let lineNumberRangeTuple : (start: Int, end: Int) = TextViewHelper.getLineHeaderRange(enumerateHeaderKey: enumerateHeaderKey, index: lineStartIndex, textStorage: textStorage)
                    
                    if leftCaretPos == lineNumberRangeTuple.end + TextViewHelper.getDashBulletListIndentStr().count + 1 {
                        TextViewHelper.deleteLineBackspace(isNumbered: false, leftCaretPos: leftCaretPos, enumerateKey: enumerateKey , enumerateHeaderKey: enumerateHeaderKey, textStorage: self.textStorage, textView: textView, isRightSideCaret: isRightSideCaret, lineNumberRangeTuple: lineNumberRangeTuple)
                        
                        updateTextViewHeight(textView: textView)
                        return false
                    }
                }
            }
            
            return true
        }
        
        func updateTextViewHeight(textView: UITextView) {
            
            if self.parent.isNewContent == false {
                if self.parent.isThread == true {
                    let newHeight = ceil(TextViewHelper.calculateTextViewHeight(textView: textView))
                    if newHeight != self.parent.desiredHeight {
                        DispatchQueue.main.async {
                            self.parent.desiredHeight = newHeight
                        }
                    }
                } else {
                    let newHeight =  ceil(TextViewHelper.calculateTextViewHeight(textView: textView))
                    if newHeight != self.parent.desiredHeight {
                        DispatchQueue.main.async {
                            self.parent.desiredHeight = newHeight
                        }
                    }
                }
            } else {
                if self.parent.isOmniBar == true {
                    let newHeight = ceil(TextViewHelper.calculateTextViewHeight(textView: textView))
                    
                    if newHeight != self.parent.desiredHeight {
                        DispatchQueue.main.async {
                            self.parent.desiredHeight = newHeight
                        }
                    }
                }
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            
            let hasText = textView.textStorage.length > 0
            if self.parent.hasText != hasText {
                self.parent.hasText = hasText
            }
            
            updateTextViewHeight(textView: textView)
            //            not needed - textStorage state already receives update via binding
            //            DispatchQueue.main.async {
            //                self.parent.textStorage = textView.textStorage
            //            }
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            if parent.isEditable == false {
                return
            }
            
            let leftCaretPos = textView.selectedRange.location
            let k = textView.selectedRange.length
            let rightCaretPos = leftCaretPos + k
            
            //            let startTime1 = CFAbsoluteTimeGetCurrent()
            let isRightSideCaret = TextViewHelper.isRightSideCaret(at: leftCaretPos, textStorage: self.textStorage)
            
            var nextBoldState = false
            var nextItalicState = false
            var nextStrikethroughState = false
            
            var nextNumberedListState = false
            var nextDashListState = false
            
            if k > 0 {
                nextBoldState = TextViewHelper.isAllBoldInSubstring(s: textStorage.attributedSubstring(from: NSMakeRange(leftCaretPos, k))) ? true : false
                nextItalicState = TextViewHelper.isAllItalicInSubstring(s: textStorage.attributedSubstring(from: NSMakeRange(leftCaretPos, k))) ? true : false
                nextStrikethroughState = TextViewHelper.isAllContainAttributeInSubstring(enumerateKey: NSAttributedString.Key.strikethroughStyle, s: textStorage.attributedSubstring(from: NSMakeRange(leftCaretPos, k))) ? true : false
                
                nextNumberedListState = TextViewHelper.isAllContainAttributeInSubstring(enumerateKey: NSAttributedString.Key.numberedListAttribute, s: textStorage.attributedSubstring(from: NSMakeRange(leftCaretPos, k))) ? true : false
                nextDashListState = TextViewHelper.isAllContainAttributeInSubstring(enumerateKey: NSAttributedString.Key.dashListAttribute, s: textStorage.attributedSubstring(from: NSMakeRange(leftCaretPos, k))) ? true : false
                
                let isLeftSelectInNumberedList = TextViewHelper.isLastCharAttribute(attribute: NSAttributedString.Key.numberedListAttribute, index: leftCaretPos, isRightSideCaret: false, textStorage: textStorage) ? true : false
                let isRightSelectInNumberedList = TextViewHelper.isLastCharAttribute(attribute: NSAttributedString.Key.numberedListAttribute, index: rightCaretPos, isRightSideCaret: true, textStorage: textStorage) ? true : false
                
                if isLeftSelectInNumberedList == true {
                    TextViewHelper.adjustLeftCursorFromForbiddenSpace(leftCaretPos: leftCaretPos, textStorage: textStorage, k: k, textView: textView, isNumberedList: true)
                }
                
                if isRightSelectInNumberedList == true {
                    TextViewHelper.adjustRightCursorFromForbiddenSpace(rightCaretPos: rightCaretPos, textStorage: textStorage, k: k, textView: textView, isNumberedList: true)
                }
                
                let isLeftSelectInDashList = TextViewHelper.isLastCharAttribute(attribute: NSAttributedString.Key.dashListAttribute, index: leftCaretPos, isRightSideCaret: false, textStorage: textStorage) ? true : false
                let isRightSelectInDashList = TextViewHelper.isLastCharAttribute(attribute: NSAttributedString.Key.dashListAttribute, index: rightCaretPos, isRightSideCaret: true, textStorage: textStorage) ? true : false
                
                if isLeftSelectInDashList == true {
                    TextViewHelper.adjustLeftCursorFromForbiddenSpace(leftCaretPos: leftCaretPos, textStorage: textStorage, k: k, textView: textView, isNumberedList: false)
                }
                
                if isRightSelectInDashList == true {
                    TextViewHelper.adjustRightCursorFromForbiddenSpace(rightCaretPos: rightCaretPos, textStorage: textStorage, k: k, textView: textView, isNumberedList: false)
                }
                
            } else {
                let lastAttributedChar = TextViewHelper.getLastChar(index: leftCaretPos, isRightSideCaret: isRightSideCaret, textStorage: textStorage)
                
                if lastAttributedChar != nil {
                    let font = lastAttributedChar!.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
                    nextBoldState = font.isBold ? true : false
                    nextItalicState = font.isItalic ? true : false
                    nextStrikethroughState = lastAttributedChar!.attribute(NSAttributedString.Key.strikethroughStyle, at: 0, effectiveRange: nil) != nil ? true : false
                    nextNumberedListState = lastAttributedChar!.attribute(NSAttributedString.Key.numberedListAttribute, at: 0, effectiveRange: nil) != nil ? true : false
                    nextDashListState = lastAttributedChar!.attribute(NSAttributedString.Key.dashListAttribute, at: 0, effectiveRange: nil) != nil ? true : false
                    
                    if nextNumberedListState == true || nextDashListState == true {
                        TextViewHelper.adjustLeftCursorFromForbiddenSpace(leftCaretPos: leftCaretPos, textStorage: textStorage, k: k, textView: textView, isNumberedList: nextNumberedListState ? true : false)
                    }
                }
            }
            
            setBoldState(to: nextBoldState)
            setDidChangeBold(to: false)
            
            setItalicState(to: nextItalicState)
            setDidChangeItalic(to: false)
            
            setStrikethroughState(to: nextStrikethroughState)
            setDidChangeStrikethrough(to: false)
            
            setNumberedBulletListState(to: nextNumberedListState)
            setDidChangeNumberedBulletList(to: false)
            
            setDashBulletListState(to: nextDashListState)
            setDidChangeDashBulletList(to: false)
            
            //            let timeElapsed1 = CFAbsoluteTimeGetCurrent() - startTime1
        }
        
        func setDidChangeBold(to status: Bool) {
            if self.parent.didChangeBold == status {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.didChangeBold = status
            }
        }
        
        func setDidChangeItalic(to status: Bool) {
            if self.parent.didChangeBold == status {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.didChangeBold = status
            }
        }
        
        func setDidChangeStrikethrough(to status: Bool) {
            if self.parent.didChangeStrikethrough == status {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.didChangeStrikethrough = status
            }
        }
        
        
        func setDidChangeNumberedBulletList(to status: Bool) {
            if self.parent.didChangeNumberedBulletList == status {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.didChangeNumberedBulletList = status
            }
        }
        
        func setDidChangeDashBulletList(to status: Bool) {
            if self.parent.didChangeBulletList == status {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.didChangeBulletList = status
            }
        }
        
        func setBoldState(to status: Bool) {
            if self.parent.isBold == status {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.isBold = status
            }
        }
        
        func setItalicState(to status: Bool) {
            if self.parent.isItalic == status {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.isItalic = status
            }
        }
        
        func setStrikethroughState(to status: Bool) {
            if self.parent.isStrikethrough == status {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.isStrikethrough = status
            }
        }
        
        func setNumberedBulletListState(to status: Bool) {
            if self.parent.isNumberedBulletList == status {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.isNumberedBulletList = status
            }
        }
        
        func setDashBulletListState(to status: Bool) {
            if self.parent.isDashBulletList == status {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.isDashBulletList = status
            }
        }
    }
}
