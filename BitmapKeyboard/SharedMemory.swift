//
//  SharedMemory.swift
//  BitmapKeyboardCanvas
//
//  Created by Romas on 01/04/2026.
//

import Foundation
import Darwin

class SharedMemory {
    
    static var shared: SharedMemory = {
        let instance = SharedMemory()
        return instance
    }()

    
    private let containerURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: "group.com.romas.bitmapkeyboard"
    )!
    
    private let shmSize: Int
    private let ptr: UnsafeMutableRawPointer
    private let sem: Semaphore?
    private let fd: Int32
    private let semName = "/bitmap_semaphore"
    
    var onData: ((Data) -> Void)?
    
    private init() {
        let shmPath = containerURL.appendingPathComponent("process.sharedmem").path
        // 64 MB, enough for big images
        shmSize = 1024 * 1024 * 64

        if !FileManager.default.fileExists(atPath: shmPath) {
            FileManager.default.createFile(atPath: shmPath, contents: nil)
        }

        fd = open(shmPath, O_RDWR)
        guard fd != -1 else {
            fatalError("Failed to open shared memory file")
        }
        
        if ftruncate(fd, Int64(shmSize)) != 0 {
            fatalError("ftruncate failed")
        }
        
        ptr = mmap(nil, shmSize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)
        guard ptr != MAP_FAILED else {
            fatalError("mmap failed")
        }
        
        sem = sem_open(semName, O_CREAT, S_IRUSR | S_IWUSR, 0)
    }
    
    deinit {
        munmap(ptr, shmSize)
        close(fd)
        sem_close(sem)
        sem_unlink(semName)
    }
    
    func writeData(_ data: Data) {
        let maxLen = min(data.count, shmSize - 1)
        
        let len = UInt32(data.count)
        ptr.storeBytes(of: UInt32(len), as: UInt32.self)
        
        data.withUnsafeBytes { bytes in
            guard let baseAddr = bytes.baseAddress else { return }
            memcpy(ptr.advanced(by: MemoryLayout<UInt32>.size), baseAddr, maxLen)
        }
        
        // signal companion app
        sem_post(sem)
    }
    
    func readSymbol() -> Data? {
        // block until keyboard signals
        sem_wait(sem)
        
        let length = ptr.load(as: UInt32.self)
        let buffer = ptr + MemoryLayout<UInt32>.size
        let data = Data(bytes: buffer, count: Int(length))
        
        return data
    }
    
    func startReadThread(onData: ((Data) -> Void)?) {
        self.onData = onData
        let dataQueue = DispatchQueue(label: "com.romas.bitmapkeyboard", qos: .userInteractive)
        dataQueue.async { [weak self] in
            while true {
                guard let self = self else { return }
                // blocks on sem_wait
                if let data = readSymbol() {
                    self.onData?(data)
                }
            }
        }
    }
}
