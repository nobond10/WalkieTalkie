//
//  Date+Utils.swift
//  WalkieTalkie
//
//  Created by Ярослав Косарев on 12.11.2022.
//

import Foundation

extension Date {
    func logsFormatted() -> String {
        self.formatted(.dateTime.day().month().hour().minute().second())
    }
}
