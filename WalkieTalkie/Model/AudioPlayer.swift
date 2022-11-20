//
//  AudioPlayer.swift
//  WalkieTalkie
//
//  Created by Ярослав Косарев on 13.11.2022.
//

import AVFoundation

class AudioPlayer: NSObject {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!
    
    deinit {
        player.stop()
        engine.stop()
    }
    
    override init() {
        super.init()
        startPlaying()
    }

    func startPlaying() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print(error)
        }

        engine.attach(player)
        
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.prepare()
        do {
            try engine.start()
        } catch {
            print(error)
        }
        player.play()
    }

    func stopPlaying() {
        player.stop()
        engine.stop()
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false)
        } catch {
            print(error)
        }
    }

    func play(data: Data) {
        if !player.isPlaying {
            startPlaying()
        }
        if let buffer = dataToPCMBuffer(data: data) {
            player.scheduleBuffer(buffer)
        }
    }
    
    func dataToPCMBuffer(data: Data) -> AVAudioPCMBuffer? {
        
        if let audioBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                              frameCapacity: UInt32(data.count) / format.streamDescription.pointee.mBytesPerFrame) {
            audioBuffer.frameLength = audioBuffer.frameCapacity
            let channels = UnsafeBufferPointer(start: audioBuffer.floatChannelData, count: Int(audioBuffer.format.channelCount))
            
            NSData(data: data).getBytes(UnsafeMutableRawPointer(channels[0]) , length: data.count)
            return audioBuffer
        }
        
        return nil
    }
}
