import Foundation
import Network

protocol ConnectivityObserving {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
}

final class Reachability: ConnectivityObserving {
    private let monitor: NWPathMonitor

    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = {
            print($0.debugDescription)
        }
    }

    func startMonitoring() {
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    var isConnected: Bool {
        let networkStatus = monitor.currentPath.status

        return networkStatus == .satisfied
    }
}
