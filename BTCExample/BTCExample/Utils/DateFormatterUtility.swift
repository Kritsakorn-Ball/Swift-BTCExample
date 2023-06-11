//
//  DateFormatter.swift
//  BTCExample
//
//  Created by Krisakorn Amnajsatit on 9/6/2566 BE.
//

import Foundation
class DateFormatterUtility {
    static let shared = DateFormatterUtility()

    private let dateFormatter: DateFormatter = DateFormatter()
    private let isoDateFormatter = ISO8601DateFormatter()

    func formatShortDate(_ date: Date) -> String {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    func formatDateISOString(_ dateString: String) -> Date? {
        return isoDateFormatter.date(from: dateString)
    }
}
