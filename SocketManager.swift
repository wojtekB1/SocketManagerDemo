//
//  SocketManager.swift
//
//  Created by Wojciech Byczkowski on 23/03/2021.
//  Copyright © 2021 Wojciech Byczkowski. All rights reserved.
//

import Starscream

typealias ModelTouple = (buyOrders: [Model], sellOrders: [Model])

enum SocketViewType {
  case type
}

protocol SocketManagerType {
  var viewDelegate: SocketManagerDelegate? { get set }
  func setupSocket()
  func disconnectSocket()
}

protocol SocketManagerDelegate: class {
  func socketDidReceiveMessage(model: ModelTouple?)
}

final class SocketManager {
  weak var viewDelegate: SocketManagerDelegate?

  private let type: SocketViewType

  private var socket: WebSocket!

  init(type: SocketViewType) {
    self.type = type
  }

  private func sendMessage(_ message: String) {
    socket.write(string: message)
  }

  private func sendData(_ data: Data) {
    socket.write(data: data)
  }

  private func socketDidConnect() {}

  private func socketDidReceiveMessage(text: String) -> ModelTouple? {}
}

extension SocketManager: SocketManagerType {
  func setupSocket() {
    socket = WebSocket(url: URL(string: APIConstants.socketBaseURL)!)
    socket.delegate = self
    socket.connect()
  }

  func disconnectSocket() {
    socket.disconnect()
  }
}
extension SocketManager: WebSocketDelegate {
  func websocketDidConnect(socket: WebSocketClient) {
    switch type {
    case .type:
      socketDidConnect()
    }
  }

  func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {}

  func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    switch type {
    case .type:
      let model = socketDidReceiveMessage(text: text)
      viewDelegate?.socketDidReceiveMessage(model: model)
    }
  }

  func websocketDidReceiveData(socket: WebSocketClient, data: Data) {}

}
