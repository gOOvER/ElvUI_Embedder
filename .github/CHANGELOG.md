# Changelog

All notable changes to **ElvUI Embedder** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of **ElvUI Embedder** (`1.0.0`) under GPL-3.0.
- **Single & Dual Chat Panel Embedding**: Embeds meters into ElvUI's Right or Left Chat Panel (with optional `Below Chat Tab` anchor, adjustable left/right split percentage, gap, and container backdrop).
- **Supported Meters**:
  - **Details! Damage Meter** (Single & Dual windows)
  - **Blizzard Damage Meter** (Retail `DamageMeterSessionWindow1`/`2` & `DamageMeter`)
  - **Skada** (Single & Dual windows)
  - **Recount**
  - **Omen Threat Meter**
  - **TinyDPS**
- **ElvUI Integration**: Registers into ElvUI Options via `LibElvUIPlugin-1.0`, hooks `PositionChat` and `ToggleChatPanels`, and adds Right-Click toggle support on `RightChatToggleButton`.
- **Optional ElvUI Meter Skinning**: Added `Apply ElvUI Skin` (`applySkin`) and `Transparent Skin` (`skinTransparent`) options to style embedded `Details!`, `Blizzard Damage Meter`, `Skada`, `Recount`, `Omen`, and `TinyDPS` windows with ElvUI templates, borders, fonts, and statusbar textures.
- **Visibility Modes**: Always Show, Only in Combat, and Only in Group / Instance.
- **Slash Commands & Localization**: `/embed` & `/embedder` commands plus `enUS` and `deDE` locales.
- **Addon Icon & Social Preview Banner**: Added `assets/icon.tga` (`## IconTexture`), `assets/logo.png`, and `.github/assets/social-banner.png`.

