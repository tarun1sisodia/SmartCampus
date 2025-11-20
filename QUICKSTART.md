# 🚀 SmartCampus - Quick Start Guide

Get SmartCampus running in under 5 minutes with Docker!

---

## ⚡ Super Quick Start

### For Linux/macOS:
```bash
./docker-start.sh
```

### For Windows:
```cmd
docker-start.bat
```

### Manual Start:
```bash
# 1. Copy environment file
cp .env.example .env

# 2. Edit .env with your Supabase credentials
nano .env

# 3. Start with Docker Compose
docker-compose up -d smartcampus-web

# 4. Open browser
http://localhost:8080
```

---

## 📋 Essential Commands

| Task | Command |
|------|---------|
| 🚀 Start | `docker-compose up -d smartcampus-web` |
| 🛑 Stop | `docker-compose stop` |
| 🔄 Restart | `docker-compose restart` |
| 📊 View logs | `docker-compose logs -f smartcampus-web` |
| 🗑️ Remove | `docker-compose down` |
| 🔨 Rebuild | `docker-compose build --no-cache` |
| 📦 Update | `git pull && docker-compose up -d --build` |

---

## 🎯 What You Need

1. **Docker** - [Install here](https://docs.docker.com/get-docker/)
2. **Supabase Account** - [Sign up free](https://supabase.com)
3. **Your Supabase credentials** - URL & Anon Key

---

## 🔧 Configuration

### .env File Structure:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

---

## 🌐 Access Points

- **Web App**: http://localhost:8080
- **Custom Port**: Edit `docker-compose.yml` ports section

---

## ❓ Troubleshooting

### Port 8080 in use?
```bash
# Find what's using it
lsof -i :8080

# Or change port in docker-compose.yml
ports:
  - "3000:8080"  # Use port 3000 instead
```

### Container won't start?
```bash
# Check logs
docker-compose logs smartcampus-web

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Changes not reflecting?
```bash
# Rebuild and restart
docker-compose up -d --build
```

---

## 📚 More Information

- 📖 Full Docker Guide: [DOCKER.md](./DOCKER.md)
- 📘 Project README: [README.md](./README.md)
- 🔒 Security: [SECURITY.md](./SECURITY.md)
- 🐛 Issues: [GitHub Issues](https://github.com/tarun1sisodia/smartcampus/issues)

---

## 🎉 That's it!

You should now have SmartCampus running. Enjoy! 🚀

**Need help?** Open an issue on GitHub or check the detailed guides above.
