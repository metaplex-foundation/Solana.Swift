//
//  RunLoopSimpleLock.swift
//  A simple version of [RunLoopLock](https://github.com/ReactiveX/RxSwift/blob/main/RxBlocking/RunLoopLock.swift)
//  to test asynchronous functions in a synchronous way
//
//  Created by Dezork

import Foundation
import CoreFoundation

#if os(Linux)
    import Foundation
    let runLoopSimpleMode: RunLoop.Mode = .default
    let runLoopSimpleModeRaw: CFString = unsafeBitCast(runLoopSimpleMode.rawValue._bridgeToObjectiveC(), to: CFString.self)
#else
    let runLoopSimpleMode: CFRunLoopMode = CFRunLoopMode.defaultMode
    let runLoopSimpleModeRaw = runLoopSimpleMode.rawValue
#endif

final class RunLoopSimpleLock {
    let currentRunLoop = CFRunLoopGetCurrent()

    func dispatch(_ action: @escaping () -> Void) {
        CFRunLoopPerformBlock(self.currentRunLoop, runLoopSimpleModeRaw) {
            action()
        }
        CFRunLoopWakeUp(self.currentRunLoop)
    }

    func stop() {
        print("stop")
        CFRunLoopPerformBlock(self.currentRunLoop, runLoopSimpleModeRaw) {
            CFRunLoopStop(self.currentRunLoop)
        }
        CFRunLoopWakeUp(self.currentRunLoop)
    }

    func run() {
        CFRunLoopRun()
    }
}
