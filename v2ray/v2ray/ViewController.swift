//
//  ViewController.swift
//  v2ray
//
//

import UIKit

class ViewController: UIViewController, WEVPNManagerDelegate {
    func manager(didChangeStatus status: WEVPNManager.WEVPNStatus) {
        switch status {
        case .off:
            slider.isOn = false
        case .on:
            slider.isOn = true
        default:
            break
        }
    }
    

    @IBOutlet weak var slider: UISwitch!
    private var manager = WEVPNManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        manager.delegate = self
    }

    @IBAction func valueChange(_ sender: UISwitch) {
        if manager.vpnStatus == .on {
            manager.stopVPN()
        } else {
            manager.startVPN()
        }
    }
}

