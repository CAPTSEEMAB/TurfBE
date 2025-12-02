# AWS Elastic Beanstalk Deployment Guide

## 🚀 Complete Setup Instructions

### Prerequisites
- AWS Account
- AWS CLI installed
- GitHub repository with secrets configured

---

## Step 1: Install AWS CLI

```bash
# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

---

## Step 2: Create IAM User for GitHub Actions

### 2.1 Go to AWS Console
1. Open: https://console.aws.amazon.com/iam/
2. Click **Users** → **Create user**
3. User name: `github-actions-eb-deployer`
4. Click **Next**

### 2.2 Attach Policy
1. Select **"Attach policies directly"**
2. Click **"Create policy"** (opens new tab)
3. Click **JSON** tab
4. Paste the contents of `aws/iam-policy-eb-deploy.json`
5. Name it: `ElasticBeanstalkGitHubActionsPolicy`
6. Create the policy
7. Go back and attach this policy to your user

### 2.3 Create Access Keys
1. Click on your new user
2. Go to **Security credentials** tab
3. Click **Create access key**
4. Select **"Third-party service"** (for GitHub Actions)
5. **SAVE THE KEYS** - you won't see the secret again!

---

## Step 3: Configure AWS CLI

```bash
aws configure
```

Enter:
```
AWS Access Key ID: YOUR_ACCESS_KEY_ID
AWS Secret Access Key: YOUR_SECRET_ACCESS_KEY
Default region name: ap-south-1
Default output format: json
```

---

## Step 4: Create IAM Roles (One-Time Setup)

Run the setup script:

```bash
cd aws
chmod +x setup-iam-roles.sh
./setup-iam-roles.sh
```

This creates:
- `aws-elasticbeanstalk-ec2-role` - Role for EC2 instances
- Instance profile for Elastic Beanstalk

---

## Step 5: Add GitHub Secrets

Go to your GitHub repository:
1. **Settings** → **Secrets and variables** → **Actions**
2. Add these secrets:

| Secret Name | Value |
|------------|-------|
| `AWS_ACCESS_KEY_ID` | Your IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | Your IAM user secret key |

---

## Step 6: Add Environment Variables in AWS

After first deployment, go to AWS EB Console:
1. Open: https://console.aws.amazon.com/elasticbeanstalk/
2. Select your environment
3. Click **Configuration** → **Software** → **Edit**
4. Add environment variables:

| Variable | Value |
|----------|-------|
| `SUPABASE_URL` | Your Supabase URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Your service role key |
| `SUPABASE_KEY` | Your anon key |
| `JWT_SECRET` | Your JWT secret |
| `NODE_ENV` | production |
| `PORT` | 8080 |

---

## Step 7: Deploy

Push to main branch:
```bash
git add .
git commit -m "Add AWS EB deployment"
git push origin main
```

The GitHub Action will:
1. ✅ Create S3 bucket for deployments
2. ✅ Create Elastic Beanstalk application
3. ✅ Create environment (first time)
4. ✅ Deploy your application

---

## 📁 File Structure

```
TurfBackend-main/
├── .ebextensions/
│   └── 00_options.config      # EB configuration
├── .github/workflows/
│   └── aws-eb-deploy.yml      # GitHub Actions workflow
├── aws/
│   ├── iam-policy-eb-deploy.json      # IAM policy for GitHub Actions
│   ├── ec2-instance-profile-policy.json
│   ├── ec2-trust-policy.json
│   └── setup-iam-roles.sh     # One-time IAM setup script
├── Procfile                    # EB process file
└── index.js                    # Your app (with health endpoint)
```

---

## 🔧 Configuration Options

### Change AWS Region
Edit `.github/workflows/aws-eb-deploy.yml`:
```yaml
env:
  AWS_REGION: ap-south-1  # Change to your preferred region
```

### Available Regions
- `us-east-1` (N. Virginia)
- `us-west-2` (Oregon)
- `eu-west-1` (Ireland)
- `ap-south-1` (Mumbai)
- `ap-southeast-1` (Singapore)

### Change Instance Type
Edit `.ebextensions/00_options.config`:
```yaml
aws:autoscaling:launchconfiguration:
  InstanceType: t3.small  # or t3.medium, etc.
```

---

## 🐛 Troubleshooting

### View Logs
```bash
# Install EB CLI
pip install awsebcli

# View logs
eb logs
```

### Check Environment Status
```bash
aws elasticbeanstalk describe-environments \
  --application-name turf-backend \
  --environment-names turf-backend-env
```

### SSH into Instance
1. Add key pair in EB configuration
2. `eb ssh`

---

## 💰 Cost Considerations

- **t3.micro**: Free tier eligible (750 hrs/month first year)
- **SingleInstance**: No load balancer cost
- **S3**: Minimal storage for deployment packages

For production, consider:
- LoadBalanced environment
- t3.small or larger instances
- Enable auto-scaling

---

## 🔒 Security Best Practices

1. ✅ Use IAM roles instead of hardcoded credentials
2. ✅ Store secrets in GitHub Secrets
3. ✅ Use environment variables for sensitive data
4. ✅ Enable HTTPS (add SSL certificate in EB)
5. ✅ Restrict security group access

---

## Need Help?

- [AWS EB Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [GitHub Actions AWS](https://github.com/aws-actions)
