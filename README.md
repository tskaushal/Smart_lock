Smart Lock System

A simple prototype demonstrating communication between a mobile application and an Arduino-based lock controller.
The phone authenticates the user (e.g., fingerprint), and then sends lock/unlock commands to the Arduino through USB-OTG.
The Arduino receives these commands over Serial and controls an LED or actuator accordingly.

Features

Flutter mobile app sends commands over USB-OTG

Arduino receives single-character commands through Serial

'U' → Unlock (LED turns ON)

'L' → Lock (LED turns OFF)

'S' → Status response (LOCKED / UNLOCKED)

Simple buzzer feedback for lock/unlock actions

Minimal and easy to extend for real hardware locks

Project Structure
Smart_lock/
│
├── Arduino/
│   └── smart_lock.ino       // Arduino firmware for the lock controller
│
├── lib/                     // Flutter app source code
├── test/                    // Flutter test files
├── pubspec.yaml             // Flutter project configuration
└── README.md                // This document

Arduino Firmware
The Arduino listens for commands sent from the mobile app.
It controls an LED (representing the lock) and optionally a buzzer.

Commands
Command	Meaning	Arduino action
U	Unlock	LED ON, buzzer short beep
L	Lock	LED OFF, two short beeps
S	Status	Sends STATUS:LOCKED/UNLOCKED
Hardware Connections

LED on digital pin 13
Buzzer on digital pin 9
(Optional) Real lock driver/relay on pin 8
USB-OTG cable between Arduino and Android phone

Firmware File
Arduino/smart_lock.ino contains the complete C++ code.

Mobile App (Flutter)
The Flutter application is responsible for:

Authentication (e.g., fingerprint on Android)
Sending 'U', 'L', 'S' commands via USB-OTG serial

Displaying lock/unlock status on the screen
The app interacts with the Arduino using USB serial libraries available for Flutter.

How to Use
1. Flash the Arduino
Upload Arduino/smart_lock.ino using Arduino IDE.

2. Run the App
Connect phone to Arduino via USB-OTG

Open the Flutter app
Authenticate
Tap Lock/Unlock buttons

3. Observe Behavior
LED will turn ON (unlock) or OFF (lock)
Arduino prints acknowledgments over Serial
Buzzer gives feedback (optional)

What This Project Demonstrates
Basic embedded programming in C++
USB-OTG communication between phone and microcontroller
Integration of hardware actions with a mobile application

Real-time command handling
Modular design: Flutter app + Arduino firmware
This is a simple prototype meant to demonstrate the core idea of link-based authentication and control.

Future Improvements

Replace USB-OTG with Bluetooth or Wi-Fi
Add encrypted command communication
Add actual hardware lock (relay/servo)
Show lock state on the app in real time
Add logs/history of accesses
