//
//  ChatList.swift
//  LocalBrain
//
//  Created by Michael Jach on 14/01/2024.
//

import SwiftUI
import CoreData

struct ChatList: View {
  @EnvironmentObject var viewModel: ViewModel
  @State private var downloadTask: URLSessionDownloadTask?
  @State private var progress = 0.0
  @State private var observation: NSKeyValueObservation?
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
          .disabled(!viewModel.models.contains(where: { $0.isDownloaded }))
        }
        
        Section(header: Text("Models")) {
          ForEach(viewModel.sortedModels()) { $model in
            if model.isDownloaded {
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
                  Spacer()
                  if model.id == viewModel.model!.id {
                    HStack {
                      Circle()
                        .frame(width: 8, height: 8)
                        .foregroundStyle(.green)
                      
                      Text("Active")
                        .foregroundStyle(.secondary)
                    }
                  }
                }
              }
            } else {
              switch model.downloadState {
              case .empty:
                Button {
                  Task {
                    model.downloadState = .downloading
                    try? await downloadModel(model: model)
                    model.downloadState = .downloaded
                  }
                } label: {
                  HStack {
                    Text(model.name)
                    Spacer()
                    Image("icon-download")
                      .resizable()
                      .frame(width: 20, height: 20)
                  }
                }
              case .downloading:
                Button {
                  
                } label: {
                  HStack {
                    Text(model.name)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                      .fontWeight(.medium)
                  }
                }
              default:
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
                    Spacer()
                    Text("Active")
                      .foregroundStyle(.secondary)
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
#if !targetEnvironment(simulator)
        Task {
          let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(viewModel.model!.filename)
          if !FileManager.default.fileExists(atPath: fileURL.path) {
            viewModel.model?.downloadState = .downloading
            try? await downloadModel(model: viewModel.model!)
            viewModel.model?.downloadState = .downloaded
          }
        }
#endif
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
    model.downloadState = .empty
  }
  
  @MainActor
  func onAddNewChat() {
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(viewModel.model!.filename)
    let chat = Chat(name: "New chat", modelFileUrl: fileURL)
    viewModel.chats.append(chat)
    navigationPath = [chat.id]
  }
  
  func downloadModel(model: Model) async throws -> Bool {
    do {
      return try await withCheckedThrowingContinuation { continuation in
        let filename = model.filename
        downloadTask = URLSession.shared.downloadTask(with: model.url) { temporaryURL, response, error in
          if let error = error {
            print("Error: \(error.localizedDescription)")
            continuation.resume(throwing: error)
          }
          
          guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            print("Server error!")
            continuation.resume(throwing: "" as! Error)
            return
          }
          
          do {
            if let temporaryURL = temporaryURL {
              let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
              try FileManager.default.copyItem(at: temporaryURL, to: fileURL)
              continuation.resume(returning: true)
            }
          } catch let err {
            print("Error: \(err.localizedDescription)")
          }
        }
        
        observation = downloadTask?.progress.observe(\.fractionCompleted) { progress, _ in
          self.progress = progress.fractionCompleted
        }
        
        downloadTask?.resume()
      }
    } catch {
      
    }
    return true
  }
}

#Preview {
  ChatList()
    .environmentObject(ViewModel())
}
