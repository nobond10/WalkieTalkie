//
//  Config.swift
//  WalkieTalkie
//
//  Created by Ярослав Косарев on 11.11.2022.
//

import Foundation

enum Mode {
    case hoster
    case joiner
}

enum MessageType: Codable {
    case wantSpeaking
    case allowSpeaking
    case rejectSpeaking
    case stopSpeaking
    case audioData(Data)
    case coordinates(Double, Double)
}

enum MainButtonState {
    case noAction
    case tapped
    case disabled
}

struct Constants {
    static let serviceType = "walktalk-st"
    static let connectionOk = "Соединение установлено с %@"
    static let connectionFailed = "Соединение не установлено"
    
    static let peersRequestDeclined = "Отклонен запрос собеседника на эфир"
    static let usersRequestDeclined = "Ваш запрос на эфир отклонен"
    static let allowPeerSpeaking = "Собеседнику разрешено говорить"
    static let allowUserSpeaking = "Ваш разрешено говорить"
    static let peerStoppedSpeaking = "Собеседник закончил говорить"
    static let userStoppedSpeaking = "Вы закончили говорить"
    static let userStartedSpeaking = "Вы начали говорить"

    static let errorFromSession = "При начале записи произошла ошибка: %@"
    static let distance = "Расстояние до собеседника: %dм."
}
