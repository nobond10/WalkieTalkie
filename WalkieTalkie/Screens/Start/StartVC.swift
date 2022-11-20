//
//  StartVC.swift
//  WalkieTalkie
//
//  Created by Ярослав Косарев on 11.11.2022.
//

import UIKit

class StartVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func goToRadio(forJoiner: Bool) {
        let mode: Mode = forJoiner ? .joiner : .hoster
        let vc = RadioCreator.createModule(for: mode)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @IBAction func createClicked(_ sender: Any) {
        goToRadio(forJoiner: false)
    }

    @IBAction func joinClicked(_ sender: Any) {
        goToRadio(forJoiner: true)
    }
}
