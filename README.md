# WorkSmart Mobile App (Demo)

WorkSmart is a Flutter app with both **Employee** and **Admin** experiences.

## Demo Accounts

### Employee demo

- Name: **Check out the demo employee account in Admin Dashboard!**
- User ID: `Check out the demo employee account in Admin Dashboard!`
- Password: `worksmart123`

### Admin demo

- Admin ID: `admin`
- Password: `admin123`

## Quick Start

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Create your `.env` file

Use the template in the project root:

```powershell
Copy-Item .env.example .env
```

```bash
cp .env.example .env
```

Then fill in your values.

### 3) Run app

```bash
flutter run
```

## Run Admin Flow

### Option A: Web (defaults to admin auth)

```bash
flutter run -d chrome
```

On web, startup route resolves to `/admin-auth`.

### Option B: Force admin route on any platform

```bash
flutter run --route=/admin-auth
```

## Environment Variables

See [.env.example](.env.example) for the full template.

Required for common app flows:

- `GOOGLE_MAPS_API_KEY`: Google Maps SDK key.
- `PASSWORD_PEPPER`: App password pepper used by user password hashing. Keep this stable between deployments.

Optional (feature-specific):

- `CLOUDINARY_API_KEY`: Needed for Cloudinary profile image upload/delete.
- `CLOUDINARY_API_SECRET`: Needed for Cloudinary profile image upload/delete.
- `CLOUDINARY_CLOUD_NAME`: Cloudinary cloud name (defaults in code if omitted).
- `DEFAULT_USER_PASSWORD`: Default password fallback used when creating users from admin side.
- `API_BASE_URL`: Reserved for external API integration.
- `AUTH_API_KEY`: Reserved for external API integration.

## Notes

- Environment is loaded from `.env` during bootstrap in [lib/core/bootstrap.dart](lib/core/bootstrap.dart).
- Employee authentication/data uses Firestore through [lib/core/util/database/realtime_data_controller.dart](lib/core/util/database/realtime_data_controller.dart).
- Admin authentication is handled via Firebase Auth through [lib/features/admin/auth/controller/admin_auth_controller.dart](lib/features/admin/auth/controller/admin_auth_controller.dart).
