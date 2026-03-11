# Next.js + PostgreSQL Project Scaffold

## Directory Structure
```
├── src/
│   ├── app/                    # Next.js App Router pages
│   │   ├── layout.tsx          # Root layout
│   │   ├── page.tsx            # Home page
│   │   ├── globals.css         # Global styles
│   │   └── api/                # API routes
│   ├── components/             # React components
│   │   ├── ui/                 # Reusable UI components
│   │   └── features/           # Feature-specific components
│   ├── lib/                    # Utility functions and shared logic
│   │   ├── db.ts               # Prisma client instance
│   │   ├── auth.ts             # Authentication utilities
│   │   └── validations.ts      # Zod schemas
│   └── types/                  # TypeScript type definitions
├── prisma/
│   ├── schema.prisma           # Database schema
│   └── migrations/             # Database migrations
├── tests/
│   ├── unit/                   # Unit tests
│   ├── integration/            # Integration tests
│   └── e2e/                    # Playwright E2E tests
├── public/                     # Static assets
├── .env.example                # Environment variable template
├── .gitignore
├── next.config.ts
├── tailwind.config.ts
├── tsconfig.json
├── vitest.config.ts
├── playwright.config.ts
└── package.json
```

## Setup Commands
```bash
npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir
npm install @prisma/client zod
npm install -D prisma vitest @testing-library/react @testing-library/jest-dom @vitejs/plugin-react jsdom playwright @playwright/test prettier
npx prisma init
```

## Key Patterns
- Use Server Components by default, Client Components only when needed
- Use Server Actions for mutations
- Use Prisma for all database access
- Use Zod for input validation
- Use Tailwind CSS for styling
- Environment variables in `.env.local` (never commit)
