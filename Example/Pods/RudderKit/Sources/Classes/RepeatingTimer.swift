//
//  RepeatingTimer.swift
//  RudderKit
//
//  Created by Pallab Maiti on 12/07/23.
//

import Foundation

public class RepeatingTimer {
    enum State {
        case suspended
        case resumed
    }
    
    let interval: TimeInterval
    let timer: DispatchSourceTimer
    let queue: DispatchQueue
    let handler: () -> Void
    
    var state: State = .suspended
    
    static var timers = [RepeatingTimer]()
    
    static public func schedule(interval: TimeInterval, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        let timer = RepeatingTimer(interval: interval, queue: queue, handler: handler)
        Self.timers.append(timer)
    }
    
    public init(interval: TimeInterval, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        self.interval = interval
        self.queue = queue
        self.handler = handler
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + self.interval, repeating: self.interval)
        timer.setEventHandler { [weak self] in
            self?.handler()
        }
        resume()
    }
    
    deinit {
        cancel()
    }
    
    public func cancel() {
        timer.setEventHandler {
            // do nothing ...
        }
        // if timer is suspended, we must resume if we're going to cancel.
        timer.cancel()
        resume()
    }
    
    public func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
    public func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
}
