//
//  AudioViewController.swift
//  SZAVPlayer_Example
//
//  Created by CaiSanze on 2019/11/29.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SZAVPlayer
import SnapKit

class AudioViewController: UIViewController {

    private lazy var audioTitleLabel: UILabel = createTitleLabel()
    private lazy var progressView: AudioPlayerProgressView = createProgressView()
    private lazy var playBtn: UIButton = createPlayBtn()
    private lazy var previousBtn: UIButton = createPreviousBtn()
    private lazy var nextBtn: UIButton = createNextBtn()
    private lazy var cleanCacheBbtn: UIButton = createCleanCacheBtn()

    private lazy var audioPlayer: SZAVPlayer = createAudioPlayer()
    private let audios: [FakeAudio] = [
        FakeAudio.fake1(),
        FakeAudio.fake2(),
        FakeAudio.fake3(),
    ]
    private var currentAudio: FakeAudio?
    private var isPaused: Bool = false
    private var playerControllerEvent: PlayerControllerEventType = .none {
        didSet {
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: playerControllerEvent)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        addSubviews()
        SZAVPlayerCache.shared.setup(maxCacheSize: 100)

        currentAudio = audios.first
        updateView()
    }

}

// MARK: - Configure UI

extension AudioViewController {

    private func updateView() {
        guard let audio = currentAudio else {
            return
        }

        audioTitleLabel.text = audio.title

        if let _ = findAudio(currentAudio: audio, findNext: true) {
            nextBtn.isEnabled = true
        } else {
            nextBtn.isEnabled = false
        }

        if let _ = findAudio(currentAudio: audio, findNext: false) {
            previousBtn.isEnabled = true
        } else {
            previousBtn.isEnabled = false
        }

        if playerControllerEvent == .playing {
            playBtn.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            playBtn.setImage(UIImage(named: "play"), for: .normal)
        }

    }

    private func addSubviews() {
        view.addSubview(audioTitleLabel)
        audioTitleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-120)
        }

        view.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-70)
        }

        view.addSubview(playBtn)
        playBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.center.equalToSuperview()
        }

        view.addSubview(nextBtn)
        nextBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.centerX.equalToSuperview().offset(100)
            make.centerY.equalToSuperview()
        }

        view.addSubview(previousBtn)
        previousBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.centerX.equalToSuperview().offset(-100)
            make.centerY.equalToSuperview()
        }

        view.addSubview(cleanCacheBbtn)
        cleanCacheBbtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
    }

}

// MARK: - Actions

extension AudioViewController {

    @objc func handlePlayBtnClick() {
        if playerControllerEvent == .playing {
            pauseAudio()
        } else {
            playAudio()
        }
    }

    @discardableResult
    @objc func handleNextBtnClick() -> Bool {
        isPaused = false
        var handleResult: Bool = false
        if let currentAudio = currentAudio,
            let audio = findAudio(currentAudio: currentAudio, findNext: true)
        {
            self.currentAudio = audio
            progressView.reset()
            playAudio()
            handleResult = true
        } else {
            SZLogError("No audio!")
        }

        updateView()

        return handleResult
    }

    @discardableResult
    @objc func handlePreviousBtnClick() -> Bool {
        isPaused = false
        var handleResult: Bool = false
        if let currentAudio = currentAudio,
            let audio = findAudio(currentAudio: currentAudio, findNext: false)
        {
            self.currentAudio = audio
            progressView.reset()
            playAudio()
            handleResult = true
        } else {
            SZLogError("No audio!")
        }

        updateView()

        return handleResult
    }

    private func handlePlayEnd() {
        if let currentAudio = currentAudio,
            let _ = findAudio(currentAudio: currentAudio, findNext: true)
        {
            handleNextBtnClick()
        } else {
            playerControllerEvent = .none
            audioPlayer.reset()
            updateView()
        }
    }

    private func playAudio() {
        guard let audio = currentAudio else {
            return
        }

        if isPaused {
            isPaused = false
            audioPlayer.play()
        } else {
            audioPlayer.pause()
            var config = SZAVPlayerConfig(url: audio.url, uniqueID: nil)
            config.headersForContentInfoRequest = [
                "header1": "111",
                "header2": "222"
            ]
            config.headersForDataRequest = [
                "header3": "333",
                "header4": "444"
            ]
            audioPlayer.setupPlayer(config: config)
        }
        playerControllerEvent = .playing
        updateView()

        SZAVPlayer.activeAudioSession()
    }

    private func pauseAudio() {
        isPaused = true
        audioPlayer.pause()
        playerControllerEvent = .paused
        updateView()
    }

    private func findAudio(currentAudio: FakeAudio, findNext: Bool) -> FakeAudio? {
        let playlist = audios
        let audios = findNext ? playlist : playlist.reversed()
        var currentAudioDetected: Bool = false
        for audio in audios {
            if currentAudioDetected {
                return audio
            } else if audio == currentAudio {
                currentAudioDetected = true
            }
        }

        return nil
    }

    @objc private func handleCleanCacheBtnClick() {
        SZAVPlayerCache.shared.cleanCache()

        let alert = UIAlertController(title: "Clean Succeed~", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - AudioPlayerProgressViewDelegate

extension AudioViewController: AudioPlayerProgressViewDelegate {

    func progressView(_ progressView: AudioPlayerProgressView, didChanged currentTime: Float64) {
        audioPlayer.seekPlayerToTime(time: currentTime, completion: nil)
    }

}

// MARK: - SZAVPlayerDelegate

extension AudioViewController: SZAVPlayerDelegate {

    func avplayer(_ avplayer: SZAVPlayer, refreshed currentTime: Float64, loadedTime: Float64, totalTime: Float64) {
        progressView.update(currentTime: currentTime, totalTime: totalTime)
    }

    func avplayer(_ avplayer: SZAVPlayer, didChanged status: SZAVPlayerStatus) {
        switch status {
        case .readyToPlay:
            SZLogInfo("ready to play")
            if playerControllerEvent == .playing {
                audioPlayer.play()
            }
        case .playEnd:
            SZLogInfo("play end")
            handlePlayEnd()
        case .loading:
            SZLogInfo("loading")
        case .loadingFailed:
            SZLogInfo("loading failed")
        case .bufferBegin:
            SZLogInfo("buffer begin")
        case .bufferEnd:
            SZLogInfo("buffer end")
            if playerControllerEvent == .stalled {
                audioPlayer.play()
            }
        case .playbackStalled:
            SZLogInfo("playback stalled")
            playerControllerEvent = .stalled
        }
    }

    func avplayer(_ avplayer: SZAVPlayer, didReceived remoteCommand: SZAVPlayerRemoteCommand) -> Bool {
        switch remoteCommand {
        case .next:
            return handleNextBtnClick()
        case .previous:
            return handlePreviousBtnClick()
        case .play:
            playAudio()
        case .pause:
            pauseAudio()
        }

        return true
    }

}

// MARK: - Getter

extension AudioViewController {

    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .black

        return label
    }

    private func createProgressView() -> AudioPlayerProgressView {
        let view = AudioPlayerProgressView()
        view.delegate = self

        return view
    }

    private func createAudioPlayer() -> SZAVPlayer {
        let player = SZAVPlayer()
        player.delegate = self

        return player
    }

    private func createPlayBtn() -> UIButton {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(handlePlayBtnClick), for: .touchUpInside)
        btn.setImage(UIImage(named: "play"), for: .normal)

        return btn
    }

    private func createPreviousBtn() -> UIButton {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(handlePreviousBtnClick), for: .touchUpInside)
        btn.setImage(UIImage(named: "previous"), for: .normal)

        return btn
    }

    private func createNextBtn() -> UIButton {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(handleNextBtnClick), for: .touchUpInside)
        btn.setImage(UIImage(named: "next"), for: .normal)

        return btn
    }

    private func createCleanCacheBtn() -> UIButton {
        let btn = UIButton()
        btn.setTitle("Clean Cache", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(handleCleanCacheBtnClick), for: .touchUpInside)

        return btn
    }

}
