# Smart Cooking Helper - Deployment Guide

## Cloud Deployment Options

### Option 1: Heroku (Backend)

#### Prerequisites
- Heroku CLI installed
- Free Heroku account

#### Steps

1. **Login to Heroku**
```bash
heroku login
```

2. **Create App**
```bash
cd backend
heroku create your-app-name
```

3. **Set Environment Variables**
```bash
heroku config:set DATABASE_URL=your_postgres_url
heroku config:set FIREBASE_PROJECT_ID=your_project_id
heroku config:set FIREBASE_PRIVATE_KEY=your_private_key
# ... set other credentials
```

4. **Deploy**
```bash
git push heroku main
```

5. **Check Logs**
```bash
heroku logs --tail
```

### Option 2: Docker + Any Cloud Provider

#### Build Docker Image
```bash
docker build -t smart-cooking-api:latest ./backend
```

#### Run Locally
```bash
docker-compose up
```

#### Push to Registry (e.g., Docker Hub)
```bash
docker tag smart-cooking-api:latest your-registry/smart-cooking-api:latest
docker push your-registry/smart-cooking-api:latest
```

#### Deploy to Cloud Run (Google Cloud)
```bash
gcloud run deploy smart-cooking-api \
    --image gcr.io/your-project/smart-cooking-api:latest \
    --platform managed \
    --region us-central1 \
    --set-env-vars DATABASE_URL=your_db_url
```

### Option 3: AWS Deployment

#### With Elastic Beanstalk
```bash
eb init smart-cooking-helper
eb create smart-cooking-env
eb deploy
```

#### With Lambda (Serverless)
```bash
# Create Lambda function with API Gateway
# Use Zappa for FastAPI deployment
pip install zappa
zappa init
zappa deploy production
```

## Database Deployment

### Amazon RDS PostgreSQL
1. Create RDS instance via AWS Console
2. Update `DATABASE_URL` environment variable
3. Run migrations

### Heroku Postgres
```bash
heroku addons:create heroku-postgresql:hobby-dev
```

## Frontend Deployment

### Android (Google Play Store)
```bash
# Generate keystore
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Build release APK
flutter build apk --release

# Build app bundle
flutter build appbundle --release

# Upload to Play Store via Play Console
```

### iOS (App Store)
```bash
# Build iOS release
flutter build ios --release

# Create .ipa file
flutter build ios --release -t lib/main.dart

# Upload via Xcode or TestFlight
```

## Monitoring & Logging

### Backend Monitoring
- **Sentry**: Error tracking
```bash
pip install sentry-sdk
# Add to main.py
```

- **Datadog**: APM monitoring
- **New Relic**: Full-stack monitoring

### Database Monitoring
- AWS CloudWatch
- Heroku Metrics
- PostgreSQL native tools

## SSL/TLS Certificates

### Let's Encrypt (Free)
```bash
# Install Certbot
sudo apt-get install certbot

# Generate certificate
sudo certbot certonly --standalone -d yourdomain.com

# Renewal (automatic with systemd)
sudo systemctl enable certbot.timer
```

## CDN Setup

### For Static Assets
```bash
# Use CloudFlare for domain DNS and caching
# Or AWS CloudFront for S3 storage
```

## Scaling Strategies

### Horizontal Scaling
- Docker container orchestration (Kubernetes)
- Load balancing (NGINX, HAProxy)
- Database replication

### Vertical Scaling
- Increase server resources
- Optimize database queries
- Implement caching (Redis)

## Backup & Recovery

### Database Backups
```bash
# PostgreSQL backup
pg_dump -U cooking_user smart_cooking_helper > backup.sql

# Restore
psql -U cooking_user smart_cooking_helper < backup.sql

# Automated backups
pg_dump -U cooking_user smart_cooking_helper | gzip > backup-$(date +%Y%m%d).sql.gz
```

### Firebase Backups
- Enable Firestore automated backups
- Store backups in Google Cloud Storage

## Performance Optimization

### Backend
- Enable gzip compression
- Implement caching headers
- Use database indexes
- Implement query pagination
- Use CDN for static files

### Frontend
- Enable code obfuscation
- Optimize images
- Use lazy loading
- Implement service workers for offline support

## Security Checklist

- [ ] Enable HTTPS/SSL
- [ ] Set strong database passwords
- [ ] Enable database encryption
- [ ] Implement rate limiting
- [ ] Add Web Application Firewall (WAF)
- [ ] Enable CORS restrictions
- [ ] Use environment variables for secrets
- [ ] Enable logging and monitoring
- [ ] Regular security updates
- [ ] Implement backup retention policy

## CI/CD Pipeline

### GitHub Actions Example
```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Heroku
        uses: akhileshns/heroku-deploy@v3.12.12
        with:
          heroku_api_key: ${{secrets.HEROKU_API_KEY}}
          heroku_app_name: your-app-name
          heroku_email: your-email@example.com
```

## Post-Deployment

1. **Test endpoints** with Postman or curl
2. **Load testing** with Artillery or JMeter
3. **Monitor logs** for errors
4. **Check database** integrity
5. **Verify backups** are working
6. **Set up alerting** for critical metrics
7. **Document** deployment process
8. **Plan rollback** strategy

## Troubleshooting

### Database Connection Issues
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check connection
psql -U cooking_user -h localhost -d smart_cooking_helper
```

### API Not Responding
```bash
# Check server status
curl -i http://localhost:8000/health

# Check logs
docker logs smart-cooking-api

# Restart container
docker restart smart-cooking-api
```

### High Memory Usage
```bash
# Monitor container resources
docker stats

# Implement memory limits
docker run -m 512m smart-cooking-api
```

## Support & Maintenance

- Set up monitoring alerts
- Schedule regular maintenance windows
- Keep dependencies updated
- Review logs regularly
- Plan capacity growth
- Document procedures
