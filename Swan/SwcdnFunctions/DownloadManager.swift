// 
//  DownloadManager.swift - Swan
// 
//  Created by Ben216k on 8/10/24
//  Copyright (c) Ben216k (under 216k License)
// 

import SwiftUI
import Foundation
import Combine

@MainActor
final class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    
    static let shared = DownloadManager()
    
    @Published var downloadTasks: [DownloadTask] = []
    // downloadManager.downloadTasks.progress <= 0 && downloadManager.downloadTasks.progress >= 1 as a variable
    var isWithinHumanableRange: Bool {
        downloadTasks.progress > 0 && downloadTasks.progress < 1
    }
    var bestSFSymbol: String {
        if isWithinHumanableRange {
            return "arrow.down"
        } else if downloadTasks.progress == 0 {
            return "arrow.down.circle"
        } else if downloadTasks.allSatisfy({ $0.destinationURL != nil }) {
            return "arrow.down.circle.fill"
        } else {
            return "arrow.down.circle.dotted"
        }
    }
    
    private var taskContinuations: [UUID: CheckedContinuation<URL, Error>] = [:]
    private var taskProgress: [UUID: Double] = [:]
    
    func startDownload(from url: URL, title: String, specific: String, image: String) async throws -> URL {
        let taskId = UUID()
        let newTask = DownloadTask(id: taskId, url: url, expectedSize: -1, currentSize: 0, imageString: image, titleInfo: title, specificInfo: specific, progress: 0)
        downloadTasks.append(newTask)
        
        return try await withCheckedThrowingContinuation { continuation in
            taskContinuations[taskId] = continuation
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            let task = session.downloadTask(with: url)
            task.taskDescription = taskId.uuidString // associate the task with the UUID
            task.resume()
        }
    }

    // URLSessionDownloadDelegate methods
    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let taskIdString = downloadTask.taskDescription, let taskId = UUID(uuidString: taskIdString) else { return }

        
        let fileManager = FileManager.default
        let downloadsURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        var _destinationURL = downloadsURL.appendingPathComponent(location.lastPathComponent)
        
        DispatchQueue.main.sync {
            if let index = self.downloadTasks.firstIndex(where: { $0.id == taskId }) {
                _destinationURL = downloadsURL.appendingPathComponent(self.downloadTasks[index].url.lastPathComponent)
            }
        }
        
        do {
            // check for existing file at _destinationURL, append a number if necessary
            let pathExtension = _destinationURL.pathExtension
            let lastComponent = _destinationURL.deletingPathExtension().lastPathComponent
            var count = 1
            while fileManager.fileExists(atPath: _destinationURL.path) {
                _destinationURL = _destinationURL.deletingLastPathComponent().appendingPathComponent("\(lastComponent) \(count).\(pathExtension)")
                count += 1
            }
            
            let destinationURL = _destinationURL
            try fileManager.moveItem(at: location, to: destinationURL)

            DispatchQueue.main.async {
                if let index = self.downloadTasks.firstIndex(where: { $0.id == taskId }) {
                    self.downloadTasks[index].destinationURL = destinationURL
                    self.taskContinuations[taskId]?.resume(returning: destinationURL)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.taskContinuations[taskId]?.resume(throwing: error)
            }
        }
    }

    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let taskIdString = downloadTask.taskDescription, let taskId = UUID(uuidString: taskIdString) else { return }

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            if let index = self.downloadTasks.firstIndex(where: { $0.id == taskId }) {
                self.downloadTasks[index].expectedSize = Int(totalBytesExpectedToWrite)
                self.downloadTasks[index].currentSize = Int(totalBytesWritten)
                self.downloadTasks[index].progress = progress
            }
        }
    }

    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let taskIdString = task.taskDescription, let taskId = UUID(uuidString: taskIdString) else { return }

        if let error = error {
            DispatchQueue.main.async {
                self.taskContinuations[taskId]?.resume(throwing: error)
            }
        }
    }
}

struct DownloadTask: Identifiable, Sendable {
    let id: UUID
    let url: URL
    var expectedSize: Int
    var currentSize: Int
    let imageString: String
    let titleInfo: String
    let specificInfo: String
    var destinationURL: URL?
    var progress: Double

    var formattedExpectedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(expectedSize), countStyle: .file)
    }
    var formattedCurrentSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(currentSize), countStyle: .file)
    }
}

extension Array where Element == DownloadTask {
    // combined progress of all download tasks
    var progress: Double {
        guard !isEmpty else { return 0 }
        let totalProgress = reduce(0) { $0 + $1.progress }
        return totalProgress / Double(count)
    }
}
