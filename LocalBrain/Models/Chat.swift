//
//  Chat.swift
//  LocalBrain
//
//  Created by Michael Jach on 14/01/2024.
//

import Foundation

struct Chat: Identifiable, Hashable {
  var id = UUID()
  var name: String
  var responses: [String] = []
  var llamaContext: LlamaContext?
  var modelFileUrl: URL
  
  init(id: UUID = UUID(), name: String, responses: [String] = [], llamaContext: LlamaContext? = nil, modelFileUrl: URL) {
    self.id = id
    self.name = name
    self.responses = responses
    self.modelFileUrl = modelFileUrl
    
    do {
      self.llamaContext = try LlamaContext.create_context(path: modelFileUrl.path())
    } catch {
      // error
    }
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
