# Changelog

## v0.2.0

- Add switchable transcription provider: local Whisper or OpenAI Audio Transcriptions.
- Add OpenAI transcription settings for model, language, prompt, local fallback, and cost logging.
- Skip loading local Whisper at startup when OpenAI transcription is enabled.
- Print estimated OpenAI transcription cost when API usage data is available.
- Clear the clipboard after paste attempts and cancel paste when no JetBrains window is available.

## v0.1.0

- Global hotkey voice recording.
- Local transcription with faster-whisper.
- OpenAI cleanup layer.
- Safe paste into JetBrains IDE windows.
- Tray icon with recording and processing states.
- Ubuntu desktop launcher and Favorites installer.
- Single-instance lock.
