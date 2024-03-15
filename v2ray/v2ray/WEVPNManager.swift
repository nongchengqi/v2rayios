//
//  WEVPNManager.swift
//  v2ray
//
//

import Foundation
import NetworkExtension

protocol WEVPNManagerDelegate: AnyObject {
    func manager(didChangeStatus status: WEVPNManager.WEVPNStatus)
}

class WEVPNManager {
    
    enum WEVPNStatus {
        case off
        case connecting
        case on
        case disconnecting
    }
    
    enum WEManagerError: Error {
        case invalidProvider
        case vpnStartFail
    }
    
    static let shared = WEVPNManager()
    private var observerDidAdd: Bool = false
    private(set) var vpnStatus = WEVPNStatus.off
    weak var delegate: WEVPNManagerDelegate?
    
    init() {
        loadProviderManager { [weak self] (manager) in
            if let manager = manager {
                self?.updateVPNStatus(manager)
            }
        }
        addVPNStatusObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateVPNStatus(_ manager: NEVPNManager) {
        switch manager.connection.status {
        case .connected:
            vpnStatus = .on
        case .connecting, .reasserting:
            vpnStatus = .connecting
        case .disconnecting:
            vpnStatus = .disconnecting
        case .disconnected, .invalid:
            vpnStatus = .off
        @unknown default:
            vpnStatus = .off
        }
        delegate?.manager(didChangeStatus: vpnStatus)
    }
    
    func addVPNStatusObserver() {
        if observerDidAdd {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        }
        loadProviderManager { [weak self] (manager) in
            guard let weakSelf = self else { return }
            if let manager = manager {
                weakSelf.observerDidAdd = true
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main, using: { [weak self] (notification) -> Void in
                    self?.updateVPNStatus(manager)
                })
            }
        }
    }
}

extension WEVPNManager {
    
    func loadAndCreateProviderManager(complete: @escaping (NETunnelProviderManager?, Error?) -> Void ) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard let managers = managers else { return }
            let manager: NETunnelProviderManager
            if (managers.count > 0) {
                manager = managers[0]
            } else {
                manager = NETunnelProviderManager()
                manager.protocolConfiguration = NETunnelProviderProtocol()
            }
            manager.isEnabled = true
            manager.localizedDescription = "v2ray VPN"
            manager.protocolConfiguration?.serverAddress = "127.0.0.1:1080"
            manager.saveToPreferences { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    complete(nil, error)
                } else {
                    manager.loadFromPreferences(completionHandler: { (error) -> Void in
                        if let error = error {
                            complete(nil, error)
                        } else {
                            self.addVPNStatusObserver()
                            complete(manager, nil)
                        }
                    })
                }
            }
            
        }
    }
    
    private func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let managers = managers {
                if managers.count > 0 {
                    let manager = managers[0]
                    complete(manager)
                    return
                }
            }
            complete(nil)
        }
    }
}

extension WEVPNManager {
    
    public func startVPN(complete: ((NETunnelProviderManager?, Error?) -> Void)? = nil) {
        loadAndCreateProviderManager() { (manager, error) in
            if let error = error {
                complete?(nil, error)
            } else {
                guard let manager = manager else {
                    complete?(nil, WEManagerError.invalidProvider)
                    return
                }
                if manager.connection.status == .disconnected || manager.connection.status == .invalid {
                    do {
                        try manager.connection.startVPNTunnel()
                        complete?(manager, nil)
                    } catch {
                        complete?(nil, error)
                    }
                } else {
                    complete?(manager, nil)
                }
            }
        }
    }
    
    public func stopVPN() {
        loadProviderManager { manager in
            guard let manager = manager else { return }
            manager.connection.stopVPNTunnel()
        }
    }
    
    public func sendMessage() {
        loadProviderManager { manager in
            guard let manager = manager else { return }
            let session = manager.connection as? NETunnelProviderSession
            let message = "reload".data(using: .utf8)
            try? session?.sendProviderMessage(message ?? Data(), responseHandler: nil)
        }
    }
}
