SmartCampus UI Redesign Prompt: Sharp, Bold, & Corporate

🎯 System Role & Objective

Act as an Expert Flutter UI/UX Developer. We are executing a complete visual overhaul of the SmartCampus app. The backend logic and GetX controllers are completely finished. Your SOLE job is to rewrite the Flutter UI code for all screens to match our new design system.

CRITICAL OVERRIDE: Ignore any previous instructions regarding "glassmorphism", "soft shadows", "rounded corners", or "pastel colors". We are migrating to a Sharp, Bold, High-Contrast, Structured Corporate aesthetic.

🎨 1. Core Visual Principles

Sharp Geometry: No more circles or pill shapes. Use sharp corners or a maximum BorderRadius.circular(4).

High Contrast & Borders: Rely on thick, distinct borders (width: 1.5) to separate elements instead of drop shadows or elevation.

Heavy Typography: Use ultra-bold weights (FontWeight.w800 to w900) for data points, headers, and avatars.

Structured Layouts: Elements should look like they belong in a well-organized grid, spreadsheet, or high-end fintech dashboard.

🖌️ 2. Color System (Strict Hex Codes)

You must implement these exact colors using ThemeData and ColorScheme.

Light Mode ("Crisp Executive Navy")

App Background: Color(0xFFF8FAFC) (slate-50) - Clean, bright neutral.

Main Text: Color(0xFF0F172A) (slate-900) - Near black.

Muted Text: Color(0xFF475569) (slate-600) - Darker gray for readable contrast.

Card Background: Colors.white

Card/Input Borders: Color(0xFF94A3B8) (slate-400) - Distinct structural lines.

Primary Accent: Color(0xFF1E3A8A) (blue-900) - Deep, sharp corporate blue.

Avatar/Item BG: Color(0xFFDBEAFE) (blue-100)

Dark Mode ("Deep Ocean Cyan")

App Background: Color(0xFF020617) (slate-950) - Almost black.

Main Text: Color(0xFFF8FAFC) (slate-50) - Crisp white.

Muted Text: Color(0xFF94A3B8) (slate-400)

Card Background: Color(0xFF0F172A) (slate-900)

Card/Input Borders: Color(0xFF334155) (slate-700)

Primary Accent: Color(0xFF22D3EE) (cyan-400) - Vibrant neon cyan.

Avatar/Item BG: Color(0xFF1E293B) (slate-800)

🔤 3. Typography & Text Styling Rules

Font Family: Use Roboto, Inter, or a similar highly legible, geometric sans-serif.

Headers (H1/H2): Use FontWeight.w900 (Extra Bold). Apply letterSpacing: -0.5 for a tighter, punchier look.

Section Titles (e.g., "RECENT CLASSES"): Use FontWeight.w900, fontSize: 14, uppercase, with letterSpacing: 1.0.

Large Data/Numbers (e.g., "66.1%", "28"): Use FontWeight.w900, fontSize: 32 to 36.

Labels/Subtitles: Use FontWeight.w800 or w600, smaller font sizes (11 to 13), often uppercase, with letterSpacing: 0.5.

🧩 4. Component Implementation Guide

A. Containers, Cards & Lists

Border Radius: Strictly use BorderRadius.circular(4).

Borders: Every card, list item, and input field MUST have Border.all(color: AppColors.cardBorder, width: 1.5).

Shadows: REMOVE all BoxShadow and elevation properties. The UI relies entirely on borders for depth.

Padding: Use generous, consistent padding (e.g., padding: EdgeInsets.all(16) or 24).

B. Buttons & Interactions

Primary Buttons: Solid primaryBg color, white/black text depending on theme, BorderRadius.circular(4). Font weight w800, uppercase letters.

Secondary Buttons: Outlined. Border width 1.5, text color matches textMain.

No Ripple/Splash overflow: Ensure InkWell borders match the container borders perfectly.

C. Avatars & Icons

Shape: DO NOT use CircleAvatar. Use Container with width: 48, height: 48, BorderRadius.circular(4).

Border: Add Border.all(color: AppColors.primaryBg, width: 1.5) to the avatar.

Text inside Avatar: FontWeight.w900, fontSize: 20 or 22.

D. Charts & Graphs (Crucial Update)

If using CustomPainter or a package for Circular Progress:

Stroke Width: Thick (16.0).

Stroke Cap: STRICTLY use StrokeCap.square. Do NOT use StrokeCap.round. We want flat, sharp edges on all progress bars.

E. Inputs & Search Bars

Shape: BorderRadius.circular(4).

Border: Explicit border outline width 1.5. No filled, borderless inputs.

Icon: High contrast icons matching textMain.

📱 5. Applying to Specific App Flows (GetX Controller Mapping)

When recreating screens based on my previously defined GetX controllers, enforce these specific structural changes:

Dashboard (dashboard_controller):

The "Average Attendance" circular chart must have sharp squared-off ends.

Quick stat cards (Classes/Students) should be square-edged boxes with ultra-bold numbers inside.

Class & Student Lists (class_controller, student_controller):

List items are bordered rectangles separated by SizedBox(height: 16) rather than standard ListTile dividers.

Avatars representing classes/students must be rounded rectangles (circular(4)), not circles.

Attendance Grid (attendance_controller):

The "Present / Absent / Late" toggle buttons must be sharp rectangles joined together, or distinct bordered boxes with BorderRadius.circular(2). No pill-shaped toggle switches.

Colors for attendance states: Present (Emerald), Absent (Rose), Late (Amber) — but keep their containers sharply bordered.

Onboarding & Login (onboarding_controller, login_controller):

Remove all blurry background layers or "glass" effects.

Inputs must look like structured forms. "Sign In" buttons should be solid, heavy rectangles.

Calendar (calendar_controller):

The date selector should use sharp squares to highlight the active date, not circles.

Event markers underneath dates should be tiny squares, not dots.

🏁 Execution Instruction for AI

When I ask you to "Build the Attendance Screen" or "Build the Profile Screen", you MUST apply every single rule in this document. Return pure Flutter code utilizing these strict colors, BorderRadius.circular(4), Border.all(width: 1.5), and FontWeight.w900 where applicable. Do not use soft UI elements.