//
//  LinkedList.swift
//  DataStructureLibs
//
//  Created by Arzhna Lee on 2014. 7. 22..
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Cocoa

class LinkedList<T:NSObject> {
    var count: Int = 0
    var head: Node<T>? = nil
    
    init(){
    }
    
    func isEmpty()->Bool {
        return self.count == 0
    }
    
    func insertNode(value:T, index:Int?) -> ReturnCode {
        var newNode = Node<T>(value: value)
        var location: Int
        
        if index == nil {
            location = self.count+1
        }else{
            location = index!
        }
        
        if self.isEmpty(){
            self.head = newNode
        }else{
            var temp: Node<T> = self.head!
            
            if location == 1 {
                newNode.next = temp
                temp.prev = newNode
                self.head = newNode
            }else{
                for i in 1..<location-1 {
                    temp = temp.next!
                }
                newNode.next = temp.next
                newNode.prev = temp
                temp.next = newNode
            }
        }
        
        self.count++
        
        return ReturnCode.OK
    }
    
    func deleteNode(index:Int) -> ReturnCode {
        if self.isOutOfBound(index) {
            return ReturnCode.OutOfBound
        }
        
        var targetNode: Node<T>? = self.head
        if(index==1) {
            targetNode!.prev = nil
            self.head = targetNode!.next
            targetNode = nil
        }else{
            for i in 1..<index {
                targetNode = targetNode!.next
            }
            if (index==self.count){
                targetNode!.prev!.next = targetNode!.next
            }else{
                targetNode!.next!.prev = targetNode!.prev
                targetNode!.prev!.next = targetNode!.next
            }
        }
        
        self.count--
        
        return ReturnCode.OK
    }
    
    func getValueOfNode(index:Int) -> T? {
        var result:T?
    
        if self.isEmpty() || self.isOutOfBound(index){
            return nil
        }else{
            var targetNode: Node<T>? = self.head
            for i in 1..<index {
                targetNode = targetNode!.next
            }
            result = targetNode!.value
        }
        return result
    }
    
    func searchIndexOfNodeByValue(value:T) -> Int? {
        var resultIndex: Int?
        
        if self.isEmpty(){
           return nil
        }else{
            var ptr: Node<T>? = self.head
            var index = 1
            do {
                if value.isEqual(ptr!.value) {
                    resultIndex = index
                    break
                }else{
                    ptr = ptr!.next
                }
            } while ++index < self.count
        }
        
        return resultIndex
    }
    
    // for debug
    func dumpList() -> String {
        var retString = String()
        
        if isEmpty() {
            retString = "This list is empty."
        }else{
            var headNode: Node<T> = self.head!
        
            for i in 1...self.count {
                retString += "[\(i)|\(headNode.value)]"
                if i == self.count {
                    break
                }else{
                    retString += "-> "
                    headNode = headNode.next!
                }
            }
            retString += " totalNode = \(self.count)"
        }
        return retString
    }
    
    // private
    func isOutOfBound(index:Int) -> Bool {
        if index > 0 && index <= self.count {
            return false
        }else{
            return true
        }
    }
}
