//
//  ChatModel.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import Foundation

struct ChatModel: Equatable, Identifiable {
  var id: UUID
  var text = ""
  let model: ModelModel
  var title = ""
  let llamaContext: LlamaContext
}
