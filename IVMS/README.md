
# 🚗 Intelligent Vehicle Monitoring System (IVMS)

## 🧠 Project Overview

**Intelligent Vehicle Monitoring System (IVMS)** is an AI-powered platform that detects vehicle number plates using **YOLOv11 + OCR**, identifies whether the vehicle is **stolen**, and predicts **possible escape routes** using location-based analysis.

This system includes:
- Django REST API backend
- React Web Dashboard (Admin/Police)
- Flutter Mobile App (Users/Officers)
- AI Module for Number Plate Detection (YOLOv11 + Tesseract)

---

## 🏗️ Folder Structure

```bash
ivms_project/
│
├── backend/              # Django backend (REST API)
├── frontend/         # React Web Dashboard
├── track_vision/           # Flutter Mobile App
├── ai_module/            # YOLO + OCR scripts
└── docs/                 # Documents and reports
```

---

## ⚙️ Backend Setup (Django + MySQL)

### Requirements
- Python 3.10+
- pip (Python package manager)

### Setup Steps
```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
cd backend
pip install -r requirements.txt
python manage.py makemigrations users
python manage.py makemigrations complaints
python manage.py makemigrations detection
python manage.py makemigrations routes
python manage.py makemigrations alerts
python manage.py migrate
daphne -p 8000 backend.asgi:application
```
Access API at 👉 [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

### Environment Variables
Create `.env` file in `backend/`
```env
SECRET_KEY=your_secret_key_here
DEBUG=True
ALLOWED_HOSTS=*
GOOGLE_MAPS_API_KEY=your_google_api_key_here
```

---

## 🤖 AI Module (YOLO + OCR)

```bash
cd ai_module
python test_camera_feed.py
python recognize_plate.py
```
This uses webcam input to detect number plates and extract text.

---

## 💻 Frontend Setup (React)

### Requirements
- Node.js 18+

### Setup Steps
```bash
cd frontend
npm install
npm run dev
```
Runs on 👉 [http://localhost:5173](http://localhost:5173)

### Environment Variables
Create `.env` in `frontend/`
```env
VITE_API_URL=http://127.0.0.1:8000
VITE_MAPS_API_KEY=your_google_maps_key
```

---

## 📱 Mobile App Setup (Flutter)

### Requirements
- Flutter SDK
- Android Studio / VS Code with Flutter plugin

### Setup Steps
```bash
cd track_vision
flutter pub get
flutter run
```
Set API base URL in:
```dart
lib/utils/constants.dart
const String BASE_URL = "http://127.0.0.1:8000";
```

---

## 🌐 Connecting All Components

| Component | Command | Description |
|------------|----------|-------------|
| Backend | `daphne -p 8000 backend.asgi:application` | API & database |
| AI Module | `python recognize_plate.py` | Detects plates |
| React | `npm run dev` | Web dashboard |
| Flutter | `flutter run` | Mobile app |

---

## 🧩 Features

✅ Detects vehicle numbers using **YOLOv11 + OCR**  
✅ Checks against stolen vehicle database  
✅ Predicts possible **routes and locations**  
✅ Sends **alerts & notifications**  
✅ Interactive **Web Dashboard** and **Mobile App**

---

## 🧰 Troubleshooting

| Issue | Solution |
|-------|-----------|
| `pip install` fails | Upgrade pip → `python -m pip install --upgrade pip` |
| Django not running | Activate virtual environment |
| React API error | Ensure backend is running |
| Flutter API issue | Use system’s local IP instead of 127.0.0.1 |

---

## 🚀 Future Enhancements
- GPS hardware tracking module
- Real-time route heatmaps
- Push notifications
- Cloud deployment (AWS / Railway / Vercel)
