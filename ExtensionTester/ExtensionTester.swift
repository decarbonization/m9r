/*
 * The Listening Room Project
 * Copyright (C) 2025  MAINTAINERS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import ListeningRoomExtensionSDK
import ExtensionFoundation
import ExtensionKit
import SwiftUI

@main struct ExtensionTester: ListeningRoomExtension {
    var features: some ListeningRoomExtensionFeature {
        ListeningRoomSidebarSection(title: "Extension Tester") {
            ListeningRoomExtensionFeatureLink(sceneID: "play-queue",
                                              title: "Play Queue",
                                              systemImage: "music.note.list")
        }
    }
    
    var body: some AppExtensionScene {
        ListeningRoomExtensionScene(id: "play-queue") {
            PlayQueueTesterView()
        }
    }
}
