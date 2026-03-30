# 🐳 Docker Deployment Guide for SmartCampus

This guide explains how to deploy and run SmartCampus using Docker for quick and easy setup.

---

## 📋 Prerequisites

Before you begin, ensure you have:

- **Docker** installed ([Download Docker](https://docs.docker.com/get-docker/)) or go to Youtube and search "How to install Docker on Ubuntu"   
- **Docker Compose** installed (usually comes with Docker Desktop)
- **Supabase credentials** (URL and API Key)

---

## 🚀 Quick Start

### Option 1: Web Deployment (Recommended for Production)

This builds and runs the Flutter web version of SmartCampus.

1. **Clone the repository**
   ```bash
   git clone https://github.com/tarun1sisodia/smartcampus.git
   cd smartcampus
   ```

2. **Configure environment variables**
   
   Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your Supabase credentials:
   ```
   SUPABASE_URL=your_supabase_url_here
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

3. **Build and run with Docker Compose**
   ```bash
   docker-compose up -d smartcampus-web
   ```

4. **Access the application**
   
   Open your browser and navigate to:
   ```
   http://localhost:8080
   ```

5. **Stop the application**
   ```bash
   docker-compose down
   ```

---

### Option 2: Development Environment

This creates a full Flutter development environment in Docker.

1. **Start the development container**
   ```bash
   docker-compose --profile dev up -d smartcampus-dev
   ```

2. **Access the container**
   ```bash
   docker exec -it smartcampus-dev bash
   ```

3. **Inside the container, run Flutter commands**
   ```bash
   flutter pub get
   flutter run -d web-server --web-port=8080
   ```

---

## 🛠️ Docker Commands Reference

### Web Deployment

| Action | Command |
|--------|---------|
| Build and start | `docker-compose up -d smartcampus-web` |
| Stop | `docker-compose stop smartcampus-web` |
| Remove | `docker-compose down` |
| View logs | `docker-compose logs -f smartcampus-web` |
| Rebuild | `docker-compose build smartcampus-web` |

### Development Environment

| Action | Command |
|--------|---------|
| Start dev container | `docker-compose --profile dev up -d` |
| Stop dev container | `docker-compose --profile dev stop` |
| Access shell | `docker exec -it smartcampus-dev bash` |
| View logs | `docker-compose logs -f smartcampus-dev` |

---

## 🔧 Advanced Configuration

### Custom Port

To run the web app on a different port, edit `docker-compose.yml`:

```yaml
services:
  smartcampus-web:
    ports:
      - "3000:8080"  # Change 3000 to your desired port
```

### Using Single Dockerfile (Alternative)

If you prefer not to use docker-compose:

**For Web:**
```bash
# Build the image
docker build -f Dockerfile.web -t smartcampus-web .

# Run the container
docker run -d -p 8080:8080 --name smartcampus smartcampus-web
```

**For Development:**
```bash
# Build the image
docker build -t smartcampus-dev .

# Run the container
docker run -it --rm -v $(pwd):/workspace smartcampus-dev
```

---

## 🐛 Troubleshooting

### Issue: Port already in use
```bash
# Check what's using port 8080
lsof -i :8080

# Use a different port in docker-compose.yml
```

### Issue: Container won't start
```bash
# Check logs
docker-compose logs smartcampus-web

# Rebuild from scratch
docker-compose build --no-cache smartcampus-web
```

### Issue: Environment variables not loading
```bash
# Ensure .env file exists in the project root
ls -la .env

# Restart container after .env changes
docker-compose restart smartcampus-web
```

---

## 📦 What Gets Installed?

### Dockerfile.web (Production)
- Flutter SDK (stable channel)
- Web dependencies
- Nginx web server
- Built web application

### Dockerfile (Development)
- Flutter SDK
- Android SDK
- Development tools
- Build dependencies

---

## 🌐 Deployment Options

### Deploy to Cloud

**Docker Hub:**
```bash
docker tag smartcampus-web your-dockerhub-username/smartcampus:latest
docker push your-dockerhub-username/smartcampus:latest
```

**Deploy on VPS/Cloud:**
```bash
# On your server
docker pull your-dockerhub-username/smartcampus:latest
docker run -d -p 80:8080 your-dockerhub-username/smartcampus:latest
```

---

## ✅ Best Practices

1. **Always use `.env` files** for sensitive credentials
2. **Don't commit `.env`** to version control
3. **Use docker-compose** for easier management
4. **Regular updates**: Pull latest Flutter SDK periodically
5. **Monitor logs**: Use `docker-compose logs -f` to watch for errors
6. **Backup volumes**: Keep flutter-pub-cache persistent

---

## 📞 Need Help?

- Check [README.md](./README.md) for general setup
- Open an issue on [GitHub](https://github.com/tarun1sisodia/smartcampus/issues)
- Review [Flutter Docker documentation](https://docs.flutter.dev)

---

## 🔄 Updates

To update to the latest version:

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose build smartcampus-web
docker-compose up -d smartcampus-web
```

---

**🎉 You're all set! Your SmartCampus application should now be running in Docker.**
