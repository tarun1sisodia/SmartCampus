@echo off
REM SmartCampus Quick Start Script for Windows
REM This script helps you quickly set up and run SmartCampus with Docker

echo.
echo SmartCampus Docker Quick Start
echo ==================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed. Please install Docker first:
    echo    Visit: https://docs.docker.com/get-docker/
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if errorlevel 1 (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Docker Compose is not installed.
        echo    Visit: https://docs.docker.com/compose/install/
        exit /b 1
    )
)

REM Check if .env file exists
if not exist .env (
    echo [WARNING] .env file not found!
    echo.
    
    if exist .env.example (
        echo Creating .env file from .env.example...
        copy .env.example .env >nul
        echo [SUCCESS] .env file created!
        echo.
        echo Please edit .env file and add your Supabase credentials:
        echo    - SUPABASE_URL
        echo    - SUPABASE_ANON_KEY
        echo.
        pause
    ) else (
        echo [ERROR] .env.example file not found. Cannot proceed.
        exit /b 1
    )
)

echo.
echo Starting SmartCampus...
echo.

REM Build and start the container
docker-compose up -d smartcampus-web

echo.
echo SmartCampus is starting!
echo.
echo Checking container status...
timeout /t 3 >nul

REM Check if container is running
docker ps | findstr smartcampus-web >nul
if errorlevel 1 (
    echo [ERROR] Container failed to start. Checking logs...
    docker-compose logs smartcampus-web
    exit /b 1
) else (
    echo [SUCCESS] Container is running!
    echo.
    echo Access SmartCampus at: http://localhost:8080
    echo.
    echo Useful commands:
    echo    - View logs:    docker-compose logs -f smartcampus-web
    echo    - Stop app:     docker-compose stop
    echo    - Restart app:  docker-compose restart
    echo    - Remove app:   docker-compose down
    echo.
)
