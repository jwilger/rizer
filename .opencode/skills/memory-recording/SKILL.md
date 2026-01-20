---
name: memory-recording
description: Record new knowledge to memento knowledge graph for future retrieval
---

# Memory Recording Skill

Use this skill to **persist valuable knowledge** acquired during tasks. This
creates "mid-term memory" that bridges the gap between training data and future
sessions.

## When to Record

Record memories at these trigger points:

1. **End of task**: After completing any significant work
2. **End of session**: Before the conversation ends
3. **Before context compaction**: When context is about to be summarized
4. **After important discoveries**: When learning something that should persist

## What to Record

### SHOULD Record

- **Architectural decisions** and their rationale
- **Design patterns** adopted for this project
- **Bug analyses** and root causes discovered
- **Configuration details** that required investigation
- **User preferences** and working style observations
- **Project conventions** (naming, structure, testing approach)
- **Integration details** (APIs, services, dependencies)
- **Troubleshooting findings** that took effort to discover

### Should NOT Record

- Ephemeral task details (temporary file paths, session-specific variables)
- Information already in version control (commit messages capture this)
- Trivial facts easily re-discovered (standard library usage)
- Sensitive data (credentials, API keys, personal information)

## Recording Procedure

### Step 1: Identify New Knowledge

Ask yourself:

1. What did I learn that I didn't know at task start?
2. What decisions were made and why?
3. What would be valuable to know in a future session?
4. What took significant effort to discover or understand?

### Step 2: Check for Existing Entities

Before creating new entities, search for existing ones to update:

```
memento_search_nodes(query: "<concept you want to record>")
```

If a relevant entity exists, use `memento_add_observations` to append new
information rather than creating duplicates.

### Step 3: Structure the Entity

#### Entity Name

Use descriptive, human-readable names:

- **Good**: "Rizer Database Connection Pooling Strategy"
- **Good**: "PR #42 Authentication Bug Analysis"
- **Bad**: "db_config" (too terse)
- **Bad**: "stuff I learned today" (not descriptive)

Naming patterns:

- `<Project> <Topic> <Type>` - "Rizer API Error Handling Pattern"
- `<Identifier> <Description>` - "ADR-0001 Event Sourcing Decision"
- `<Topic> <Date Context>` - "CI Pipeline Fix January 2026"

#### Entity Type

Use descriptive snake_case or Title Case types. Common types observed:

| Category      | Types                                                                     |
| ------------- | ------------------------------------------------------------------------- |
| Decisions     | `architecture_decision`, `design_pattern`, `implementation_decision`      |
| Technical     | `bug_analysis`, `bug_fix`, `debugging_insight`, `troubleshooting_finding` |
| Code          | `rust_pattern`, `architectural_pattern`, `test_pattern`, `domain_model`   |
| Process       | `pr_pattern`, `git_branch`, `deployment_success`, `implementation_plan`   |
| Documentation | `documentation_update`, `architecture_decision_record`                    |
| Analysis      | `code_analysis`, `technical_analysis`, `project_analysis`                 |

Choose the most specific type that fits, or create a new descriptive type.

#### First Observation (Project Association)

**ALWAYS** include project metadata as the first observation:

```
Project: rizer | Path: /home/jwilger/projects/rizer | Scope: PROJECT_SPECIFIC
```

For general knowledge not tied to a specific project:

```
Scope: GENERAL | Topic: <general topic area>
```

#### Subsequent Observations

Each observation should be a complete, self-contained fact:

- **Good**: "Uses connection pooling with max 10 connections per database"
- **Good**: "Decision made on 2026-01-20 after performance testing showed 3x improvement"
- **Bad**: "pooling" (too terse, lacks context)
- **Bad**: "See above" (not self-contained)

Include:

- Specific technical details
- Rationale for decisions (the "why")
- Dates when relevant
- File paths for code-related knowledge
- Constraints or limitations discovered

### Step 4: Create or Update Entity

#### Creating New Entity

```
memento_create_entities(entities: [{
  name: "Rizer Database Connection Strategy",
  entityType: "architecture_decision",
  observations: [
    "Project: rizer | Path: /home/jwilger/projects/rizer | Scope: PROJECT_SPECIFIC",
    "Decision: Use sqlx with connection pooling, max 10 connections",
    "Rationale: Testing showed 3x throughput improvement over single connection",
    "Date: 2026-01-20",
    "Configuration in src/db/pool.rs with PgPoolOptions",
    "Environment variable DATABASE_MAX_CONNECTIONS controls pool size"
  ]
}])
```

#### Updating Existing Entity

```
memento_add_observations(observations: [{
  entityName: "Rizer Database Connection Strategy",
  contents: [
    "Update 2026-01-25: Added connection timeout of 30s after intermittent failures",
    "New config option DATABASE_CONNECT_TIMEOUT added"
  ]
}])
```

### Step 5: Create Relations (When Meaningful)

If the new knowledge connects to existing entities, create relations:

```
memento_create_relations(relations: [{
  from: "Rizer Database Connection Strategy",
  to: "Rizer Performance Optimization Plan",
  relationType: "implements",
  strength: 0.9,
  confidence: 1.0
}])
```

Common relation types:

- `implements` - This implements/satisfies that
- `depends_on` - This requires that
- `relates_to` - General association
- `supersedes` - This replaces that decision
- `caused_by` - This issue was caused by that

## Recording Checklist

Before finishing a task/session, verify:

- [ ] Did I make any decisions that should be recorded?
- [ ] Did I discover anything non-obvious about the codebase?
- [ ] Did I establish any patterns or conventions?
- [ ] Did I encounter and resolve any issues worth remembering?
- [ ] Did I learn any user preferences or project requirements?

## Example Recording Session

After implementing authentication for rizer:

```
1. Search for existing: memento_search_nodes("rizer authentication")
   → No existing entities found

2. Create new entity:
   memento_create_entities(entities: [{
     name: "Rizer Authentication Architecture",
     entityType: "architecture_decision",
     observations: [
       "Project: rizer | Path: /home/jwilger/projects/rizer | Scope: PROJECT_SPECIFIC",
       "Decision: JWT-based authentication with refresh tokens",
       "Library: jsonwebtoken crate for JWT handling",
       "Token expiry: 15 minutes access, 7 days refresh",
       "Storage: Refresh tokens stored in PostgreSQL with user_sessions table",
       "Rationale: Stateless access tokens reduce DB load, refresh tokens allow revocation",
       "Security: Tokens signed with RS256, keys rotated monthly",
       "Implementation date: 2026-01-20",
       "Key files: src/auth/jwt.rs, src/auth/middleware.rs, src/db/sessions.rs"
     ]
   }])

3. Create relation to existing user entity:
   memento_create_relations(relations: [{
     from: "Rizer Authentication Architecture",
     to: "Rizer User Management",
     relationType: "implements",
     strength: 0.8,
     confidence: 1.0
   }])
```

## Important Notes

- **Be specific**: Vague memories are useless memories
- **Include rationale**: The "why" is often more valuable than the "what"
- **Date significant decisions**: Helps understand evolution over time
- **Don't over-record**: Focus on knowledge that provides future value
- **Update don't duplicate**: Search first, add observations to existing entities
