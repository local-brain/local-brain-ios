//
//  Chats.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Chats {
  @Reducer(state: .equatable)
  
  enum Path {
    case chat(Chat)
  }
  
  @ObservableState
  struct State: Equatable {
    var chats: IdentifiedArrayOf<Chat.State> = []
    var models: IdentifiedArrayOf<ModelItem.State> = [
      ModelItem.State(model: ModelModel(
        name: "Meta Llama 3.2 1B",
        url: URL(string:  "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_0.gguf?download=true")!,
        filename: "Llama-3.2-1B-Instruct-Q4_0.gguf",
        format: "{prompt}",
        size: "700MB",
        memoryRequired: 3
      )),
      ModelItem.State(model: ModelModel(
        name: "Google Gemma 2 2B",
        url: URL(string:  "https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_S.gguf?download=true")!,
        filename: "gemma-2-2b-it-Q4_K_S.gguf",
        format: "{prompt}",
        size: "2GB",
        memoryRequired: 3
      )),
      ModelItem.State(model: ModelModel(
        name: "Microsoft Phi 3.5 Mini",
        url: URL(string:  "https://huggingface.co/bartowski/Phi-3.5-mini-instruct-GGUF/resolve/main/Phi-3.5-mini-instruct-Q4_0.gguf?download=true")!,
        filename: "Phi-3.5-mini-instruct-Q4_0.gguf",
        format: "{prompt}",
        size: "2GB",
        memoryRequired: 3
      )),
      ModelItem.State(model: ModelModel(
        name: "Meta Llama 3.2 3B",
        url: URL(string:  "https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_0.gguf?download=true")!,
        filename: "Llama-3.2-3B-Instruct-Q4_0.gguf",
        format: "{prompt}",
        size: "2GB",
        memoryRequired: 3
      )),
      ModelItem.State(model: ModelModel(
        name: "Meta Llama 3.1 8B",
        url: URL(string:  "https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_S.gguf?download=true")!,
        filename: "Meta-Llama-3.1-8B-Instruct-Q4_K_S.gguf",
        format: "{prompt}",
        size: "5GB",
        memoryRequired: 7
      )),
      ModelItem.State(model: ModelModel(
        name: "Qwen 2.5.1 7B",
        url: URL(string:  "https://huggingface.co/bartowski/Qwen2.5.1-Coder-7B-Instruct-GGUF/resolve/main/Qwen2.5.1-Coder-7B-Instruct-Q4_0.gguf?download=true")!,
        filename: "Qwen2.5.1-Coder-7B-Instruct-Q4_0.gguf",
        format: "{prompt}",
        size: "4GB",
        memoryRequired: 7
      )),
      ModelItem.State(model: ModelModel(
        name: "Ministral 8B",
        url: URL(string:  "https://huggingface.co/bartowski/Ministral-8B-Instruct-2410-GGUF/resolve/main/Ministral-8B-Instruct-2410-Q4_0.gguf?download=true")!,
        filename: "Ministral-8B-Instruct-2410-Q4_0.gguf",
        format: "{prompt}",
        size: "5GB",
        memoryRequired: 7
      ))
    ]
    
    var activeId: String?
    
    // Sub states
    var path = StackState<Path.State>()
  }
  
  enum Action: Sendable {
    case initialize
    case newChat
    
    // Sub actions
    case path(StackActionOf<Path>)
    case chats(IdentifiedActionOf<Chat>)
    case models(IdentifiedActionOf<ModelItem>)
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .initialize:
        if let activeId = UserDefaults.standard.string(forKey: "activeId") {
          state.activeId = activeId
        } else {
          state.activeId = state.models.first(where: { $0.downloadState == .downloaded })?.id
        }
        return .none
        
      case .newChat:
        if let activeModel = state.models.first(where: { $0.id == state.activeId }) {
          let chatState = Chat.State(chat: ChatModel(
            id: UUID(),
            model: activeModel.model,
            llamaContext: try! LlamaContext.create_context(path: activeModel.model.path.path)
          ))
          state.chats.append(chatState)
          state.path.append(.chat(chatState))
        }
        return .none
        
      case .path(.element(_, action: .chat(.cleanup))):
        state.chats = state.chats.filter({ !$0.chat.text.isEmpty })
        return .none
        
      case .path(.element(_, action: .chat(.setTitle(let title)))):
        if let idx = state.path.first?.chat?.id {
          state.chats[id: idx]?.chat.title = title
        }
        return .none
        
      case .path(.element(_, action: .chat(.onResponse(let response)))):
        if let idx = state.path.first?.chat?.id {
          state.chats[id: idx]?.chat.text += response
        }
        return .none
        
      case .path:
        return .none
        
      case .chats:
        return .none
        
      case .models(.element(_, action: .delete(let uuid))):
        if uuid == state.activeId {
          state.activeId = nil
        }
        return .none
        
      case .models(.element(_, action: .setActive(let uuid))):
        state.activeId = uuid
        UserDefaults.standard.set(uuid, forKey: "activeId")
        return .none
        
      case .models:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
    .forEach(\.chats, action: \.chats) {
      Chat()
    }
    .forEach(\.models, action: \.models) {
      ModelItem()
    }
  }
}
