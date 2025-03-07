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

struct PlaylistList: View {
    init(playlist: Playlist) {
        self.playlist = playlist
        self._accentColor = .init(wrappedValue: playlist.accentColor?.cgColor ?? .clear)
    }
    
    let playlist: Playlist
    @State private var selection = Set<PersistentIdentifier>()
    @State private var accentColor: CGColor
    @Environment(PlayQueue.self) private var playQueue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    @Bindable var playlist = playlist
                    
                    Image(systemName: "music.note.list")
                        .imageScale(.large)
                    TextField("Playlist Name", text: $playlist.name)
                        .textFieldStyle(.plain)
                        .font(.title)
                    ColorPicker("", selection: $accentColor, supportsOpacity: true)
                }
                HStack {
                    Button {
                        do {
                            try playQueue.play(playlist.songs.shuffled())
                        } catch {
                            TaskErrors.all.present(error)
                        }
                    } label: {
                        Label("Shuffle", systemImage: "shuffle")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            Divider()
            List(selection: $selection) {
                ForEach(playlist.songs) { song in
                    Text(verbatim: song.title ?? "--")
                        .draggable(LibraryItem(from: song))
                }
                .onMove { offsets, destination in
                    playlist.songs.move(fromOffsets: offsets, toOffset: destination)
                }
                .onDelete { offsets in
                    playlist.songs.remove(atOffsets: offsets)
                }
            }
            .contextMenu { selection in
                Button("Remove from Playlist") {
                    playlist.songs.removeAll(where: { selection.contains($0.id) })
                }
                Divider()
                ItemContextMenuContent(selection: selection)
            } primaryAction: { selection in
                guard let songID = selection.first,
                      let songPosition = playlist.songs.firstIndex(where: { $0.id == songID }) else {
                    return
                }
                do {
                    try playQueue.play(playlist.songs, startingAt: songPosition)
                } catch {
                    TaskErrors.all.present(error)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(white: 0.0, opacity: 0.1))
        }
        .onChange(of: accentColor) {
            playlist.accentColor = RGBColor(cgColor: accentColor)
        }
        .accentColor(Color(cgColor: accentColor))
        .background(Color(cgColor: accentColor).brightness(-0.2))
    }
}
