# SpeedTrack — First-Time Setup & Run Guide

## What You Need

- A Mac running macOS 13 (Ventura) or later
- Xcode 15 or later (free from the Mac App Store)
- An iPhone running iOS 16 or later (optional — you can also use the simulator)
- A free Apple ID

---

## Step 1 — Install Xcode

1. Open the **App Store** on your Mac
2. Search for **Xcode**
3. Click **Get** → **Install** (it's ~7 GB, give it time)
4. Once installed, open Xcode once and accept the license agreement

---

## Step 2 — Open the Project

1. Open **Finder** and navigate to the `sw-app-speedtrack` folder
2. Double-click **`sw-app-speedtrack.xcodeproj`**
3. Xcode will open the project

---

## Step 3 — Sign the App with Your Apple ID

You need to sign the app even for personal use.

1. In Xcode, click the project name **`sw-app-speedtrack`** in the left sidebar
2. Select the **SpeedTrack** target
3. Go to the **Signing & Capabilities** tab
4. Check **Automatically manage signing**
5. Under **Team**, click the dropdown and select **Add an Account...**
6. Sign in with your Apple ID
7. After signing in, select your Apple ID as the Team

> If you see a "No account" warning, make sure you're signed into Xcode with your Apple ID under **Xcode → Settings → Accounts**.

---

## Step 4A — Run on the iPhone Simulator (No iPhone Required)

1. At the top of Xcode, click the device selector (next to the play button)
2. Choose any **iPhone** simulator (e.g., iPhone 15)
3. Press **⌘R** or click the **▶ Play** button

> Note: The simulator cannot use real GPS, so speed will always read 0. Use a real iPhone for actual speed tracking.

---

## Step 4B — Run on Your Real iPhone

1. Connect your iPhone to your Mac with a USB cable
2. On your iPhone, tap **Trust** when prompted to trust the computer
3. In Xcode, click the device selector at the top and choose your iPhone from the list
4. Press **⌘R** or click the **▶ Play** button
5. Xcode will build and install the app on your iPhone

**First launch — trust the developer profile on your iPhone:**

1. On your iPhone, go to **Settings → General → VPN & Device Management**
2. Tap your Apple ID email under **Developer App**
3. Tap **Trust "[your Apple ID]"** → **Trust**
4. Open SpeedTrack — it will now launch

---

## Step 5 — Grant Location Permission

When SpeedTrack opens for the first time, it will ask for location access.

- Tap **Allow While Using App**

If you accidentally denied it:

1. Go to **Settings → Privacy & Security → Location Services**
2. Find **SpeedTrack** and set it to **While Using the App**

---

## Re-Signing Every 7 Days (Free Apple ID Limitation)

With a free Apple ID, the app expires after **7 days**. To reinstall:

1. Connect your iPhone
2. Open the project in Xcode
3. Press **⌘R** to rebuild and reinstall
4. You do not need to re-trust in Settings again

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "Could not launch — verify the Developer App certificate" | Settings → General → VPN & Device Management → Trust your Apple ID |
| Speed always shows 0 | Go outside with clear sky view. GPS needs a moment to lock. |
| "Untrusted Developer" error | Follow Step 4B trust instructions above |
| Xcode says "No devices" | Unlock your iPhone and tap Trust on the cable prompt |
| Build fails with signing error | Signing & Capabilities → make sure your Apple ID team is selected |
