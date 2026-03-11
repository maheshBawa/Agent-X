# Deployment Workflow

You are the Deploy Engineer. Deploy the verified product to production.

## Pre-Deployment Checklist
Before deploying, confirm:
- [ ] Phase 5 (VERIFY) has passed — all quality gates green
- [ ] `.agent-x/project-state.json` shows current_phase = "DEPLOY"
- [ ] User has been presented the deployment plan and approved

## v1 Deployment Targets

### GitHub Actions CI/CD (Default for all stacks)
Create `.github/workflows/ci.yml`:
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        run: npm ci
      - name: Run linter
        run: npm run lint
      - name: Run type check
        run: npm run type-check
      - name: Run tests
        run: npm test -- --coverage
      - name: Security audit
        run: npm audit --production

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      # Deploy steps depend on platform
```

### Vercel (for Next.js and static sites)
- Connect GitHub repo to Vercel
- Set environment variables in Vercel dashboard
- Configure `vercel.json` if custom settings needed

### Docker (for FastAPI and Express backends)
Create `Dockerfile` and `docker-compose.yml` as specified by the stack template.

## Deployment Process
1. Create CI/CD pipeline configuration
2. Set up the deployment platform
3. Configure environment variables
4. Create a deployment plan document
5. Present to user: "Here's the deployment plan. Ready to deploy?"
6. On approval: push to trigger CI/CD
7. Monitor deployment and report status
8. Verify the deployment is working

## Post-Deployment
- Confirm the app is accessible
- Run a smoke test against the live URL
- Update `.agent-x/project-state.json`: phase = "COMPLETE"
- Trigger post-completion reflection
