//
//  AudioRecorder.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 27.02.2022.
//

import AVFoundation

protocol AudioRecorderService: AnyObject {
    func record() throws
}

final class AudioSessionRecorderService: NSObject, AudioRecorderService {
    
    private typealias AudioRecordingSettings = [String: Any]
    
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
                    // failed to record!
                }
            }
        }
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
        finishRecording(success: flag)
    }
}
