//
//  ModelService.swift
//  local-brain
//
//  Created by Michal Jach on 11/12/2024.
//

import Foundation

final class ModelsService: NSObject {
  static let instance = ModelsService()
  
  var stream: AsyncStream<Event>?
  private var continuation: AsyncStream<Event>.Continuation?
  private var tempUrl: URL?
  private var downloadTask: URLSessionDownloadTask?
  
  func cancel() {
    downloadTask?.cancel()
  }
  
  func downloadModel(modelUrl: URL, filename: String) {
    self.stream = AsyncStream { continuation in
      self.continuation = continuation
      let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
      self.tempUrl = fileURL
      try? FileManager.default.removeItem(at: fileURL)
      downloadTask = URLSession.shared.downloadTask(with: modelUrl)
      downloadTask?.delegate = self
      downloadTask?.resume()
    }
  }
}

extension ModelsService: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let error = error {
      self.continuation?.yield(.error(error: error))
    }
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    DispatchQueue.main.async {
      self.continuation?.yield(
        .progress(
          percent: Int((Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)) * 100)
        ))
    }
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    if let tempUrl = self.tempUrl {
      try? FileManager.default.copyItem(at: location, to: tempUrl)
      try? FileManager.default.removeItem(at: location)
      self.continuation?.yield(.success(location: tempUrl))
    }
    self.continuation?.finish()
    self.tempUrl = nil
  }
}

extension ModelsService {
  enum Event {
    case progress(percent: Int)
    case error(error: Error)
    case success(location: URL)
  }
}
