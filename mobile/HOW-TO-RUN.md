# How to Run AI Parenting Assistant

## Prerequisites
- Backend running on port 3001
- All node_modules installed (already done)
- All CocoaPods installed (already done)

## Starting the App (3 Terminals)

### Terminal 1: Backend
```bash
cd backend
npm run dev
```
**Wait for:** `AI Parenting Assistant API is running on port 3001`

### Terminal 2: Metro Bundler
```bash
cd mobile
./START-APP.sh
```
**Wait for:** `Loading dependency graph, done.`

### Terminal 3: iOS App
```bash
cd mobile
npm run ios
```

## What You Should See

1. ✅ iOS Simulator opens
2. ✅ App installs
3. ✅ **Login screen appears** with email and password fields
4. ✅ NO red error screens
5. ✅ NO "Expo Go" text anywhere

## If You See Errors

### "Module failed to load" or "Cannot read property 'EventEmitter'"
This means Metro cache is contaminated. Run:
```bash
cd mobile
rm -rf node_modules/.cache $TMPDIR/metro-* $TMPDIR/haste-*
./START-APP.sh
```

### "EADDRINUSE ::: 8083"
Port is in use. Kill it:
```bash
lsof -ti:8083 | xargs kill -9
```

### App shows "Expo Go"
Your simulator has Expo cached. Delete the app from simulator and reinstall:
```bash
cd mobile
npm run ios
```

## Testing the App

1. **Register**: Tap "Sign up" → Create account
2. **Login**: Use your credentials
3. **See home screen**: Welcome message with your email
4. **Logout**: Tap logout button → Back to login screen

## Troubleshooting

If nothing works, run the nuclear clean:
```bash
cd mobile
./QUICK-START.sh
```
Then follow the 3-terminal startup process above.
