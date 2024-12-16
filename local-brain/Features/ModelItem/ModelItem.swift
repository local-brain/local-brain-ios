//
//  ModelItem.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import ComposableArchitecture
import Foundation
import UIKit

@Reducer
struct ModelItem {
  enum DownloadState {
    case notDownloaded
    case downloaded
    case downloading
  }
  
  @ObservableState
  struct State: Equatable, Identifiable {
    var id: String { model.id }
    let model: ModelModel
    var downloadProgress = 0
    var downloadState: DownloadState = .notDownloaded
    let modelService = ModelsService()
    
    init(model: ModelModel, downloadProgress: Int = 0, downloadState: DownloadState = .notDownloaded) {
      self.model = model
      self.downloadProgress = downloadProgress
      let fileExist = FileManager.default.fileExists(atPath: model.path.path)
      self.downloadState = fileExist ? .downloaded : downloadState
    }
  }
  
  enum Action: Sendable {
    case download
    case onProgressChange(Int)
    case didDownload(Result<Int, Error>)
    case delete(String)
    case setActive(String)
    case cancel
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .setActive:
        return .none
        
      case .cancel:
        state.modelService.cancel()
        return .none
        
      case .delete:
        try? FileManager.default.removeItem(atPath: state.model.path.path)
        state.downloadProgress = 0
        state.downloadState = .notDownloaded
        return .none
        
      case .download:
        UIApplication.shared.isIdleTimerDisabled = true
        state.modelService.downloadModel(
          modelUrl: state.model.url,
          filename: state.model.filename
        )
        
        guard let stream = state.modelService.stream else { return .none }
        
        return .run { send in
          for await status in stream {
            switch status {
            case .progress(let percent):
              await send(.onProgressChange(percent))
            case .success:
              await send(.didDownload(.success(100)))
            case .error(let error):
              await send(.didDownload(.failure(error)))
            }
          }
        }
        
      case .didDownload(.success):
        UIApplication.shared.isIdleTimerDisabled = false
        state.downloadState = .downloaded
        return .run { [model = state.model] send in
          await send(.setActive(model.id))
        }
        
      case .didDownload(.failure(let error)):
        UIApplication.shared.isIdleTimerDisabled = false
        state.downloadProgress = 0
        state.downloadState = .notDownloaded
        print(error)
        return .none
        
      case .onProgressChange(let progress):
        state.downloadState = .downloading
        state.downloadProgress = progress
        return .none
      }
    }
  }
}
