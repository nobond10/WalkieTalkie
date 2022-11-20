//
//  AudioRecorder2.swift
//  WalkieTalkie
//
//  Created by Ярослав Косарев on 13.11.2022.
//

import AVFoundation

protocol AudioRecorderDelegate: AnyObject {
    func didRecordData(_ data: Data)
}

class AudioRecorder: NSObject {
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private let engine: AVAudioEngine = AVAudioEngine()
    let localPlayerQueue = DispatchQueue(label: "localPlayerQueue", qos: DispatchQoS.userInteractive)
    private let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!
    weak var delegate: AudioRecorderDelegate?
    

    deinit {
        engine.stop()
    }

    func startRecording() {
        localPlayerQueue.async {
            do {
                try self.audioSession.setCategory(.record)
                try self.audioSession.setPreferredIOBufferDuration(0.001)
                try self.audioSession.setPreferredSampleRate(44100)
                try self.audioSession.setActive(true)

                self.engine.inputNode.removeTap(onBus: 0)
                self.engine.inputNode.installTap(onBus: 0, bufferSize: 4410, format: self.format) { buffer, time in
                    let data = self.audioBufferToNSData(PCMBuffer: buffer)
                    self.delegate?.didRecordData(data)
                }

                self.engine.prepare()
                try self.engine.start()
            }
            catch let error as NSError {
                print("\(type(of: self)) > \(#function) > Error encountered: \(error)")
            }
        }
    }

    func stopRecording() {
        engine.stop()

        do {
            try self.audioSession.setActive(false)
        } catch {
            print(error)
        }
    }

    private func audioBufferToNSData(PCMBuffer: AVAudioPCMBuffer) -> Data {
        let channelCount = 1  // given PCMBuffer channel count is 1
        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
        let data = Data(bytes: channels[0], count:Int(PCMBuffer.frameLength * PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))

        return data
    }
}

