//
//  AudioPlayerService.swift
//  chat-test-assignment
//
//  Created by Denis Cherniy on 27.02.2022.
//

import AVFoundation

protocol IAudioPlayerService: AnyObject {
    func playSound(forURL url: URL) throws
    func stopPlaying()
}

final class AudioPlayerService: IAudioPlayerService {
    
    private var player: AVAudioPlayer?
    private var audioSession: AVAudioSession
    
    init(audioSession: AVAudioSession = .sharedInstance()) {
        self.audioSession = audioSession
    }
    
    func playSound(forURL url: URL) throws {
        stopPlaying()
        
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        player = try AVAudioPlayer(contentsOf: url)
        
        player?.play()
    }
    
    func stopPlaying() {
        player?.stop()
    }
}
