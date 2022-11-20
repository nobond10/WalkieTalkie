////
////  AudioRecorder.swift
////  WalkieTalkie
////
////  Created by Ярослав Косарев on 12.11.2022.
////
//
//import AVFoundation
//
//protocol AudioRecorderDelegate: AnyObject {
//    func didRecordData(_ data: Data)
//}
//
//class AudioRecorder: NSObject {
//    private let outputStream: OutputStream
//    private let captureSession = AVCaptureSession()
//    weak var delegate: AudioRecorderDelegate?
//
//    init(outputStream: OutputStream) {
//        self.outputStream = outputStream
//        super.init()
//    }
//
//    deinit {
//        captureSession.stopRunning()
//    }
//
//    func startRecording() {
//        outputStream.schedule(in: RunLoop.main, forMode: .default)
//        outputStream.open()
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
//
//            do {
//                self.captureSession.beginConfiguration()
//                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
//                if self.captureSession.canAddInput(audioInput) {
//                    self.captureSession.addInput(audioInput)
//                }
//
//                let audioOutput = AVCaptureAudioDataOutput()
//                audioOutput.setSampleBufferDelegate(self, queue: .global(qos: .userInitiated))
//                if self.captureSession.canAddOutput(audioOutput) {
//                    self.captureSession.addOutput(audioOutput)
//                }
//
//                self.captureSession.commitConfiguration()
//                self.captureSession.startRunning()
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    func stopRecording() {
//        captureSession.stopRunning()
//        outputStream.close()
//    }
//}
//
//extension AudioRecorder: AVCaptureAudioDataOutputSampleBufferDelegate {
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        var blockBuffer: CMBlockBuffer?
//        var audioBufferList: AudioBufferList = AudioBufferList()
//
//        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, bufferListSizeNeededOut: nil, bufferListOut: &audioBufferList, bufferListSize: MemoryLayout<AudioBufferList>.size, blockBufferAllocator: nil, blockBufferMemoryAllocator: nil, flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, blockBufferOut: &blockBuffer)
//                let buffers = UnsafeMutableAudioBufferListPointer(&audioBufferList)
//        
//                for buffer in buffers {
//                    let u8ptr = buffer.mData!.assumingMemoryBound(to: UInt8.self)
//                    outputStream.write(u8ptr, maxLength: Int(buffer.mDataByteSize))
//                }
////        let buffers = UnsafeMutableAudioBufferListPointer(&audioBufferList)
////        for buffer in buffers {
//////            outputStream.write(buffer.mData!, maxLength: Int(buffer.mDataByteSize))
////            delegate?.didRecordData(buffer.mData!.assumingMemoryBound(to: UInt8.self))
////        }
//    }
//    
//    private func audioBufferToNSData(PCMBuffer: AVAudioPCMBuffer) -> NSData {
//        let channelCount = 1  // given PCMBuffer channel count is 1
//        let channels = UnsafeBufferPointer(start: PCMBuffer.floatChannelData, count: channelCount)
//        let data = NSData(bytes: channels[0], length:Int(PCMBuffer.frameLength * PCMBuffer.format.streamDescription.pointee.mBytesPerFrame))
//        
//        return data
//    }
//}
