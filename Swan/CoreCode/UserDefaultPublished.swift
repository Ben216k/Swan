// 
//  UserDefaultPublished.swift - Swan
// 
//  Created by Ben216k on 9/13/24
//  Copyright (c) Ben216k (under 216k License)
//

import Foundation
import Combine

@propertyWrapper
struct UserDefaultPublished<Value> {
    let key: String
    let defaultValue: Value
    
    var wrappedValue: Value {
        get {
            // Retrieve the value from UserDefaults, or use the default
            UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            // Save the new value to UserDefaults
            UserDefaults.standard.set(newValue, forKey: key)
            // Notify subscribers about the change
            notificationSubject.send(newValue)
        }
    }
    
    // Publisher to notify about changes
    private let notificationSubject = PassthroughSubject<Value, Never>()
    
    var projectedValue: AnyPublisher<Value, Never> {
        notificationSubject.eraseToAnyPublisher()
    }
}
