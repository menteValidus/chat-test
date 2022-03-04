//
//  AudioSessionRecorderService.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 27.02.2022.
//

import AVFoundation
import Combine

protocol AudioRecorderService: AnyObject {
    
    var lastRecordedAudioURLPublisher: Published<URL?>.Publisher { get }
    
    func record() throws
    func stopRecording()
}

final class AudioSessionRecorderService: NSObject, AudioRecorderService {
    
    private typealias AudioRecordingSettings = [String: Any]
    
    var lastRecordedAudioURLPublisher: Published<URL?>.Publisher {
        $lastRecordedAudioURL
    }
    
    @Published
    private var lastRecordedAudioURL: URL?
    
    private let audioSession: AVAudioSession
    
    private var audioRecorder: AVAudioRecorder?
    
    private var audioRecordingSettings: AudioRecordingSettings {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
    
    init(audioSession: AVAudioSession = .sharedInstance()) {
        self.audioSession = audioSession
    }
    
    func record() throws {
        try audioSession.setCategory(.playAndRecord, mode: .default)
        try audioSession.setActive(true)
        audioSession.requestRecordPermission() { [weak self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self?.startAudioRecording()
                } else {
                    print("Audio recording usage permission wasn't granted")
                }
            }
        }
    }
    
    func stopRecording() {
        finishRecording(success: true)
    }
    
    private func startAudioRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).m4a")

        let settings = audioRecordingSettings
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    private func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}

extension AudioSessionRecorderService: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        lastRecordedAudioURL = recorder.url
        finishRecording(success: flag)
    }
}
