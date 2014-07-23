//
//  Queue.swift
//  DataStructureLibs
//
//  Created by Arzhna Lee on 2014. 7. 22..
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Cocoa

class Queue<T:NSObject> {
    var count: Int = 0
    var head: Node<T> = Node<T>()
    var tail: Node<T> = Node<T>()
    
    init(){
    }
    
    func isEmpty()->Bool {
        return self.count == 0
    }
    
    func enqueue(value: T) {
        var node = Node<T>(value: value)
        if self.isEmpty(){
            self.head = node
            self.tail = node
        }else{
            node.next = self.head
            self.head.prev = node
            self.head = node
        }
        self.count++
    }
    
    func dequeue()->T? {
        if self.isEmpty(){
            return nil
        } else {
            var temp: Node<T> = self.tail
            if self.count != 1 {
                self.tail = self.tail.prev!
            }
            self.count--
            return temp.value
        }
    }
}