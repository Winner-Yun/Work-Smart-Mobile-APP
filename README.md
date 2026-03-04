# WorkSmart Mobile App (Demo)

This project is a Flutter demo app with **Employee** and **Admin** flows.

## Demo Accounts

### Employee demo (your account)

- Name: **Yun Winner**
- User ID: `user_winner_777`
- Password: `password123`

You can log in using either:

- `user_winner_777`, or
- a name that matches `Yun Winner`

### Admin demo accounts

- Admin ID: `admin`
- Password: `admin123`

---

## How to Run

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Create `.env` in project root

At minimum:

```env
GOOGLE_MAPS_API_KEY=your_google_maps_key
```

### 3) Run app (normal)

```bash
flutter run
```

---

## How to Run Admin

### Option A: Web (opens Admin login by default)

```bash
flutter run -d chrome
```

On web, initial route is admin auth (`/admin-auth`).

### Option B: Force admin route on any platform

```bash
flutter run --route=/admin-auth
```

Then log in with one of the admin demo accounts above.

---

## Notes

- Employee credentials are from `lib/core/util/mock_data/userFinalData.dart`.
- Admin credentials are from `lib/features/admin/auth/logic/auth_admin_logic.dart`.
