//
//  Stack.swift
//  DataStructureLibs
//
//  Created by Arzhna Lee on 2014. 7. 23..
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Cocoa

class Stack<T:NSObject>  {
    var count: Int = 0
    var top: Node<T>? = nil
    
    init(){
    }
    
    func isEmpty()->Bool {
        return self.count == 0
    }
    
    func push(value:T) {
        var newNode = Node(value: value)
        newNode.prev = self.top
        self.top = newNode
        self.count++
    }
    
    func pop()->T? {
        if isEmpty() {
            return nil
        }else{
            var result:T
            result = self.top!.value!
            self.top = self.top!.prev
            self.count--
            return result
        }
    }
    
    func dumpStack()->String {
        var resultString = String()
        
        if isEmpty() {
            resultString = "This stack is empty."
        }else{
            var ptr: Node<T>? = self.top
            //resultString = "["
            do {
                resultString += "\(ptr!.value)"
                if ptr!.prev {
                    resultString += "|"
                }
                ptr = ptr!.prev
            } while ptr
            resultString += "]"
        }
        
        return resultString
    }
}
