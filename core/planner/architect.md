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

## Design Principles
1. **Simplicity:** Fewer components that work well > many thin abstractions
2. **Security-first:** Every endpoint authenticated unless explicitly public
3. **Testability:** Every component must be testable in isolation
4. **No premature optimization:** Design for current requirements, not hypothetical scale

Present the architecture to the user for approval. Iterate based on feedback.
