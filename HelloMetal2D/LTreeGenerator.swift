//
//  LTreeGenerator.swift
//  HelloMetal2D
//
//  Created by Denis Dobynda on 16.09.18.
//  Copyright © 2018 Denis Dobynda. All rights reserved.
//

import UIKit

class LTreeGenerator: NSObject {
    
    init(with: [(String,String)]) {
        rules = with
        super.init()
    }
    
    var rules: [(searcheable: String, replace: String)]

     func getLine(after iterations: Int) -> String {
        var line = "F"
        var newLine = ""
        
        for _ in 0..<iterations {
            var index = line.startIndex
            while index != line.endIndex {
                var found = false
                for rule in rules {
                    if rule.searcheable == String(line[index]) {
                        newLine.append(rule.replace)
                        found = true
                    }
                }
                if !found {
                    newLine.append(line[index])
                }
                index = line.index(after: index)
            }
            line = newLine
            newLine = ""
        }
        
        return line
    }
    
}
