//
//  Mocks.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import Foundation

class Mocks {
  static let chatModel = ChatModel(
    id: UUID(),
    text: "**What's 2 + 2?**\nUpdated chat template to fix small bug with tool usage being undefined, if you don't use the built-in chat template it shouldn't change anything",
    model: modelModel,
    title: "What's 2 + 2?",
    llamaContext: try! LlamaContext.create_context(path: "")
  )
  static let modelModel = ModelModel(
    name: "Mistral 7B",
    url: URL(string: "https://url.com")!,
    filename: "filename",
    format: "{prompt}",
    size: "4GB"
  )
}
