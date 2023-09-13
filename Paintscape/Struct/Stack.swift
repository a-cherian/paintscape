//
//  Stack.swift
//  Paintscape
//
//  Created by AC on 9/12/23.
//

struct Stack <T:Hashable>{
    private var items: [T] = []
    var count: Int { get { items.count } }
    
    func peek() -> T {
        guard let topElement = items.first else { fatalError("This stack is empty.") }
        return topElement
    }
    
    mutating func pop() -> T {
        return items.removeFirst()
    }
  
    mutating func push(_ element: T) {
        items.insert(element, at: 0)
    }
    
    func getDuplicates() -> Dictionary<T, Int>.Values {
        var dictionary = [T: Int]()

        for item in items {
           dictionary[item] = dictionary[item] ?? 0 + 1
        }
        
        return dictionary.values
    }
}
