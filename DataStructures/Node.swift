//
//  Node.swift
//  DataStructureLibs
//
//  Created by Arzhna Lee on 2014. 7. 22..
//  Copyright (c) 2014 Arzhna. All rights reserved.
//

import Cocoa

class Node<T:NSObject> {
    var value: T? = nil
    var prev: Node<T>? = nil
    var next: Node<T>? = nil
    
    init(){
    }
    
    init(value: T){
        self.value = value
    }
}
