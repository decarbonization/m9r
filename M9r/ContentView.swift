/*
 * M9r
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

import SwiftData
import SwiftUI

struct ContentView: View {
    @State var isPresentingQueue = false
    
    var body: some View {
        NavigationSplitView {
            List {
                Section("Library") {
                    NavigationLink("All Albums", value: AllAlbumsDestination())
                    NavigationLink("All Artists", value: AllArtistsDestination())
                    NavigationLink("All Songs", value: AllSongsDestination())
                }
                Section("Playlists") {
                    
                }
            }
            .navigationDestination(for: AllAlbumsDestination.self) { _ in
                AlbumList()
            }
            .navigationDestination(for: AllArtistsDestination.self) { _ in
                ArtistList()
            }
            .navigationDestination(for: AllSongsDestination.self) { _ in
                SongList()
            }
        } detail: {
            NavigationStack {
                EmptyView()
            }
        }
        .toolbar {
            NowPlaying()
            PlaybackControls()
            Button("Queue") {
                isPresentingQueue = true
            }
            .popover(isPresented: $isPresentingQueue) {
                QueueList()
            }
        }
    }
}
