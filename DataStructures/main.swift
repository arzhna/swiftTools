//
//  main.swift
//  DataStructureLibs
//
//  Created by Arzhna Lee on 2014. 7. 22..
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Foundation

println("=====  Test of Queue  =====")
var q = Queue()

println("create queue and enqueue 10 items")
for i in 1...10 {
    var num = i*11
    q.enqueue(num)
}

print("dequeue : ")
for i in 1...10 {
    print("\(q.dequeue()) ")
}
println("\n")

println("=====  Test of Linked List  =====")

var llist = LinkedList()

println("create list and insert 10 nodes")
for i in 1...10 {
    var nodeData = Int(arc4random()%100)
    var result: ReturnCode
    result = llist.insertNode(nodeData, index: nil)
    //println(result.description())
}
println("\(llist.dumpList())")

println("delete node 1")
llist.deleteNode(1)
println("\(llist.dumpList())")

println("delete node 3")
llist.deleteNode(3)
println("\(llist.dumpList())")

println("delete node \(llist.count)")
llist.deleteNode(llist.count)
println("\(llist.dumpList())")

println("insert node 1 to 27")
llist.insertNode(27, index:1)
println("\(llist.dumpList())")

println("insert node 7 to 11")
llist.insertNode(11, index:7)
println("\(llist.dumpList())")

println("insert node \(llist.count) to 32")
llist.insertNode(32, index:llist.count)
println("\(llist.dumpList())")

println("the data of node 1 : \(llist.getValueOfNode(1))")
println("the data of node 4 : \(llist.getValueOfNode(4))")
println("the data of node \(llist.count) : \(llist.getValueOfNode(llist.count))")

if let retval = llist.searchIndexOfNodeByValue(llist.getValueOfNode(4)!) {
    println("index of node that has value \(llist.getValueOfNode(4)) is \(retval)")
}else{
    println("node is not exist in this list")
}

if let retval = llist.searchIndexOfNodeByValue(1234) {
    println("index of node that has value 1234 is \(retval)")
}else{
    println("node is not exist in this list")
}

for i in 1...llist.count {
    llist.deleteNode(1)
}

println("\(llist.dumpList())\n")

println("=====  Test of Stack  =====")
println("create stack and push 10 items")
var stack = Stack()

for i in 1...10 {
    stack.push(i)
}

println("\(stack.dumpStack())")

println("pop 2 items")
for i in 1...2 {
    print("\(stack.pop()) ")
}

println("\n\(stack.dumpStack())")

println("pop 3 items")
for i in 1...3 {
    print("\(stack.pop()) ")
}

println("\n\(stack.dumpStack())")

println("pop remained items")
for i in 1...stack.count {
    print("\(stack.pop()) ")
}

println("\n\(stack.dumpStack())")

