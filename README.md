# ShopWave

> Ride the wave of great deals — a production-grade Flutter shopping app

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Riverpod](https://img.shields.io/badge/Riverpod-2.5-purple)
![Hive](https://img.shields.io/badge/Hive-1.1-orange)
![GoRouter](https://img.shields.io/badge/GoRouter-14.2-green)
![Freezed](https://img.shields.io/badge/Freezed-2.5-teal)

## Screenshots

> Add screenshots here

## Architecture

ShopWave follows Clean Architecture with strict layer separation:

```
lib/
├── core/                   # Shared utilities
│   ├── constants/          # Colors, strings, sizes
│   ├── errors/             # Failure and exception types
│   ├── router/             # GoRouter config (ShellRoute + typed routes)
│   ├── storage/            # HiveService (init + box access)
│   └── theme/              # Material 3 ThemeData (light + dark)
└── features/
    ├── products/           # Product browse, search, detail
    │   ├── data/           # Models (Freezed), datasources, repository impl
    │   ├── domain/         # Entities (Freezed), repository interface, use cases
    │   └── presentation/   # Providers (Riverpod), screens, widgets
    ├── cart/               # Shopping cart with Hive persistence
    ├── favorites/          # Wishlist with Hive persistence
    └── checkout/           # Checkout form + order success
```

**Data flow:**
```
assets/mock/products.json
        ↓ rootBundle.loadString
ProductRemoteDatasource → ProductRepositoryImpl → productsProvider → ProductListScreen
        ↓ cache                       ↑ fallback
    products_cache (Hive)  ←──────────┘
```

The UI never calls datasources directly — everything flows through the repository.

## Features

- **Product List** — 2-column grid with shimmer loading, search, pull-to-refresh, offline banner
- **Product Detail** — Hero animation, expandable description, star rating, sticky add-to-cart bar
- **Cart** — Swipe-to-delete, animated quantity controls, order summary with free shipping threshold
- **Favorites** — Toggle from any screen, persisted across restarts
- **Checkout** — 6-field validated form, 1.5s simulated order placement
- **Order Success** — Confetti particle animation, order ID chip, no-back-navigate guard
- **Offline Mode** — Falls back to Hive cache, shows banner when serving stale data
- **Dark Mode** — Full Material 3 dark theme support
- **Persistence** — Cart and favorites survive app restarts via Hive

## Tech Stack

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | 2.5.1 | State management (ONLY state solution) |
| freezed + freezed_annotation | 2.5.2 | Immutable data classes |
| json_serializable + json_annotation | 6.8.0 / 4.9.0 | JSON serialization |
| go_router | 14.2.0 | Declarative navigation with ShellRoute |
| hive_flutter | 1.1.0 | Local persistence (cart, favorites, cache) |
| cached_network_image | 3.3.1 | Image loading with shimmer placeholder |
| shimmer | 3.0.0 | Loading skeleton UI |
| flutter_animate | 4.5.0 | Entrance animations, confetti, transitions |
| google_fonts | 6.2.1 | Poppins typography |
| dartz | 0.10.1 | Functional Either type for error handling |
| intl | 0.19.0 | Currency formatting |

## Setup & Running

```bash
git clone <repo-url>
cd shopwave
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Running Tests

```bash
flutter test          # 25 unit tests, all passing
flutter analyze       # zero issues
```

## Known Issues / Limitations

- Product images are served from `picsum.photos` (random seed-based), so images are abstract rather than product-accurate.
- The remote datasource reads from `assets/mock/products.json` rather than a live API; in production this would be replaced with a Dio HTTP client.
- `riverpod_lint` and `custom_lint` were excluded from dev dependencies due to version conflicts with the current Dart SDK (3.11); the architecture and code still follows all Riverpod best practices manually.
- No authentication layer — user state is assumed to be anonymous.

## License

MIT
