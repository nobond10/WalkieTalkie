//
//  RadioVC.swift
//  WalkieTalkie
//
//  Created by Ярослав Косарев on 11.11.2022.
//

import UIKit

class RadioVC: UIViewController {
    let presenter: RadioPresenter
    
    @IBOutlet weak var buttonSpeak: UIButton!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var textViewLogs: UITextView!
    @IBOutlet weak var labelDistance: UILabel!
    
    private var mainButtonState: MainButtonState = .disabled
    init(presenter: RadioPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setStatus(_ text: String, isConnectionOk: Bool) {
        DispatchQueue.main.async {
            self.labelStatus.text = text
            self.labelStatus.textColor = isConnectionOk ? .green : .red
        }
    }

    var firstViewAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstViewAppear {
            firstViewAppear = false
            presenter.onViewDidAppear()
        }
    }

    @IBAction func buttonBackClicked(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func touchDown(_ sender: Any) {
        if case .noAction = mainButtonState {
            presenter.startedHighlighing()
        }
    }
    
    @IBAction func dragOutside(_ sender: UIButton) {
        if case .tapped = mainButtonState {
            presenter.endedHighlighting()
        }
    }
}

extension RadioVC {
    func makeSpeakingButtonEnabled() {
        DispatchQueue.main.async {
            self.mainButtonState = .noAction
            self.buttonSpeak.backgroundColor = .green
            self.buttonSpeak.isEnabled = true
        }
    }
    
    func makeSpeakingButtonDisabled() {
        DispatchQueue.main.async {
            self.mainButtonState = .disabled
            self.buttonSpeak.backgroundColor = .red
            self.buttonSpeak.isEnabled = false
        }
    }
    
    func makeSpeakingButtonTapped() {
        DispatchQueue.main.async {
            self.mainButtonState = .tapped
            self.buttonSpeak.backgroundColor = .yellow
            self.buttonSpeak.isEnabled = true
        }
    }

    func addToLogs(text: String) {
        let dateFormatted = Date().logsFormatted()
        DispatchQueue.main.async {
            self.textViewLogs.text = dateFormatted + ": " + text + "\n" + self.textViewLogs.text
        }
    }

    func setDistance(_ distance: String) {
        DispatchQueue.main.async {
            self.labelDistance.text = distance
        }
    }
}
