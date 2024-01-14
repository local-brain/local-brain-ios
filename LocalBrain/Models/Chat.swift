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
  
  init(id: UUID = UUID(), name: String, responses: [String] = [], llamaContext: LlamaContext? = nil) {
    self.id = id
    self.name = name
    self.responses = responses
    
    do {
      let url = Bundle.main.url(forResource: "ggml-model-q4_0", withExtension: "bin")!
      self.llamaContext = try LlamaContext.create_context(path: url.path())
    } catch {
      // error
    }
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
