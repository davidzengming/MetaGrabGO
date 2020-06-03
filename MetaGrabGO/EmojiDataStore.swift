//
//  EmojiDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-05-28.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

class EmojiDataStore: ObservableObject {
    @Published var emojiArr = [[Int]]()
    @Published var emojiCount = [Int: Int]()
    @Published var didReactToEmoji = [Int: Bool]()
    
    @Published var usersArrReactToEmoji = [Int: [User]]()
    @Published var usersSetReactToEmoji = [Int: Set<Int>]()
    
    let maxEmojisPerThread = 10
    let maxEmojiCountPerRow = 5
    
    @Published var isLoading = false
    
    init(serializedEmojiArr: [Int], emojiReactionCount: [Int: Int], userArrPerEmoji: [Int: [User]], didReactToEmojiDict: [Int: Bool]) {
        emojiArr = getInitialEmojiArray(emojiArr: serializedEmojiArr, emojiReactionCount: emojiReactionCount)
        emojiCount = emojiReactionCount
        didReactToEmoji = didReactToEmojiDict
        buildUserEmojiList(userArrPerEmoji: userArrPerEmoji)
    }
    
    func buildUserEmojiList(userArrPerEmoji: [Int: [User]]) {
        var usersSetReactToEmoji = [Int: Set<Int>]()
        
        for (emojiId, users) in userArrPerEmoji {
            for user in users {
                if usersSetReactToEmoji[emojiId] == nil {
                    usersSetReactToEmoji[emojiId] = Set<Int>()
                }
                usersSetReactToEmoji[emojiId]!.insert(user.id)
            }
        }
        
        self.usersSetReactToEmoji = usersSetReactToEmoji
        self.usersArrReactToEmoji = userArrPerEmoji
    }
    
    func isEmojiVote(emojiId: Int) -> Bool {
        return emojiId == 0 || emojiId == 1
    }
    
    func getInitialEmojiArray(emojiArr: [Int], emojiReactionCount: [Int: Int]) -> [[Int]] {
        var arr = [[Int]]()
        arr.append([])
        if emojiReactionCount[0] != nil {
            arr[0].append(0)
        }
        
        if emojiReactionCount[1] != nil {
            arr[0].append(1)
        }
        
        for emojiId in emojiArr {
            if emojiId == 0 || emojiId == 1 {
                continue
            }
            let row = arr.count - 1
            let col = arr[row].count
            
            if col == self.maxEmojiCountPerRow {
                arr.append([emojiId])
                continue
            }
            arr[arr.count - 1].append(emojiId)
        }
        
        // add plus emoji button
        if arr.count <= 2 && arr[arr.count - 1].count < self.maxEmojiCountPerRow {
            arr[arr.count - 1].append(999)
        } else if arr.count == 1 && arr[arr.count - 1].count == self.maxEmojiCountPerRow {
            arr.append([999])
        }
        
        return arr
    }
    
    func addEmojiToStore(emojiId: Int, user: User, newEmojiCount: Int) {
        DispatchQueue.main.async {
            self.didReactToEmoji[emojiId] = true
            
            if self.usersArrReactToEmoji[emojiId] == nil {
                self.usersArrReactToEmoji[emojiId] = []
            }
            self.usersArrReactToEmoji[emojiId]!.append(user)
            
            if self.usersSetReactToEmoji[emojiId] == nil {
                self.usersSetReactToEmoji[emojiId] = Set()
            }
            self.usersSetReactToEmoji[emojiId]!.insert(user.id)
            
            if self.emojiCount[emojiId] != nil {
                print("Emoji already exists in array, not adding a new icon.")
                return
            }
            self.emojiCount[emojiId] = newEmojiCount
            self.emojiArr = self.getShiftedArrayForAddEmoji(emojiId: emojiId)
        }
    }
    
    func removeEmojiFromStore(emojiId: Int, user: User, newEmojiCount: Int) {
        DispatchQueue.main.async {
            if newEmojiCount == 0 {
                self.emojiArr = self.getShiftedArrayForRemoveEmoji(emojiId: emojiId)
                self.didReactToEmoji.removeValue(forKey: emojiId)
                self.emojiCount.removeValue(forKey: emojiId)
            } else {
                self.didReactToEmoji[emojiId] = false
                self.emojiCount[emojiId] = newEmojiCount
            }
            
            let index = self.usersArrReactToEmoji[emojiId]!.firstIndex(of: user)
            
            self.usersArrReactToEmoji[emojiId]!.remove(at: index!)
            if self.usersArrReactToEmoji[emojiId]!.count == 0 {
                self.usersArrReactToEmoji.removeValue(forKey: emojiId)
            }
            
            self.usersSetReactToEmoji[emojiId]!.remove(user.id)
            if self.usersSetReactToEmoji[emojiId]!.count == 0{
                self.usersSetReactToEmoji.removeValue(forKey: emojiId)
            }
        }
    }
    
    func getShiftedArrayForAddEmoji(emojiId: Int) -> [[Int]] {
        let arr = self.emojiArr
        var res = [[Int]]()
        
        if emojiId == 0 {
            res.append([emojiId])
            
            for i in 0 ..< arr.count {
                for j in 0 ..< arr[i].count {
                    let arrRow = res.count - 1
                    let arrCol = res[arrRow].count
                    
                    if arrRow == 1 && arrCol == self.maxEmojiCountPerRow {
                        break
                    }
                    
                    if arrCol == self.maxEmojiCountPerRow {
                        res.append([arr[i][j]])
                        continue
                    }
                    
                    res[res.count - 1].append(arr[i][j])
                }
            }
        } else if emojiId == 1 {
            if (self.emojiCount[0] != nil) {
                res.append([0, 1])
                for i in 0 ..< arr.count {
                    for j in 0 ..< arr[i].count {
                        let arrRow = res.count - 1
                        let arrCol = res[arrRow].count
                        
                        if arrRow == 1 && arrCol == self.maxEmojiCountPerRow {
                            break
                        }
                        
                        if arr[i][j] == 0 {
                            continue
                        }
                        
                        if arrCol == self.maxEmojiCountPerRow {
                            res.append([arr[i][j]])
                            continue
                        }
                        res[res.count - 1].append(arr[i][j])
                    }
                }
            } else {
                res.append([1])
                for i in 0 ..< arr.count {
                    for j in 0 ..< arr[i].count {
                        let arrRow = res.count - 1
                        let arrCol = res[arrRow].count
                        
                        if arrRow == 1 && arrCol == self.maxEmojiCountPerRow {
                            break
                        }
                        
                        if arrCol == self.maxEmojiCountPerRow {
                            res.append([arr[i][j]])
                            continue
                        }
                        res[res.count - 1].append(arr[i][j])
                    }
                }
            }
            
        } else {
            res = arr
            
            let arrRow = res.count - 1
            let arrCol = res[arrRow].count
            
            res[res.count - 1].popLast()
            res[res.count - 1].append(emojiId)
            
            if arrRow == 1 && arrCol == self.maxEmojiCountPerRow {
                return res
            }
            
            if arrCol == self.maxEmojiCountPerRow {
                res.append([999])
            } else {
                res[res.count - 1].append(999)
            }
        }
        
        return res
    }
    
    func getShiftedArrayForRemoveEmoji(emojiId: Int) -> [[Int]] {
        let arr = self.emojiArr
        
        var res = [[Int]]()
        res.append([])
        
        var isLastElementAddEmoji = true
        if arr.count == 2 && arr[arr.count - 1].count == self.maxEmojiCountPerRow && arr[arr.count - 1][self.maxEmojiCountPerRow - 1] != 999 {
            isLastElementAddEmoji = false
        }
        
        for i in 0 ..< arr.count {
            for j in 0 ..< arr[i].count {
                let arrRow = res.count - 1
                let arrCol = res[arrRow].count
                
                if arr[i][j] == emojiId {
                    continue
                }
                
                if arrCol == maxEmojiCountPerRow {
                    res.append([arr[i][j]])
                    continue
                }
                res[res.count - 1].append(arr[i][j])
            }
        }
        
        if isLastElementAddEmoji == false {
            res[res.count - 1].append(999)
        }
        
        return res
    }
}
