//
//  SZAVPlayerConfig.swift
//  SZAVPlayer
//
//  Created by CaiSanze on 2020/1/6.
//

import UIKit
import AVKit

public struct SZAVPlayerConfig {

    public var url: URL?                // The URL value for playing.
    public var uniqueID: String?        // The uniqueID to identify wether they are the same audio. If set to nil will use url to create one.
    public var isVideo: Bool            // Is video or not.
    public var isVideoOutputEnabled: Bool           // Output video image function enabled or not.
    public var timeObserverInterval: Float64 = 1    // TimeObserver interval, default value is 1s.
    public var videoGravity: AVLayerVideoGravity = .resizeAspect

    /// If set to ture, the asset will be loaded with the system's own way. It is suitable for situations like
    /// local files or you don't needed custom loading.
    public var disableCustomLoading: Bool = false

    public var headersForContentInfoRequest: [String: String]?
    public var headersForDataRequest: [String: String]?

    public init(url: URL?, uniqueID: String?, isVideo: Bool = false, isVideoOutputEnabled: Bool = false) {
        self.url = url
        self.uniqueID = uniqueID
        self.isVideo = isVideo
        self.isVideoOutputEnabled = isVideoOutputEnabled
    }

    public static var `default`: SZAVPlayerConfig {
        return SZAVPlayerConfig(url: URL(string: "fakerURL.com"), uniqueID: nil)
    }

}
