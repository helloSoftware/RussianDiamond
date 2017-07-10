//: Playground - noun: a place where people can play

import UIKit

func getMathTest(a:Int)->(Int)->Int{

    func add(val:Int)->Int{
        return val+val
    }
    
    func multi(val:Int)->Int{
    
        return val*val
    }
    
    switch a {
    case 1:
        return add(val:)
    default:
        return multi(val:)
    }
}

var mathTest = getMathTest(a: 1)
print(mathTest(5))