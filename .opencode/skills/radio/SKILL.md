---
name: radio
description: Use when modifying the music radio feature. Documents the RadioConfig backend, music directory structure, JSON format, import/reorder/delete workflow, and QML integration.
---

# Radio (Music) Skill

This skill documents the music radio feature, including the backend data model, file storage structure, and QML frontend integration.

## Architecture

```
RadioConfig (C++ backend)  <-- QML context property "radioConfig" -->  RadioConfigPage.qml
     SongItem struct                                                    ListModel (songModel)
     loadConfig()                                                       MediaPlayer
     saveConfig()                                                       FileDialog (import/cover)
     importSong()
     importCover()
     reindex()
```

## Key Files

| File | Role |
|---|---|
| `src/backend/radio/RadioConfig.h` | SongItem struct + RadioConfig class declaration |
| `src/backend/radio/RadioConfig.cpp` | Config load/save, import, reorder, delete logic |
| `src/frontend/qml/pages/RadioConfigPage.qml` | Song grid UI, playback, import dialogs |

## Directory Structure

```
music/                          # appDir/music/
├── radio_config.json           # Song list config
├── 001/
│   ├── 001.mp3                # Audio file (named after directory id)
│   └── cover.bin              # Cover image (optional, any image format)
├── 002/
│   ├── 002.mp3
│   └── cover.bin
└── ...
```

## JSON Format

```json
{
    "songs": [
        {
            "id": "001",
            "title": "Song Title",
            "mp3": "001/001.mp3",
            "cover": "001/cover.bin"
        }
    ]
}
```

- `id`: 3-digit zero-padded number matching directory name
- `title`: Display name (from original MP3 filename on import)
- `mp3`: Relative path `NNN/NNN.mp3`
- `cover`: Relative path `NNN/cover.bin` (empty string if no cover)

## SongItem Struct

```cpp
struct SongItem {
    QString id;      // "001"
    QString title;   // Display name
    QString mp3;     // "001/001.mp3"
    QString cover;   // "001/cover.bin" or ""
};
```

## RadioConfig API

### Config I/O

```cpp
Q_INVOKABLE bool loadConfig();                    // Load from music/radio_config.json
Q_INVOKABLE bool saveConfig();                    // Save to music/radio_config.json
Q_INVOKABLE QVariantList getSongList() const;     // Return song list as QVariantList
Q_INVOKABLE int songCount() const;
```

### Song Management

```cpp
Q_INVOKABLE void addSong(id, title, mp3, cover);  // Add song to list
Q_INVOKABLE void removeSong(int index);           // Remove + delete physical directory
Q_INVOKABLE void moveSong(int from, int to);      // Reorder + rename physical dirs/files
Q_INVOKABLE void updateSongCover(int idx, cover); // Update cover path for a song
```

### Import

```cpp
Q_INVOKABLE QString musicDir() const;                                    // appDir/music/
Q_INVOKABLE QString importSong(const QString &srcFilePath);              // Returns id "NNN"
Q_INVOKABLE QString importCover(const QString &srcFilePath, const QString &subDir); // Returns "NNN/cover.bin"
```

## Reorder Logic (reindex)

When songs are reordered, physical directories and files are renamed to match new positions:

1. Capture old ids from current song list
2. Update in-memory ids, mp3 paths, cover paths to new positions
3. Copy directories to `_tmp_NNN` temp names (avoid conflicts)
4. Copy from `_tmp_NNN` to final `NNN` names
5. Rename any leftover mp3 files inside to `NNN.mp3`
6. Delete temp directories

## Import Workflow (QML)

1. User clicks "Add Song" card -> `fileDialog` opens (MP3 filter)
2. `radioConfig.importSong(srcPath)` copies file to `music/NNN/NNN.mp3`, returns id
3. `coverFileDialog` opens (image filter, skippable)
4. If cover selected: `radioConfig.importCover(srcPath, id)` copies to `music/NNN/cover.bin`
5. Song added to model and config, `saveConfig()` called

## Delete Workflow

1. Delete button clicked -> `deleteConfirmDialog` opens
2. On confirm: `mediaPlayer.stop()` + `mediaPlayer.source = ""` (release file lock on Windows)
3. `radioConfig.removeSong(index)` deletes physical directory + removes from list
4. `reindex()` renumbers remaining songs
5. `syncModelFromBackend()` refreshes UI model

## Path Construction in QML

```qml
// Audio source
"file:///" + radioConfig.musicDir() + "/" + model.mp3

// Cover image
"file:///" + radioConfig.musicDir() + "/" + model.cover
```

## Important Notes

- **File locking on Windows**: Always stop MediaPlayer and clear source before deleting songs
- **Reorder renames physical files**: Directory names and mp3 filenames always match the id
- **Migration support**: `loadConfig()` auto-migrates old format (name/filePath/coverPath) to new format
- **Cover is optional**: cover field can be empty string
- **Title from filename**: On import, title is set to the original MP3 filename (without extension)
