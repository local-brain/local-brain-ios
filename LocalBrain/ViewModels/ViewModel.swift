//
//  ChatListViewModel.swift
//  LocalBrain
//
//  Created by Michael Jach on 14/01/2024.
//

import SwiftUI

class ViewModel: ObservableObject {
  @Published var isSupported = false
  @Published var chats: [Chat]
  @Published var models: [Model]
  @Published var model: Model?
  
  init() {
    var systemInfo = utsname()
    uname(&systemInfo)
    let modelCode = withUnsafePointer(to: &systemInfo.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) {
        ptr in String.init(validatingUTF8: ptr)
      }
    }
    self.isSupported = ["arm64", "iPhone16,1", "iPhone16,2", "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7", "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11", "iPad13,16", "iPad13,17"].contains(modelCode)
    
    self.chats = []
    self.models = [
      Model(
        name: "Mistral 7B Instruct v0.2 (4GB)",
        filename: "mistral-7b-instruct-v0.2.Q4_0.gguf",
        url: URL(string: "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_0.gguf?download=true")!
      ),
      Model(
        name: "Tinyllama 1.1B Chat v1.0 (638MB)",
        filename: "tinyllama-1.1b-chat-v1.0.Q4_0.gguf",
        url: URL(string: "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_0.gguf?download=true")!
      ),
      Model(
        name: "Openchat 3.5 0106 (4GB)",
        filename: "openchat-3.5-0106.Q4_0.gguf",
        url: URL(string: "https://huggingface.co/TheBloke/openchat-3.5-0106-GGUF/resolve/main/openchat-3.5-0106.Q4_0.gguf?download=true")!
      )
    ]
    self.model = models.first!
  }
  
  func sortedChats() -> Binding<[Chat]> {
    Binding<[Chat]>(
      get: {
        self.chats.reversed()
      },
      set: { chats in
        for chat in chats {
          if let index = self.chats.firstIndex(where: { $0.id == chat.id }) {
            self.chats[index] = chat
          }
        }
      }
    )
  }
  
  func sortedModels() -> Binding<[Model]> {
    Binding<[Model]>(
      get: {
        self.models
      },
      set: { models in
        for model in models {
          if let index = self.models.firstIndex(where: { $0.id == model.id }) {
            self.models[index] = model
          }
        }
      }
    )
  }
}
