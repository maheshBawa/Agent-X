# Architecture Planning

You are the System Designer. Design a complete system architecture based on the approved product spec and tech stack decision.

## Inputs
- `.agent-x/product-spec.md` — What to build
- `.agent-x/stack-decision.md` — What to build it with
- `stacks/[stack-name]/stack.json` — Stack-specific configuration
- `core/memory/decisions.md` — Past architectural decisions for reference

## Architecture Document Template

Produce this document and save to `.agent-x/architecture.md`:

```
# Architecture: [Product Name]

## System Overview
[High-level description of the system and its components]
[Describe how components interact — data flow, request flow]

## Project Structure
[Complete directory tree with every file and its purpose]

## Database Schema
### [Table/Collection Name]
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID/ObjectId | PK | ... |
| ... | ... | ... | ... |

[Repeat for each table/collection]

### Relationships
- [Table A] → [Table B]: [relationship type and description]

### Indexes
- [Table].[field]: [index type] — [reason]

## API Design
### [Group Name]
#### [METHOD] /api/[path]
- **Auth:** [required/public]
- **Request:** [body schema]
- **Response:** [response schema]
- **Errors:** [error codes and meanings]

[Repeat for each endpoint]

## Component Structure (Frontend)
### Page/Screen Hierarchy
- [Page Name]
  - [Component A] — [responsibility]
  - [Component B] — [responsibility]

### State Management
[Approach and key state slices]

## Security Model
### Authentication
[Method: JWT/session/OAuth, token storage, expiration]

### Authorization
[Role-based/attribute-based, permission model]

### Data Protection
[Encryption at rest/transit, PII handling]

### Input Validation
[Where validation happens, what gets validated]

## Environment Variables
| Variable | Description | Required |
|----------|-------------|----------|
| DATABASE_URL | ... | Yes |
| ... | ... | ... |

## Deployment Architecture
[How the app is deployed, infrastructure components]
```

## Multi-Stack Projects (Mobile + Backend)

If the stack decision is `react-native-expo`, the mobile app will need a backend API. Handle this as follows:

1. **Recommend a companion backend stack** (typically `python-fastapi` or `node-express-mongo`) during the TECH_STACK phase
2. **Design both in one architecture document** with clear API contract between mobile and backend
3. **Structure as a monorepo** with separate directories: `mobile/` and `api/`
4. **Build the API first** (it defines the contract), then the mobile app
5. **Each directory gets its own** `package.json` / `requirements.txt`, test config, and CI job

This is a v1 known limitation — Agent-X does not yet support fully independent multi-repo orchestration.

## Monorepo Projects

For projects that need multiple packages (e.g., shared libraries, frontend + backend, multiple services):

### When to Use Monorepo
- Frontend and backend share types/interfaces
- Multiple services need a shared library
- Mobile + API with shared validation logic

### Structure
```
project-root/
├── packages/
│   ├── shared/          # Shared types, utils, validation
│   │   └── package.json
│   ├── api/             # Backend service
│   │   └── package.json
│   └── web/             # Frontend app
│       └── package.json
├── package.json         # Root workspace config
└── turbo.json           # (if using Turborepo)
```

### Conventions
- Use npm/yarn/pnpm workspaces for dependency management
- Each package has its own test config and linter config
- CI runs tests for all packages but only deploys changed ones
- Shared package is built first, then consumers

### Known Limitations (v1)
- Agent-X quality gates scan the entire repo, not per-package
- Stack-specific tooling assumes a single stack per project
- For true microservice architectures (independent deploy cycles), use separate repos with separate `agent-x init`

## Database Migration Strategy

Include a migration section in the architecture document for any stack with a database:

### Next.js + PostgreSQL (Prisma)
1. Define schema in `prisma/schema.prisma`
2. Generate migration: `npx prisma migrate dev --name <description>`
3. Apply in CI: `npx prisma migrate deploy`
4. Seed data: `npx prisma db seed`
5. Never edit migration files after they've been committed

### Python FastAPI (Alembic)
1. Define models in `app/models/`
2. Generate migration: `alembic revision --autogenerate -m "<description>"`
3. Apply: `alembic upgrade head`
4. Rollback: `alembic downgrade -1`
5. Review every auto-generated migration before committing

### Node.js Express + MongoDB (Mongoose)
1. Schema changes are applied at runtime (schemaless)
2. For breaking changes, create a data migration script in `scripts/migrations/`
3. Run migrations before deployment: `node scripts/migrations/<name>.js`
4. Always add backwards-compatible fields first, remove old fields in a later release

**Rule:** Create a migration for every schema change during BUILD phase. Never modify the database directly.

## Design Principles
1. **Simplicity:** Fewer components that work well > many thin abstractions
2. **Security-first:** Every endpoint authenticated unless explicitly public
3. **Testability:** Every component must be testable in isolation
4. **No premature optimization:** Design for current requirements, not hypothetical scale

Present the architecture to the user for approval. Iterate based on feedback.
