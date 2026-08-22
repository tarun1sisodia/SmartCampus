# Architecture

## Overview
The application follows a client-server architecture. The new QR-based scanning feature will be integrated into the existing SmartCampus flow.

## Technical Stack
- **Frontend**: (Matches existing SmartCampus stack)
- **Backend**: (Matches existing SmartCampus stack, possibly integrating Python/Flask or OpenCV logic from the reference repository if applicable).
- **Database**: To track QR attendance records.
- **QR/Vision**: Integration of a QR scanning library (e.g., HTML5 QR Code scanner for frontend, or OpenCV for backend).

## File & Folder Structure
```
SmartCampus/
├── src/                (Existing SmartCampus Source)
├── docs/               (Project Documentation)
├── qr_module/          (New QR Scanning features)
└── ...
```
