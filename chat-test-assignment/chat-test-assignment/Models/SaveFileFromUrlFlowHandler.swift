//
//  SaveFileFromUrlFlowHandler.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 28.02.2022.
//

import Combine
import Foundation

final class SaveFileFromUrlFlowHandler {
    
    enum FlowError: Error {
        case failedToDownload
        case failedToWriteToFile
        case unknown
    }
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func process(remoteFileUrl url: URL) -> AnyPublisher<URL, FlowError> {
        downloadFile(fromUrl: url)
            .flatMap { [weak self] (data) -> AnyPublisher<URL, FlowError> in
                guard let self = self else {
                    return Fail(error: FlowError.unknown).eraseToAnyPublisher()
                }
                
                return self.saveDataToFile(data: data)
            }
            .eraseToAnyPublisher()
    }
    
    private func downloadFile(fromUrl url: URL) -> AnyPublisher<Data, FlowError> {
        session.dataTaskPublisher(for: url)
            .map { data, _ in
                data
            }
            .mapError { _ in
                return FlowError.failedToDownload
            }
            .eraseToAnyPublisher()
    }
    
    private func saveDataToFile(data: Data) -> AnyPublisher<URL, FlowError> {
        let pathUrl = FileManager.default.urls(for: .documentDirectory,
                                               in: .userDomainMask)[0].appendingPathComponent("\(UUID().uuidString).m4a")
        
        do {
            try data.write(to: pathUrl)
            return Just(pathUrl)
                .setFailureType(to: FlowError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: FlowError.failedToWriteToFile).eraseToAnyPublisher()
        }
    }
}
