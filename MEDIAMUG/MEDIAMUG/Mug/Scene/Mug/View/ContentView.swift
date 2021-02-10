//
//  ContentView.swift
//  VIDEOMUG
//
//  Created by hbkim on 2021/02/08.
//

import SwiftUI
import AVKit
import SwiftUI
import UIKit
import YouTubePlayer
import LinkPresentation

struct ContentView: View {

//    private let player = AVPlayer(url: URL(string: "https://youtu.be/pNk-QA8OxWU")!)

    var controlState: YouTubeControlState = {
        var controlState = YouTubeControlState()
        controlState.videoID = "pNk-QA8OxWU"
        return controlState
    }()

//    init(playerState: YouTubeControlState) {
//        self.controlState = playerState
//    }

    var body: some View {

//
        VStack {
            YouTubeView(playerState: controlState)

//            VideoPlayer(player: player)
//                .onAppear() {
//                    player.play()
//                }

            Text("Hello, world!")
                .padding()

            Button(action: {
                  let metadataProvider = LPMetadataProvider()
              let url = URL(string: "https://www.youtube.com/watch?v=pNk-QA8OxWU")!
                  metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
                      guard let data = metadata, error == nil else {
                          return
                      }
                    print("title " + data.title!)
//                    data
//                      self.metaData = data
                  }
//                let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
//
//                UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { success, error in
//                        if let error = error {
//                            print("Error: \(error)")
//                        }
//                    }
            }) {
                Text("알람")
            }.padding()


            Button(action: {
                alert()
            }) {
                Text("알람")
            }.padding()
        }
    }

    func alert() {

        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Wake up!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Rise and shine! It's morning time!",
                                                                arguments: nil)
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "TIMER_EXPIRED"
        // Configure the trigger for a 7am wakeup.

        let date = Date().addingTimeInterval(TimeInterval(10))
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute, .second], from: date)
        var dateInfo = DateComponents()
        dateInfo.hour = comps.hour
        dateInfo.minute = comps.minute
        dateInfo.second = comps.second
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        print("언제 울릴거야? \(dateInfo.hour!):\(dateInfo.minute!):\(dateInfo.second!)")

        // Create the request object.
        let request = UNNotificationRequest(identifier: "MorningAlarm", content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()

        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

final class YouTubeView: UIViewRepresentable {

    typealias UIViewType = YouTubePlayerView

    @ObservedObject var playerState: YouTubeControlState

    init(playerState: YouTubeControlState) {
        self.playerState = playerState
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(playerState: playerState)
    }

    func makeUIView(context: Context) -> UIViewType {
        let playerVars = [
            "controls": "1",
            "playsinline": "0",
            "autohide": "0",
            "autoplay": "0",
            "fs": "1",
            "rel": "0",
            "loop": "0",
            "enablejsapi": "1",
            "modestbranding": "1"
        ]

        let ytVideo = YouTubePlayerView()

        ytVideo.playerVars = playerVars as YouTubePlayerView.YouTubePlayerParameters
        ytVideo.delegate = context.coordinator

        return ytVideo
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

        guard let videoID = playerState.videoID else { return }

        if !(playerState.executeCommand == .idle) && uiView.ready {
            switch playerState.executeCommand {
            case .loadNewVideo:
                playerState.executeCommand = .idle
                uiView.loadVideoID(videoID)
            case .play:
                playerState.executeCommand = .idle
                uiView.play()
            case .pause:
                playerState.executeCommand = .idle
                uiView.pause()
            case .forward:
            playerState.executeCommand = .idle
                uiView.getCurrentTime { (time) in
                    guard let time = time else {return}
                    uiView.seekTo(Float(time) + 10, seekAhead: true)
                }
            case .backward:
                playerState.executeCommand = .idle
                uiView.getCurrentTime { (time) in
                    guard let time = time else {return}
                    uiView.seekTo(Float(time) - 10, seekAhead: true)
                }
            default:
                playerState.executeCommand = .idle
                print("\(playerState.executeCommand) not yet implemented")
            }
        } else if !uiView.ready {
            uiView.loadVideoID(videoID)
        }

    }

    class Coordinator: YouTubePlayerDelegate {
        @ObservedObject var playerState: YouTubeControlState

        init(playerState: YouTubeControlState) {
            self.playerState = playerState
        }

        func playerReady(_ videoPlayer: YouTubePlayerView) {
            videoPlayer.play()
            playerState.videoState = .play
        }

        func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {

            switch playerState {
            case .Playing:
                self.playerState.videoState = .play
            case .Paused, .Buffering, .Unstarted:
                self.playerState.videoState = .pause
            case .Ended:
                self.playerState.videoState = .stop
//                self.playerState.videoID = loadNextVideo()
            default:
                print("\(playerState) not implemented")
            }
        }
    }
}

enum playerCommandToExecute {
    case loadNewVideo
    case play
    case pause
    case forward
    case backward
    case stop
    case idle
}

// 2
class YouTubeControlState: ObservableObject {

    // 3
    @Published var videoID: String? // = "qRC4Vk6kisY"
    {
        // 4
        didSet {
            self.executeCommand = .loadNewVideo
        }
    }

    // 5
    @Published var videoState: playerCommandToExecute = .loadNewVideo

    // 6
    @Published var executeCommand: playerCommandToExecute = .idle

    // 7
    func playPauseButtonTapped() {
        if videoState == .play {
            pauseVideo()
        } else if videoState == .pause {
            playVideo()
        } else {
            print("Unknown player state, attempting playing")
            playVideo()
        }
    }

    // 8
    func playVideo() {
        executeCommand = .play
    }

    func pauseVideo() {
        executeCommand = .pause
    }

    func forward() {
        executeCommand = .forward
    }

    func backward() {
        executeCommand = .backward
    }
}
