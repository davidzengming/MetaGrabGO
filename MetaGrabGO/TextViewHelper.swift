//
//  TextViewHelper.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-01-28.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI

class TextViewHelper {
    static var attrMap : [[NSAttributedString.Key: Bool] : Int]?
    
    static func calculateTextViewHeight(textView: UITextView) -> CGFloat {
        // Compute the desired height for the content
        
//        let startTime1 = CFAbsoluteTimeGetCurrent()
        let newSize1 = textView.contentSize.height
//        let timeElapsed1 = CFAbsoluteTimeGetCurrent() - startTime1
        
//        let startTime2 = CFAbsoluteTimeGetCurrent()
//        let fixedWidth = textView.frame.size.width
//        let newSize2 = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        let timeElapsed2 = CFAbsoluteTimeGetCurrent() - startTime2
//        print("contentsize: ", timeElapsed1, " ||||||| sizethatfits: ", timeElapsed2)
        return newSize1
    }
    
    // external func
    static func splitAttributedString(inputString: NSAttributedString, seperateBy: String) -> [NSAttributedString] {
        let input = inputString.string
        let separatedInput = input.components(separatedBy: seperateBy)
        var output = [NSAttributedString]()
        var start = 0
        for sub in separatedInput {
            let range = NSMakeRange(start, sub.utf16.count)
            let attribStr = inputString.attributedSubstring(from: range)
            output.append(attribStr)
            start += range.length + seperateBy.count
        }
        return output
    }
    
    static func getBulletListIndentStr() -> String {
        return ".\t"
    }
    
    static func getDashBulletListIndentStr() -> String {
        return "\t"
    }
    
    static func getDash() -> String {
        return "-"
    }
    
    static func getFormattedBulletListAttributedString(isNumbered: Bool, selectedStr: NSAttributedString) -> NSMutableAttributedString {
        let lines = splitAttributedString(inputString: selectedStr, seperateBy: "\n")
        var count : Int = 1
        let dash = NSMutableAttributedString(string: getDash(), attributes: [NSAttributedString.Key.dashHeaderInBulletList: true, NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)])
        
        let attributedRes = NSMutableAttributedString(string: "")
        for (index, line) in lines.enumerated() {
            
            let endOfLine = index == lines.count - 1 ? NSMutableAttributedString(string: "") : NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)])
            let attributedLine = NSMutableAttributedString(string: isNumbered ? getBulletListIndentStr() : getDashBulletListIndentStr(), attributes: [ NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)])
            
            attributedLine.append(line)
            attributedLine.append(endOfLine)
            
            attributedRes.append(isNumbered ? NSMutableAttributedString(string: String(count), attributes: [NSAttributedString.Key.numberHeaderInBulletList: true, NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)]) : dash)
            attributedRes.append(attributedLine)
            count += 1
        }
        
        if isNumbered {
            attributedRes.addAttributes([NSAttributedString.Key.paragraphStyle: getBulletListParagraphStyle(), NSAttributedString.Key.numberedListAttribute: true], range: NSMakeRange(0, attributedRes.length))
        } else {
            attributedRes.addAttributes([NSAttributedString.Key.paragraphStyle: getBulletListParagraphStyle(), NSAttributedString.Key.dashListAttribute: true], range: NSMakeRange(0, attributedRes.length))
        }
        
        return attributedRes
    }
    
    static func formatNewLineAndAdjustCursor(isNumbered: Bool, leftCaretPos: Int, enumerateKey: NSAttributedString.Key, enumerateHeaderKey: NSAttributedString.Key, textStorage: NSTextStorage, textView: UITextView) {
        let isRightSideCaret = self.isRightSideCaret(at: leftCaretPos, textStorage: textStorage)
        let lineStartIndex = getListLineStart(index: leftCaretPos, isRightSideCaret: isRightSideCaret, textStorage: textStorage, enumerateHeaderKey: enumerateHeaderKey)
        
        let currLineNumIndexes: (start: Int, end: Int) = getLineHeaderRange(enumerateHeaderKey: enumerateHeaderKey, index: lineStartIndex, textStorage: textStorage)
        let currLineNum = isNumbered ? convertAttributeStrToInt(s: textStorage.attributedSubstring(from: NSMakeRange(currLineNumIndexes.start, currLineNumIndexes.end - currLineNumIndexes.start + 1))) : -1
        
        let endOfList = getListEnd(index: leftCaretPos, isRightSideCaret: TextViewHelper.isRightSideCaret(at: leftCaretPos, textStorage: textView.textStorage), textStorage: textStorage, enumerateKey: enumerateKey)
        
        var replacementTextAndOffset: (replacementText: NSAttributedString, offset: Int)
        if endOfList >= leftCaretPos {
            replacementTextAndOffset = getReplacementListNumbersTextAndInsertCursorOffset(isNumbered: isNumbered, s: textStorage.attributedSubstring(from: NSMakeRange(leftCaretPos, endOfList - leftCaretPos)), counter: currLineNum, isInsertingNewLine: true)
            
            textStorage.replaceCharacters(in: NSMakeRange(leftCaretPos, endOfList - leftCaretPos), with: replacementTextAndOffset.replacementText)
        } else {
            replacementTextAndOffset = getReplacementListNumbersTextAndInsertCursorOffset(isNumbered: isNumbered, s: NSAttributedString(string: ""), counter: currLineNum, isInsertingNewLine: true)
            textStorage.replaceCharacters(in: NSMakeRange(leftCaretPos, 0), with: replacementTextAndOffset.replacementText)
        }
        
        textView.selectedRange = NSMakeRange(leftCaretPos + replacementTextAndOffset.offset, 0)
    }
    
    static func deleteLineBackspace(isNumbered: Bool, leftCaretPos: Int, enumerateKey: NSAttributedString.Key, enumerateHeaderKey: NSAttributedString.Key, textStorage: NSTextStorage, textView: UITextView, isRightSideCaret: Bool, lineNumberRangeTuple: (start: Int, end: Int)) {
        let endOfLine = getListLineEnd(index: leftCaretPos, isRightSideCaret: isRightSideCaret, textStorage: textStorage, enumerateHeaderKey: enumerateHeaderKey)
        let endOfList = getListEnd(index: leftCaretPos, isRightSideCaret: isRightSideCaret, textStorage: textStorage, enumerateKey: enumerateKey)
        
        let startOfLine = getListLineStart(index: leftCaretPos, isRightSideCaret: isRightSideCaret, textStorage: textStorage, enumerateHeaderKey: enumerateHeaderKey)
        let startOfList = getListStart(index: leftCaretPos, isRightSideCaret: isRightSideCaret, textStorage: textStorage, enumerateKey: enumerateKey)
        
        let currLineNum = isNumbered ? convertAttributeStrToInt(s: textStorage.attributedSubstring(from: NSMakeRange(lineNumberRangeTuple.start, lineNumberRangeTuple.end - lineNumberRangeTuple.start + 1))) : -1
        
        let currentLineString: NSMutableAttributedString
        if endOfLine < leftCaretPos {
            currentLineString = NSMutableAttributedString(string: "")
        } else if startOfLine == startOfList {
            currentLineString = NSMutableAttributedString(attributedString: textStorage.attributedSubstring(from: NSMakeRange(leftCaretPos, endOfLine != endOfList ? endOfLine - leftCaretPos: endOfLine - leftCaretPos + 1)))
            currentLineString.addAttributes([NSAttributedString.Key.paragraphStyle: TextViewHelper.getPlainParagraphStyle()], range: NSMakeRange(0, currentLineString.length))
            
            if isNumbered {
                currentLineString.removeAttribute(NSAttributedString.Key.numberedListAttribute, range: NSMakeRange(0, currentLineString.length))
            } else {
                currentLineString.removeAttribute(NSAttributedString.Key.dashListAttribute, range: NSMakeRange(0, currentLineString.length))
            }
            
        } else {
            currentLineString = NSMutableAttributedString(attributedString: textStorage.attributedSubstring(from: NSMakeRange(leftCaretPos, endOfLine != endOfList ? endOfLine - leftCaretPos: endOfLine - leftCaretPos + 1)))
            
            currentLineString.addAttributes([NSAttributedString.Key.paragraphStyle: TextViewHelper.getBulletListParagraphStyle()], range: NSMakeRange(0, currentLineString.length))
            
            if isNumbered {
                currentLineString.addAttributes([NSAttributedString.Key.numberedListAttribute: true], range: NSMakeRange(0, currentLineString.length))
            } else {
                currentLineString.addAttributes([NSAttributedString.Key.dashListAttribute: true], range: NSMakeRange(0, currentLineString.length))
            }
        }
        
        var replacementTextAndCursorOffsetTuple: (replacementText: NSMutableAttributedString, offset: Int)
        
        if endOfList > endOfLine {
            replacementTextAndCursorOffsetTuple = TextViewHelper.getReplacementListNumbersTextAndInsertCursorOffset(isNumbered: isNumbered, s: textStorage.attributedSubstring(from: NSMakeRange(endOfLine + 1, endOfList - (endOfLine + 1) + 1)), counter: currentLineString.length == 0 ? 1 : currLineNum, isInsertingNewLine: false)
        } else {
            replacementTextAndCursorOffsetTuple = (NSMutableAttributedString(string: ""), 0)
        }
        
        let concatNewString = currentLineString.length == 0 && replacementTextAndCursorOffsetTuple.replacementText.length != 0 ? NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.paragraphStyle: getPlainParagraphStyle(), NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)]) : NSMutableAttributedString(string: "")
        concatNewString.append(currentLineString)
        
        if currentLineString.length != 0 && replacementTextAndCursorOffsetTuple.replacementText.length != 0 {
            
            var newLineChar = NSAttributedString(string: "")
            if startOfLine != startOfList {
                newLineChar = isNumbered ? NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.paragraphStyle: getBulletListParagraphStyle(), NSAttributedString.Key.numberedListAttribute: true, NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)]) : NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.paragraphStyle: getBulletListParagraphStyle(), NSAttributedString.Key.dashListAttribute: true, NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)])
            } else {
                newLineChar = NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.paragraphStyle: getPlainParagraphStyle(), NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)])
            }
            
            concatNewString.append(newLineChar)
        }
        concatNewString.append(replacementTextAndCursorOffsetTuple.replacementText)
        
        //let startOfList = getListStart(index: leftCaretPos, isRightSideCaret: TextViewHelper.isRightSideCaret(at: leftCaretPos, textStorage: textStorage), textStorage: textStorage, enumerateKey: NSAttributedString.Key.numberedListAttribute)
        let replaceLeftPos = currentLineString.length == 0 || startOfLine == startOfList ? lineNumberRangeTuple.start : lineNumberRangeTuple.start - 1
        
        if endOfList != -1 {
            textStorage.replaceCharacters(in: NSMakeRange(replaceLeftPos, endOfList - replaceLeftPos + 1), with: concatNewString)
        } else {
            textStorage.replaceCharacters(in: NSMakeRange(replaceLeftPos, leftCaretPos - replaceLeftPos - 1), with: concatNewString)
        }
        
        textView.selectedRange = NSMakeRange(currentLineString.length == 0 || startOfLine == startOfList ? lineNumberRangeTuple.start: lineNumberRangeTuple.start - 1, 0)
    }
    
    static func adjustLeftCursorFromForbiddenSpace(leftCaretPos: Int, textStorage: NSTextStorage, k: Int, textView: UITextView, isNumberedList: Bool) {
        let enumerateHeaderKey = isNumberedList ? NSAttributedString.Key.numberHeaderInBulletList : NSAttributedString.Key.dashHeaderInBulletList
        
        let indentStrLength = isNumberedList ? getBulletListIndentStr().count : getDashBulletListIndentStr().count
        
        let lineStartIndex = TextViewHelper.getListLineStart(index: leftCaretPos, isRightSideCaret: false, textStorage: textStorage, enumerateHeaderKey: enumerateHeaderKey)
        let lineNumStartEnd = TextViewHelper.getLineHeaderRange(enumerateHeaderKey: enumerateHeaderKey, index: lineStartIndex, textStorage: textStorage)
        
        if lineNumStartEnd.0 <= leftCaretPos && leftCaretPos <= lineNumStartEnd.1 + indentStrLength {
            let updatedLeftCaretPosition = lineNumStartEnd.1 + indentStrLength + 1
            textView.selectedRange = NSMakeRange(updatedLeftCaretPosition, k - (updatedLeftCaretPosition - leftCaretPos))
        }
    }
    
    static func adjustRightCursorFromForbiddenSpace(rightCaretPos: Int, textStorage: NSTextStorage, k: Int, textView: UITextView, isNumberedList: Bool) {
        let enumerateHeaderKey = isNumberedList ? NSAttributedString.Key.numberHeaderInBulletList : NSAttributedString.Key.dashHeaderInBulletList
        
        let indentStrLength = isNumberedList ? getBulletListIndentStr().count : getDashBulletListIndentStr().count
        let lineStartIndex = TextViewHelper.getListLineStart(index: rightCaretPos, isRightSideCaret: true, textStorage: textStorage, enumerateHeaderKey: enumerateHeaderKey)
        let lineNumStartEnd = TextViewHelper.getLineHeaderRange(enumerateHeaderKey: enumerateHeaderKey, index: lineStartIndex, textStorage: textStorage)
        if lineNumStartEnd.0 <= rightCaretPos && rightCaretPos <= lineNumStartEnd.1 + indentStrLength - 1 {
            let updatedRightCaretPosition = lineNumStartEnd.1 + indentStrLength
            textView.selectedRange = NSMakeRange(textView.selectedRange.location, k + updatedRightCaretPosition - rightCaretPos)
        }
    }
    
    static func findLineAndReplaceWithBulletLine(isNumbered: Bool, leftCaretPos: Int, textStorage: NSTextStorage, uiView: UITextView) {
        if uiView.textStorage.length == 0 {
            return
        }
        
        let isRightSideCaret = TextViewHelper.isRightSideCaret(at: leftCaretPos, textStorage: uiView.textStorage)
        
        let pos = isRightSideCaret ? leftCaretPos - 1 : leftCaretPos
        
        var lineStartIndex: Int
        if pos == -1 {
            lineStartIndex = 0
        } else {
            let newLineCharFoundRange = uiView.textStorage.mutableString.range(of: "\n", options: .backwards, range: NSMakeRange(0, pos + 1))
            lineStartIndex = newLineCharFoundRange.location != NSNotFound ? newLineCharFoundRange.location + 1 : 0
        }
        
        var lineEndIndex: Int
        if pos == uiView.textStorage.length {
            lineEndIndex = uiView.textStorage.length - 1
        } else {
            let newLineCharFoundRange = uiView.textStorage.mutableString.range(of: "\n", range: NSMakeRange(pos, uiView.textStorage.length - pos))
            lineEndIndex = newLineCharFoundRange.location != NSNotFound ? newLineCharFoundRange.location : uiView.textStorage.length - 1
        }
        
        let replacementText = TextViewHelper.getFormattedBulletListAttributedString(isNumbered: isNumbered, selectedStr: uiView.textStorage.attributedSubstring(from: NSMakeRange(lineStartIndex, lineEndIndex - lineStartIndex + 1)))
        
        if uiView.textStorage.length - 1 > lineEndIndex {
            if isNumbered {
                replacementText.append(NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.numberedListAttribute: true, NSAttributedString.Key.paragraphStyle: TextViewHelper.getBulletListParagraphStyle(), NSAttributedString.Key.font: TextViewHelper.getHelveticaNeueFont(isBold: false)]))
            } else {
                replacementText.append(NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.dashListAttribute: true, NSAttributedString.Key.paragraphStyle: TextViewHelper.getBulletListParagraphStyle(), NSAttributedString.Key.font: TextViewHelper.getHelveticaNeueFont(isBold: false)]))
            }
        }
        
        uiView.textStorage.replaceCharacters(in: NSMakeRange(lineStartIndex, lineEndIndex - lineStartIndex + 1), with: replacementText)
        uiView.selectedRange = NSMakeRange(lineStartIndex + (isNumbered ? getBulletListIndentStr().count + 1 : getDashBulletListIndentStr().count + 1), 0)
    }
    
    static var boldItalicFont = UIFont(name: "HelveticaNeue-BoldItalic", size: 16)!
    static var italicFont = UIFont(name: "HelveticaNeue-Italic", size: 16)!
    static var boldFont = UIFont(name: "HelveticaNeue-Bold", size: 16)!
    static var normalFont = UIFont(name: "HelveticaNeue", size: 16)!
    
    static func getHelveticaNeueFont(isBold: Bool, isItalic: Bool = false) -> UIFont {
        if isItalic == true {
            return isBold ? self.boldItalicFont : self.italicFont
        } else {
            return isBold ? self.boldFont : self.normalFont
        }
    }
    
    
    static var bulletListParagraphStyle: NSMutableParagraphStyle = initBulletListParagraphStyle()
    static func initBulletListParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 10
        paragraphStyle.headIndent = 25
        paragraphStyle.lineSpacing = 3
        paragraphStyle.paragraphSpacing = 2
        paragraphStyle.paragraphSpacingBefore = 2
        
        return paragraphStyle
    }
    
    static func getBulletListParagraphStyle() -> NSMutableParagraphStyle {
        return bulletListParagraphStyle
    }
    
    static var plainParagraphStyle: NSMutableParagraphStyle = initPlainParagraphStyle()
    static func initPlainParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        return paragraphStyle
    }
    
    static func getPlainParagraphStyle() -> NSMutableParagraphStyle {
        return plainParagraphStyle
    }
    
    static func isRightSideCaret(at index: Int, textStorage: NSTextStorage) -> Bool {
        if index == 0 {
            return false
        }
        let prevChar = textStorage.attributedSubstring(from: NSMakeRange(index - 1, 1)).string
        
        if prevChar == "\t" || prevChar == "\n" {
            return false
        }
        return true
    }
    
    static var typingAttributes: [Int: [NSAttributedString.Key : Any]] = initTypingAttributesSettings()
    
    static func initTypingAttributesSettings() -> [Int: [NSAttributedString.Key : Any]] {
        var typingAttributes = [Int: [NSAttributedString.Key : Any]]()
        
        func dfs(mask: Int, i: Int, curAttributes: [NSAttributedString.Key : Any]) {
            
            typingAttributes[mask] = curAttributes
            
            if i == 5 {
                return
            }
            
            for j in i..<5 {
                var curAttributes2 = curAttributes
                
                if j == 0 {
                    curAttributes2[NSAttributedString.Key.font] = getHelveticaNeueFont(isBold: true, isItalic: false)
                } else if j == 1 {
                    if (mask >> 0) & 1 == 1 {
                        curAttributes2[NSAttributedString.Key.font] = getHelveticaNeueFont(isBold: true, isItalic: true)
                    } else {
                        curAttributes2[NSAttributedString.Key.font] = getHelveticaNeueFont(isBold: false, isItalic: true)
                    }
                } else if j == 2 {
                    curAttributes2[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                } else if j == 3 {
                    curAttributes2[.paragraphStyle] = getBulletListParagraphStyle()
                    curAttributes2[NSAttributedString.Key.numberedListAttribute] = true
                } else if j == 4 {
                    curAttributes2[.paragraphStyle] = getBulletListParagraphStyle()
                } else {
                    print("Error")
                }
                
                dfs(mask: mask | (1 << i), i: j + 1, curAttributes: curAttributes2)
            }
        }
        
        var initAttributes = [NSAttributedString.Key : Any]()
        initAttributes[NSAttributedString.Key.font] = getHelveticaNeueFont(isBold: false, isItalic: false)
        
        dfs(mask: 0, i: 0, curAttributes: initAttributes)
        return typingAttributes
    }
    
    static func prepareTypingAttributesSetting(textView: UITextView, isBold: Bool, isItalic: Bool, isStrikethrough: Bool, isBulletList: Bool, isNumberedList: Bool) {
        var mask = 0
        
        if isBold == true {
            mask = mask | (1 << 0)
        }
        
        if isItalic == true {
            mask = mask | (1 << 1)
        }
        
        if isStrikethrough == true {
            mask = mask | (1 << 2)
        }
        
        if isBulletList == true {
            mask = mask | (1 << 3)
        }
        
        if isNumberedList == true {
            mask = mask | (1 << 4)
        }
        
        textView.typingAttributes = typingAttributes[mask]!
        return
    }
    
    static func getReplacementListNumbersTextAndInsertCursorOffset(isNumbered: Bool, s: NSAttributedString, counter: Int, isInsertingNewLine: Bool) -> (NSMutableAttributedString, Int) {
        var counter = counter
        let res = NSMutableAttributedString(string: "")
        var moveCursorOffset = 0
        let dash = NSMutableAttributedString(string: getDash(), attributes: [NSAttributedString.Key.dashHeaderInBulletList: true, NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)])
        
        if isInsertingNewLine == true {
            res.append(NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)]))
            counter += 1
            
            res.append(isNumbered ? NSMutableAttributedString(string: String(counter), attributes: [NSAttributedString.Key.numberHeaderInBulletList: true, NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)]) : dash)
            
            res.append(isNumbered ? NSAttributedString(string: getBulletListIndentStr()) : NSAttributedString(string: getDashBulletListIndentStr()))
            moveCursorOffset = res.length
            counter += 1
        }
        
        s.enumerateAttribute(isNumbered ? NSAttributedString.Key.numberHeaderInBulletList : NSAttributedString.Key.dashHeaderInBulletList, in: NSMakeRange(0, s.length), options: .longestEffectiveRangeNotRequired) {
            value, range, stop in
            
            if value == nil {
                res.append(NSMutableAttributedString(attributedString: s.attributedSubstring(from: range)))
            } else {
                res.append(isNumbered ? NSMutableAttributedString(string: String(counter), attributes: [NSAttributedString.Key.numberHeaderInBulletList: true, NSAttributedString.Key.font: getHelveticaNeueFont(isBold: false)]) : dash)
                counter += 1
            }
        }
        
        res.addAttributes([NSAttributedString.Key.paragraphStyle: getBulletListParagraphStyle()], range: NSMakeRange(0, res.length))
        
        if isNumbered {
            res.addAttributes([NSAttributedString.Key.numberedListAttribute: true], range: NSMakeRange(0, res.length))
        } else {
            res.addAttributes([NSAttributedString.Key.dashListAttribute: true], range: NSMakeRange(0, res.length))
        }
        
        return (res, moveCursorOffset)
    }
    
    static func getListStart(index: Int, isRightSideCaret: Bool, textStorage: NSTextStorage, enumerateKey: NSAttributedString.Key) -> Int {
        if textStorage.length == 0 {
            return -1
        }
        
        if isRightSideCaret == false && index == textStorage.length {
            return getListStart(index: index - 1, isRightSideCaret: false, textStorage: textStorage, enumerateKey: enumerateKey)
        }
        
        var start = -1
        let currIndex = isRightSideCaret ? index - 1 : index
        
        textStorage.enumerateAttribute(enumerateKey, in: NSMakeRange(0, currIndex - 0 + 1), options: [.reverse, .longestEffectiveRangeNotRequired]) {
            value, range, stop in
            if value != nil {
                start = range.location
            } else {
                stop.pointee = true // return early
            }
        }
        return start
    }
    
    static func getListEnd(index: Int, isRightSideCaret: Bool, textStorage: NSTextStorage, enumerateKey: NSAttributedString.Key) -> Int {
        if textStorage.length == 0 {
            return -1
        }
        
        if (isRightSideCaret == false && index == textStorage.length) {
            return getListEnd(index: index - 1, isRightSideCaret: false, textStorage: textStorage, enumerateKey: enumerateKey)
        }
        
        var end = -1
        let currIndex = isRightSideCaret ? index - 1: index
        textStorage.enumerateAttribute(enumerateKey, in: NSMakeRange(currIndex, textStorage.length - currIndex), options: .longestEffectiveRangeNotRequired) {
            value, range, stop in
            if value != nil {
                end = range.location + range.length - 1
            } else {
                stop.pointee = true // return early
            }
        }
        return end
    }
    
    static func getListLineStart(index: Int, isRightSideCaret: Bool, textStorage: NSTextStorage, enumerateHeaderKey: NSAttributedString.Key) -> Int {
        if textStorage.length == 0 {
            return -1
        }
        
        if isRightSideCaret == false && index == textStorage.length {
            return getListLineStart(index: index - 1, isRightSideCaret: false, textStorage: textStorage, enumerateHeaderKey: enumerateHeaderKey)
        }
        
        var startOfLine = -1
        let currIndex = isRightSideCaret ? index - 1 : index
        
        textStorage.enumerateAttribute(enumerateHeaderKey, in: NSMakeRange(0, currIndex - 0 + 1), options: [.reverse, .longestEffectiveRangeNotRequired]) {
            value, range, stop in
            if value != nil {
                startOfLine = range.location
                stop.pointee = true // return early
            }
        }
        return startOfLine
    }
    
    static func getListLineEnd(index: Int, isRightSideCaret: Bool, textStorage: NSTextStorage, enumerateHeaderKey: NSAttributedString.Key) -> Int {
        if textStorage.length == 0 {
            return -1
        }
        if  (isRightSideCaret == false && index == textStorage.length) {
            return getListLineEnd(index: index - 1, isRightSideCaret: false, textStorage: textStorage, enumerateHeaderKey: enumerateHeaderKey)
        }
        
        var endOfLine = -1
        let currIndex = isRightSideCaret ? index - 1 : index
        
        textStorage.enumerateAttribute(enumerateHeaderKey, in: NSMakeRange(currIndex, textStorage.length - currIndex), options: [.longestEffectiveRangeNotRequired]) {
            value, range, stop in
            if value == nil {
                endOfLine = range.location + range.length - 1
                stop.pointee = true // return early
            } else {
                endOfLine = range.location + range.length - 1
            }
        }
        return endOfLine
    }
    
    static func getLastChar(index: Int, isRightSideCaret: Bool, textStorage: NSTextStorage) -> NSAttributedString? {
        if textStorage.length == 0 {
            return nil
        }
        
        if isRightSideCaret == false && index == textStorage.length {
            if textStorage.attributedSubstring(from: NSMakeRange(index - 1, 1)).string == "\n" {
                return nil
            }
            
            return getLastChar(index: index - 1, isRightSideCaret: false, textStorage: textStorage)
        }

        let currChar = textStorage.attributedSubstring(from: NSMakeRange(isRightSideCaret ? index - 1 : index, 1))
        
        return currChar
    }
    
    static func isLastCharAttribute(attribute: NSAttributedString.Key, index: Int, isRightSideCaret: Bool, textStorage: NSTextStorage) -> Bool {
        if textStorage.length == 0 {
            return false
        }
        
        if isRightSideCaret == false && index == textStorage.length {
            if textStorage.attributedSubstring(from: NSMakeRange(index - 1, 1)).string == "\n" {
                return false
            }
            
            return isLastCharAttribute(attribute: attribute, index: index - 1, isRightSideCaret: false, textStorage: textStorage)
        }

        let currChar = textStorage.attributedSubstring(from: NSMakeRange(isRightSideCaret ? index - 1 : index, 1))
        let hasNumberedListAttr = currChar.attribute(attribute, at: 0, effectiveRange: nil)
        
        return hasNumberedListAttr != nil ? true : false
    }
    
    static func isLastCharBold(index: Int, isRightSideCaret: Bool, textStorage: NSTextStorage) -> Bool {
        if textStorage.length == 0 {
            return false
        }
        if isRightSideCaret == false && index == textStorage.length {
            return isLastCharBold(index: index - 1, isRightSideCaret: false, textStorage: textStorage)
        }
        
        let lastCharacter = textStorage.attributedSubstring(from: NSMakeRange(isRightSideCaret ? index - 1 : index, 1))
        let font = lastCharacter.attribute(.font, at: 0, effectiveRange: nil)
        
        if font == nil {
            return false
        } else {
            let value = font as! UIFont
            if value.fontName.contains("Bold") {
                return true
            } else {
                return false
            }
        }
    }
    
    static func isLastCharItalic(index: Int, isRightSideCaret: Bool, textStorage: NSTextStorage) -> Bool {
        if textStorage.length == 0 {
            return false
        }
        if isRightSideCaret == false && index == textStorage.length {
            return isLastCharBold(index: index - 1, isRightSideCaret: false, textStorage: textStorage)
        }
        
        let lastCharacter = textStorage.attributedSubstring(from: NSMakeRange(isRightSideCaret ? index - 1 : index, 1))
        let font = lastCharacter.attribute(.font, at: 0, effectiveRange: nil)
        
        if font == nil {
            return false
        } else {
            let value = font as! UIFont
            if value.fontName.contains("Italic") {
                return true
            } else {
                return false
            }
        }
    }
    
    static func convertAttributeStrToInt(s: NSAttributedString) -> Int {
        let numInString = s.attributedSubstring(from: NSMakeRange(0, s.length)).string
        return Int(numInString)!
    }
    
    static func isAllBoldInSubstring(s: NSAttributedString) -> Bool {
        var isAllBolded = true
        s.enumerateAttribute(NSAttributedString.Key.font, in: NSMakeRange(0, s.length), options: .longestEffectiveRangeNotRequired) {
            value, range, stop in
            let font = value as! UIFont
            if !font.fontName.contains("Bold") {
                isAllBolded = false
                stop.pointee = true // return early
            }
        }
        return isAllBolded
    }
    
    static func isAllItalicInSubstring(s: NSAttributedString) -> Bool {
        var isAllItalic = true
        s.enumerateAttribute(NSAttributedString.Key.font, in: NSMakeRange(0, s.length), options: .longestEffectiveRangeNotRequired) {
            value, range, stop in
            let font = value as! UIFont
            if !font.fontName.contains("Italic") {
                isAllItalic = false
                stop.pointee = true // return early
            }
        }
        return isAllItalic
    }
    
    static func isAllContainAttributeInSubstring(enumerateKey: NSAttributedString.Key, s: NSAttributedString) -> Bool {
        var isAllContainAttribute = true
        s.enumerateAttribute(enumerateKey, in: NSMakeRange(0, s.length), options: .longestEffectiveRangeNotRequired) {
            value, range, stop in
            if value == nil {
                isAllContainAttribute = false
                stop.pointee = true // return early
            }
        }
        return isAllContainAttribute
    }
    
    static func getLineHeaderRange(enumerateHeaderKey: NSAttributedString.Key, index: Int, textStorage: NSTextStorage) -> (Int, Int) {
        var startOfNumberIndex = 0
        var endOfNumberIndex = 0
        
        textStorage.enumerateAttribute(enumerateHeaderKey, in: NSMakeRange(index, textStorage.length - index), options: [.longestEffectiveRangeNotRequired]) {
            value, range, stop in
            startOfNumberIndex = range.location
            endOfNumberIndex = range.location + range.length - 1
            stop.pointee = true // return early
        }
        
        return (startOfNumberIndex, endOfNumberIndex)
    }
    
    // network related functions
    static func getAttrCheckList() -> [Any] {
        let boldAttr = [NSAttributedString.Key.font: TextViewHelper.getHelveticaNeueFont(isBold: true, isItalic: false)]
        let italicAttr = [NSAttributedString.Key.font: TextViewHelper.getHelveticaNeueFont(isBold: false, isItalic: true)]
        
        let strikethroughAttr = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        
        let numberHeaderAttr = [NSAttributedString.Key.numberHeaderInBulletList: true]
        let numberBodyAttr = [NSAttributedString.Key.numberedListAttribute: true]
        
        let dashHeaderAttr = [NSAttributedString.Key.dashHeaderInBulletList: true]
        let dashBodyAttr = [NSAttributedString.Key.dashListAttribute: true]
        
        let attrCheckList : [Any] = [boldAttr, italicAttr, strikethroughAttr, numberHeaderAttr, numberBodyAttr, dashHeaderAttr, dashBodyAttr]
        return attrCheckList
    }
    
    static func getFontEncodingVal(font: UIFont) -> Int {
        if font == TextViewHelper.getHelveticaNeueFont(isBold: true, isItalic: false) {
            return Int(pow(2.0, 0)) // 1
        } else if font == TextViewHelper.getHelveticaNeueFont(isBold: false, isItalic: true) {
            return Int(pow(2.0, 1)) // 2
        } else if font == TextViewHelper.getHelveticaNeueFont(isBold: true, isItalic: true) {
            return Int(pow(2.0, 0)) + Int(pow(2.0, 1)) // 3
        }
        return 0
    }
    
    static func parseTextStorageAttributesAsBitRep(content: NSTextStorage) -> [[Int]] {
        let attrCheckList = getAttrCheckList()
        
        if self.attrMap == nil {
            self.attrMap = [:]
            
            // add attributes that are 1 or 0 to map, other attributes such as bold and italic have to be manually checked
            for i in 3..<attrCheckList.count {
                self.attrMap![attrCheckList[i] as! [NSAttributedString.Key: Bool]] = i
            }
        }
        
        var rangeAttributesMap : [[Int]] = []
        
        content.enumerateAttributes(in: NSMakeRange(0, content.length), options: .longestEffectiveRangeNotRequired) {
            value, range, stop in
            
            var bitRep = 0
            for (key, val) in value {
                if key == NSAttributedString.Key.font {
                    let font = val as! UIFont
                    bitRep += getFontEncodingVal(font: font)
                } else if key == NSAttributedString.Key.strikethroughStyle {
                    bitRep += Int(pow(2.0, 2))
                } else {
                    if let boolVal : Bool = val as? Bool {
                        if self.attrMap!.keys.contains([key:boolVal]) {
                            let doubleVal : Double = Double(self.attrMap![[key:boolVal]]!)
                            bitRep += Int(pow(2.0, doubleVal))
                        }
                    }
                }
            }
            
            let currRange = [bitRep, range.location, range.length]
            rangeAttributesMap.append(currRange)
        }
        return rangeAttributesMap
    }
    
    static func generateAttributesFromEncoding(encode: Int) -> [NSAttributedString.Key: Any] {
        var encode = encode
        
        // default starting attributes
        var attributesToBeApplied: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: TextViewHelper.getHelveticaNeueFont(isBold: false, isItalic: false), NSAttributedString.Key.paragraphStyle: TextViewHelper.getPlainParagraphStyle()]
        
        var counter = 0
        while encode != 0 {
            if encode & 1 == 1 {
                if counter == 1 && attributesToBeApplied[NSAttributedString.Key.font]! as! UIFont == TextViewHelper.getHelveticaNeueFont(isBold: true, isItalic: false) {
                    attributesToBeApplied[NSAttributedString.Key.font] = TextViewHelper.getHelveticaNeueFont(isBold: true, isItalic: true)
                } else {
                    attributesToBeApplied = attributesToBeApplied.merging(TextViewHelper.getAttrCheckList()[counter] as! [NSAttributedString.Key : Any]) {(_, last) in last} // overwrite existing keys with new val in closure
                }
                
                if counter >= 3 && counter <= 6 {
                    
                    // specific paragraph styles for lists
                    attributesToBeApplied = attributesToBeApplied.merging([NSAttributedString.Key.paragraphStyle: TextViewHelper.getBulletListParagraphStyle()]){(_, last) in last}
                }
            }
            counter += 1
            encode >>= 1
        }
        
        // set default paragraph style if empty
        if attributesToBeApplied[NSAttributedString.Key.paragraphStyle] == nil {
            attributesToBeApplied = attributesToBeApplied.merging([NSAttributedString.Key.paragraphStyle: TextViewHelper.getPlainParagraphStyle()]) {(current, _) in current}
        }
        
        return attributesToBeApplied
    }
}
