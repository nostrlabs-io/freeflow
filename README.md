<img src="assets/logo.png" style="border-radius: 100%; height: 64px;"/>
<h1>
    Freeflow
</h1>

## About

Freeflow is a decentralized short-form video platform built on the Nostr protocol. It provides a TikTok-like experience with the freedom and censorship resistance of Nostr, allowing users to create, share, and discover short videos without relying on centralized platforms.

## Features

- 📱 **Cross-platform**: Available on Android, iOS, Web, Windows, macOS, and Linux
- 🎥 **Video Creation**: Record and share short videos with built-in camera integration
- 🔄 **Nostr Integration**: Built on the decentralized Nostr protocol using NIP-71 for video events
- 🔐 **Amber Support**: Secure key management through Amber wallet integration
- ⚡ **Lightning Integration**: Zap videos and creators using Bitcoin Lightning Network
- 🔍 **Discovery**: Search and explore videos across the Nostr network
- 👤 **Profiles**: Follow creators and build your network
- 💬 **Comments**: Engage with content through comments and reactions
- 🎨 **Modern UI**: Clean, responsive interface optimized for mobile

## Technology Stack

- **Framework**: Flutter (Dart)
- **Protocol**: Nostr (Decentralized social protocol)
- **Video**: Custom video player and compression
- **Storage**: ObjectBox for local caching
- **Authentication**: Amber wallet integration for secure key management
- **Networking**: WebSocket connections to Nostr relays

## Getting Started

### Prerequisites

- Flutter SDK (>=3.6.0)
- Android Studio / Xcode for mobile development
- Git

### Installation

1. Clone the repository:

```bash
git clone https://github.com/nostrlabs-io/freeflow.git
cd freeflow
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the application:

```bash
flutter run
```

## Architecture

Freeflow uses the NDK (Nostr Development Kit) for Nostr protocol integration:

- **ndk**: Core Nostr protocol implementation
- **ndk_objectbox**: Local caching and data persistence
- **ndk_amber**: Amber wallet integration for secure signing
- **ndk_rust_verifier**: Event signature verification

The app connects to multiple Nostr relays including:

- wss://nos.lol
- wss://relay.damus.io
- wss://relay.primal.net

## Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

## License

This project is licensed under the terms found in the LICENSE file.

## Links

- [Nostr Protocol](https://nostr.com/)
- [NIP-71 Specification](https://github.com/nostr-protocol/nips/blob/master/71.md) (Video Events)
- [Amber Wallet](https://github.com/greenart7c3/Amber)
