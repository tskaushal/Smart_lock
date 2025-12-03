// Simple Smart Lock Firmware
// Commands over Serial:
// 'U' -> Unlock  (LED ON)
// 'L' -> Lock    (LED OFF)
// 'S' -> Status  (send back LOCKED / UNLOCKED)

const int LED_PIN = 13;       // lock indicator (on-board LED)
const int BUZZER_PIN = 9;     // optional buzzer

bool isUnlocked = false;

void setup() {
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);

  Serial.begin(9600);
  delay(500);
  Serial.println("SMART_LOCK_READY");
  sendStatus();
}

void loop() {
  if (Serial.available() > 0) {
    char cmd = Serial.read();
    handleCommand(cmd);
  }
}

void handleCommand(char cmd) {
  cmd = toupper(cmd); // normalize

  if (cmd == 'U') {
    unlock();
    Serial.println("ACK:UNLOCKED");
  } 
  else if (cmd == 'L') {
    lock();
    Serial.println("ACK:LOCKED");
  }
  else if (cmd == 'S') {
    sendStatus();
  }
  else {
    Serial.println("ERR:UNKNOWN_CMD");
  }
}

void unlock() {
  isUnlocked = true;
  digitalWrite(LED_PIN, HIGH);
  beep(1, 120);
}

void lock() {
  isUnlocked = false;
  digitalWrite(LED_PIN, LOW);
  beep(2, 70);
}

void sendStatus() {
  if (isUnlocked) {
    Serial.println("STATUS:UNLOCKED");
  } else {
    Serial.println("STATUS:LOCKED");
  }
}

void beep(int times, int duration) {
  for (int i = 0; i < times; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(duration);
    digitalWrite(BUZZER_PIN, LOW);
    delay(80);
  }
}
