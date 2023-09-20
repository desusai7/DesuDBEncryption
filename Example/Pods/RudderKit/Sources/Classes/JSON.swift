//
//  JSON.swift
//  RudderKit
//
//  Created by Pallab Maiti on 27/07/23.
//

import Foundation

extension String {
    public func convert<T: Any>() -> T? {
        if let data = data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? T
            } catch { }
        }
        return nil
    }
}

func toJSONString<T: Any>(object: T) -> String? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8)
    } catch { }
    return nil
}

extension Dictionary {
    public func toJSONString() -> String? {
        return RudderKit.toJSONString(object: self)
    }
}

extension Array {
    public func toJSONString() -> String? {
        return RudderKit.toJSONString(object: self)
    }
}
