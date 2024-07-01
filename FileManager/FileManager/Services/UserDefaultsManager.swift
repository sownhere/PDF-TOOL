//
//  UserDefaultsManager.swift
//  FileManager
//
//  Created by Macbook on 28/06/2024.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private init() {} // Private initializer for Singleton
    
    // MARK: - User Defaults Keys
    private enum UserDefaultsKey: String {
        case isGrid
        case sortPreference
        
    }
    
    enum SortOrder: String {
        case name
        case size
        case date
    }

    
    
    // MARK: - Property for isGrid
    var isGrid: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.isGrid.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.isGrid.rawValue)
        }
    }
    
    
    var sortPreference: SortOrder {
        get {
            guard let storedValue = UserDefaults.standard.string(forKey: UserDefaultsKey.sortPreference.rawValue),
                  let order = SortOrder(rawValue: storedValue) else {
                return .name // Default sorting
            }
            return order
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKey.sortPreference.rawValue)
        }
    }
    // MARK: - Methods to manage other settings
    
    
    
}

extension UserDefaultsManager.SortOrder {
    var description: String {
        switch self {
        case .name:
            return "Name"
        case .size:
            return "Size"
        case .date:
            return "Date"
        }
    }
}


