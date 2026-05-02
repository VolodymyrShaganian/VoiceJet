# VoiceJet

Small Linux voice input helper for JetBrains IDEs.

It records audio with a hotkey, transcribes it locally with `faster-whisper`, optionally cleans the text with OpenAI, and pastes it into the active JetBrains IDE window.

## Features

- `F8` starts and stops recording
- `Ctrl+Alt+Q` exits
- Faster Whisper transcription
- OpenAI text cleanup layer
- Safe paste only into JetBrains IDE windows
- Clipboard fallback for non-JetBrains windows
- Small `REC` overlay while recording
- System tray menu

## Requirements

Linux with X11 is expected.

System packages:

```bash
sudo apt install xdotool pulseaudio-utils python3-tk
```

`python3-tk` is only needed for the floating `REC` overlay.

## Setup

```bash
git clone https://github.com/your-username/VoiceJet.git
cd VoiceJet

python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt

cp .env.example .env
```

Edit `.env` and set:

```env
OPENAI_API_KEY=your_openai_api_key_here
```

## Configuration

All main runtime settings are configured through `.env`:

```env
OPENAI_MODEL=gpt-4.1-mini

TRANSCRIBE_PROVIDER=local
OPENAI_TRANSCRIBE_MODEL=gpt-4o-transcribe
OPENAI_TRANSCRIBE_LANGUAGE=uk
OPENAI_TRANSCRIBE_PROMPT=
OPENAI_TRANSCRIBE_FALLBACK_LOCAL=true
OPENAI_COST_LOG=true

WHISPER_MODEL=small
WHISPER_DEVICE=cpu
WHISPER_COMPUTE_TYPE=int8
WHISPER_DOWNLOAD_ROOT=
WHISPER_LANGUAGE=uk
WHISPER_BEAM_SIZE=1

SAMPLE_RATE=16000
AUDIO_CHANNELS=1
AUDIO_FILENAME=/tmp/voice_input.wav
PASTE_DELAY=0.1

HOTKEY_TOGGLE_RECORDING=<f8>
HOTKEY_EXIT=<ctrl>+<alt>+q

LOCK_FILE=/tmp/voicejet.lock
```

Configuration is read when the app process starts. After changing `.env` or shell environment variables, fully quit VoiceJet and start it again. No rebuild is needed.

Transcription can run locally with Whisper or through OpenAI:

```env
TRANSCRIBE_PROVIDER=local
```

```env
TRANSCRIBE_PROVIDER=openai
OPENAI_TRANSCRIBE_MODEL=gpt-4o-transcribe
```

For a cheaper OpenAI transcription model, use:

```env
OPENAI_TRANSCRIBE_MODEL=gpt-4o-mini-transcribe
```

When `TRANSCRIBE_PROVIDER=openai`, the local Whisper model is not loaded at startup. If OpenAI transcription fails and `OPENAI_TRANSCRIBE_FALLBACK_LOCAL=true`, the app falls back to local Whisper. `OPENAI_COST_LOG=true` prints an estimated OpenAI transcription cost after each successful OpenAI transcription when usage data is returned by the API.

Hotkey syntax follows `pynput` global hotkey format. Examples:

```env
HOTKEY_TOGGLE_RECORDING=<f8>
HOTKEY_EXIT=<ctrl>+<alt>+q
```

```env
HOTKEY_TOGGLE_RECORDING=<ctrl>+<alt>+r
HOTKEY_EXIT=<ctrl>+<shift>+q
```

## Whisper Models

These settings are used when `TRANSCRIBE_PROVIDER=local`, or when OpenAI transcription falls back to local Whisper. Whisper models trade speed for recognition quality:

```text
tiny    fastest, lowest quality; good for very short commands
base    fast, acceptable quality; good when latency matters most
small   slower, better quality; good default for dictation on CPU
medium  much slower, better quality; usually too heavy for quick CPU dictation
large   best quality, very slow on CPU; better suited for GPU or offline transcription
```

For this project, `small` with `WHISPER_BEAM_SIZE=1` is a practical default. If latency matters more than accuracy, try `base`. If recognition is bad, keep `small` and increase `WHISPER_BEAM_SIZE` to `3`.

`WHISPER_BEAM_SIZE` also affects speed and quality:

```text
1  fastest, may make more mistakes
3  balanced
5  more accurate, slower
```

## Usage

```bash
.venv/bin/python voice_input.py
```

Controls:

```text
F8                start/stop recording by default
Ctrl+Alt+Q        exit by default
Tray left click   start/stop recording
```

Tray icon states:

```text
green play triangle  stopped, ready to record
red circle           recording
orange ring          processing transcription/GPT output
```

Click the tray icon to start or stop recording. Some Ubuntu/GNOME tray backends do not expose a reliable context menu, so `Ctrl+Alt+Q` is the stable exit shortcut:

```text
left click     start/stop recording
Ctrl+Alt+Q     exit
```

## Desktop Launcher

Install a desktop launcher:

```bash
chmod +x install_desktop_entry.sh
./install_desktop_entry.sh
```

Then open the Ubuntu app launcher, search for `VoiceJet`, start it, and pin it to the dock.

On Ubuntu/GNOME the installer also tries to add `VoiceJet` to Favorites automatically.

Only one app instance is allowed. Clicking the launcher again while the app is already running exits immediately.

The launcher runs the project venv directly:

```text
.venv/bin/python voice_input.py
```

If you move the project folder, run `./install_desktop_entry.sh` again.

Voice prefixes:

```text
код:       returns clean Python code only
коментар:  returns a formatted code comment
текст:     returns cleaned natural text
```

Without a prefix, the text is cleaned as smart dictation. The assistant does not answer the dictated content.

## Safe Paste

The script pastes only when the active window looks like a JetBrains IDE:

```text
PyCharm
PhpStorm
IntelliJ
WebStorm
jetbrains
```

Pasting uses the clipboard temporarily and clears it immediately after the paste attempt.

If another window is active, paste is canceled, the clipboard is cleared, and this message is printed:

```text
Не JetBrains вікно. Вставку скасовано, буфер очищено.
```

## Notes

- `.env` is ignored by git. Do not commit your API key.
- If OpenAI fails, the original transcribed text is used.
- First Whisper run can be slower because the model may need to download or warm up.
- Set `WHISPER_DOWNLOAD_ROOT` if you want Whisper models cached in a project-specific directory.
- GPU can be used by setting `WHISPER_DEVICE=cuda` and a compatible compute type, but CPU is the default.

## GitLab

Initialize the repository:

```bash
git init
git add voice_input.py README.md requirements.txt .env.example .gitignore install_desktop_entry.sh voice-to-jetbrains.desktop.template assets/voice-to-jetbrains.svg
git commit -m "Initial voice input helper"
```

Create an empty GitLab project, then connect and push:

```bash
git remote add origin git@gitlab.com:your-username/VoiceJet.git
git branch -M main
git push -u origin main
```

Check that `.env` is not tracked:

```bash
git status --short
git check-ignore -v .env
```
