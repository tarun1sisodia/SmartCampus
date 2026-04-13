#!/bin/bash

# SmartCampus Quick Start Script
# This script helps you quickly set up and run SmartCampus with Docker

set -e

echo "🎓 SmartCampus Docker Quick Start"
echo "=================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first:"
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
COMPOSE_CMD=""
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose is not installed. Please install Docker Compose first:"
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found!"
    echo ""
    
    if [ -f .env.example ]; then
        echo "📝 Creating .env file from .env.example..."
        cp .env.example .env
        echo "✅ .env file created!"
        echo ""
        echo "⚙️  Please edit .env file and add your Supabase credentials:"
        echo "   - SUPABASE_URL"
        echo "   - SUPABASE_ANON_KEY"
        echo ""
        read -p "Press Enter after you've configured .env file..." 
    else
        echo "❌ .env.example file not found. Cannot proceed."
        exit 1
    fi
fi

echo ""
echo "🚀 Starting SmartCampus..."
echo ""

# Build and start the container
$COMPOSE_CMD up -d smartcampus-web

echo ""
echo "✅ SmartCampus is starting!"
echo ""
echo "📊 Checking container status..."
sleep 3

if docker ps | grep -q smartcampus-web; then
    echo "✅ Container is running!"
    echo ""
    echo "🌐 Access SmartCampus at: http://localhost:8080"
    echo ""
    echo "📋 Useful commands:"
    echo "   - View logs:    $COMPOSE_CMD logs -f smartcampus-web"
    echo "   - Stop app:     $COMPOSE_CMD stop"
    echo "   - Restart app:  $COMPOSE_CMD restart"
    echo "   - Remove app:   $COMPOSE_CMD down"
    echo ""
else
    echo "❌ Container failed to start. Checking logs..."
    $COMPOSE_CMD logs smartcampus-web
    exit 1
fi
