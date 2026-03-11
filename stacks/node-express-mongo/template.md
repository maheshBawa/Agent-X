# Node.js Express + MongoDB Project Scaffold

## Directory Structure
```
├── src/
│   ├── index.ts                # App entry point
│   ├── app.ts                  # Express app configuration
│   ├── config/                 # Configuration
│   │   └── index.ts
│   ├── models/                 # Mongoose models
│   ├── routes/                 # Express route handlers
│   ├── middleware/             # Custom middleware (auth, validation)
│   ├── services/              # Business logic
│   └── types/                 # TypeScript types
├── tests/
│   ├── unit/
│   ├── integration/
│   └── setup.ts
├── .env.example
├── tsconfig.json
├── package.json
└── Dockerfile
```

## Setup Commands
```bash
npm init -y
npm install express mongoose zod jsonwebtoken bcryptjs cors helmet dotenv
npm install -D typescript vitest supertest @types/express @types/node tsx eslint prettier
npx tsc --init
```
