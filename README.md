# RunX - Premium Monochrome Luxury Fitness

![RunX Banner](assets/branding/app_logo.png)

RunX is an elite, data-driven fitness platform designed for runners who value precision, focus, and a minimal aesthetic. Stripping away the noise of traditional fitness apps, RunX provides a high-contrast, monochrome experience focused entirely on your performance.

## 🏁 Key Features

*   **Precision GPS Tracking:** High-fidelity route mapping and smoothed pace calculations.
*   **AI Performance Coach:** Daily insights driven by your training plan adherence and recovery data.
*   **Elite Communities:** Join high-performance packs and compete in private leaderboards.
*   **Premium Training Plans:** Structed plans for 5K, 10K, and Marathons with real-time progress tracking.
*   **Luxury Monochrome UI:** A unique, high-contrast aesthetic designed for clarity and focus.
*   **Privacy-First:** Secure cloud sync via Supabase with local-first data persistence.

## 🛠️ Technology Stack

*   **Frontend:** Flutter (Dart)
*   **Backend:** Supabase (Auth, Database, Storage)
*   **State Management:** Provider
*   **Navigation:** Custom indexed stack navigation
*   **Database:** PostgreSQL (via Supabase) & SharedPreferences (Local Cache)

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (^3.12.0)
*   Supabase Account

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/runx.git
    ```
2.  Install dependencies:
    ```bash
    cd runx/frontend
    flutter pub get
    ```
3.  Configure Supabase:
    *   Create a project on [Supabase](https://supabase.com).
    *   Run the provided `supabase_schema.sql` in the SQL Editor.
    *   Add your `SUPABASE_URL` and `SUPABASE_ANON_KEY` to `lib/services/supabase_service.dart`.
4.  Run the app:
    ```bash
    flutter run
    ```

## ⚖️ License

Distributed under the MIT License. See `LICENSE` for more information.

## 🤝 Contributing

Contributions are welcome! Please see `CONTRIBUTING.md` for our code of conduct and submission process.

---
**Run Beyond Limits.**
