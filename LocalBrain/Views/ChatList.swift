//
//  ChatList.swift
//  LocalBrain
//
//  Created by Michael Jach on 14/01/2024.
//

import SwiftUI

struct ChatList: View {
  @EnvironmentObject var viewModel: ViewModel
  @State private var progress = 0
  @State private var navigationPath: [UUID] = []
  
  var body: some View {
    NavigationStack(path: $navigationPath) {
      List {
        Section(header: Text("Recent")) {
          if viewModel.sortedChats().isEmpty {
            Text("No recent chats")
              .foregroundStyle(.secondary)
          } else {
            ForEach(viewModel.sortedChats()) { $chat in
              NavigationLink(value: chat.id) {
                Text(chat.name)
              }
            }
          }
        }
        
        Section {
          Button {
            onAddNewChat()
          } label: {
            HStack {
              Image("icon-add")
                .resizable()
                .frame(width: 24, height: 24)
              
              Text("New chat")
                .fontWeight(.medium)
            }
          }
          .disabled(!viewModel.models.contains(where: { $0.downloadState == .downloaded }))
        }
        
        Section(header: Text("Models"), footer: Text("All models are open source, downloaded from huggingface.co.")) {
          ForEach(viewModel.sortedModels()) { $model in
            switch model.downloadState {
            case .notDownloaded:
              Button {
                model.downloadState = .downloading
                ModelsService.instance.downloadModel(modelUrl: model.url, filename: model.filename)
              } label: {
                HStack {
                  Text(model.name)
                  Spacer()
                  Image("icon-download")
                    .resizable()
                    .frame(width: 20, height: 20)
                }
              }
              .disabled(viewModel.models.contains(where: { $0.downloadState == .downloading }))
              
            case .downloading:
              Button {
                
              } label: {
                HStack {
                  Text(model.name)
                  Spacer()
                  Text("\(progress)%")
                    .fontWeight(.medium)
                }
                .onAppear {
                  Task {
                    if let stream = ModelsService.instance.stream {
                      for await status in stream {
                        switch status {
                        case .progress(let percent):
                          self.progress = percent
                        case .success:
                          model.downloadState = .downloaded
                          onModelSelect(model: model)
                        case .error:
                          model.downloadState = .notDownloaded
                        }
                      }
                    }
                  }
                }
              }
            case .downloaded:
              Menu {
                Button {
                  onModelSelect(model: model)
                } label: {
                  Text("Set active")
                }
                Button {
                  onDeleteModel(model: &model)
                } label: {
                  Text("Delete")
                }
              } label: {
                HStack {
                  Text(model.name)
                    .multilineTextAlignment(.leading)
                  Spacer()
                  
                  HStack {
                    if model.id == viewModel.model?.id {
                      HStack {
                        Circle()
                          .frame(width: 8, height: 8)
                          .foregroundColor(.green)
                        
                        Text("Active")
                          .foregroundStyle(.secondary)
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      .navigationTitle("Chats")
      .navigationDestination(for: UUID.self) { id in
        ChatDetail(chat: viewModel.sortedChats().first(where: { $0.id == id })!)
      }
      .onAppear {
//#if !targetEnvironment(simulator)
        Task {
          let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(viewModel.model!.filename)
          if !FileManager.default.fileExists(atPath: fileURL.path) && !viewModel.models.contains(where: { $0.downloadState == .downloading }) {
            viewModel.models[0].downloadState = .downloading
            ModelsService.instance.downloadModel(modelUrl: viewModel.models[0].url, filename: viewModel.models[0].filename)
          }
        }
//#endif
      }
    }
  }
  
  func onModelSelect(model: Model) {
    viewModel.model = model
  }
  
  func onDeleteModel(model: inout Model) {
    do {
      let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(model.filename)
      try FileManager.default.removeItem(atPath: fileURL.path)
    } catch let error {
      print(error)
    }
    model.downloadState = .notDownloaded
  }
  
  @MainActor
  func onAddNewChat() {
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(viewModel.model!.filename)
    let chat = Chat(name: "New chat", modelFileUrl: fileURL)
    viewModel.chats.append(chat)
    navigationPath = [chat.id]
  }
}

#Preview {
  ChatList()
    .environmentObject(ViewModel())
}
