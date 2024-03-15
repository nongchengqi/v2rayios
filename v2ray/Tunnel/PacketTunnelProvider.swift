//
//  PacketTunnelProvider.swift
//  Tunnel
//
//
//

import NetworkExtension

enum WETunnelError:Error {
    case unValid
}

let conf = """
log-level: debug
tun:
  enable: true
  device-id: "fd://REPLACE-ME-WITH-THE-FD"
model: rule
proxies:
- name: proxy
  type: ss
  server: xxxxxx
  port: 10086
  cipher: chacha20-ietf-poly1305
  password: xxxxxx
mmdb: test.mmdb
rules:
- IP-CIDR,114.114.0.0/15,DIRECT
- IP-CIDR,223.5.0.0/15,DIRECT
- IP-CIDR,8.8.0.0/15,DIRECT
- MATCH, proxy
"""

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let tunnelNetworkSettings = createTunnelSettings()
        setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            guard let self = self else { return }
            let tunFd = self.getTunFd() ?? 4
            let confWithFd = conf.replacingOccurrences(of: "REPLACE-ME-WITH-THE-FD", with: String(tunFd))
            let manager = FileManager.default
            let urlForDocument = manager.urls(for: .documentDirectory, in:.userDomainMask)
            let fileBaseUrl = urlForDocument[0]
            let url = createFile(name: "example.yaml", fileBaseUrl: fileBaseUrl)
            do {
                try confWithFd.write(to: url, atomically: false, encoding: .utf8)
            } catch {
                NSLog("fialed to write config file \(error)")
            }
            DispatchQueue.global(qos: .userInteractive).async {
                signal(SIGPIPE, SIG_IGN)
                vpn_run(url.path)
            }
            completionHandler(nil)
        }
    }
    
    private func createFile(name:String, fileBaseUrl:URL) -> URL {
        let manager = FileManager.default
        let file = fileBaseUrl.appendingPathComponent(name)
        debugPrint("文件: \(file)")
        let exist = manager.fileExists(atPath: file.path)
        if !exist {
            let data = Data(base64Encoded:"aGVsbG8gd29ybGQ=" ,options:.ignoreUnknownCharacters)
            let createSuccess = manager.createFile(atPath: file.path,contents:data,attributes:nil)
            debugPrint("文件创建结果: \(createSuccess)")
        }
        return file
    }
    
    private func getTunFd() -> Int32? {
        if #available(iOS 15, *) {
            var buf = [CChar](repeating: 0, count: Int(IFNAMSIZ))
            let utunPrefix = "utun".utf8CString.dropLast()
            return (0...1024).first { (_ fd: Int32) -> Bool in
                var len = socklen_t(buf.count)
                return getsockopt(fd, 2, 2, &buf, &len) == 0 && buf.starts(with: utunPrefix)
            }
        } else {
            return self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as? Int32
        }
    }
    
    func createTunnelSettings() -> NEPacketTunnelNetworkSettings  {
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "240.0.0.10")
        newSettings.ipv4Settings = NEIPv4Settings(addresses: ["240.0.0.1"], subnetMasks: ["255.255.255.0"])
        newSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.`default`()]
        newSettings.proxySettings = nil
        newSettings.dnsSettings = NEDNSSettings(servers: ["223.5.5.5", "8.8.8.8", "114.114.114.114"])
        newSettings.mtu = 1500
        return newSettings
    }
    
}
