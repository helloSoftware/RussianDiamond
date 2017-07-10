//
//  Block.swift
//  RussianDiamond
//
//  Created by poplar on 2017/7/4.
//  Copyright © 2017年 poplar. All rights reserved.
//

import Foundation

struct Block : CustomStringConvertible {
    var x :Int
    var y : Int
    var color : Int
    var description: String{
        return "Block x : \(x) y: \(y) color : \(color)"
    }
}
