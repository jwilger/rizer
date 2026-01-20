---
name: memory-retrieval
description: Retrieve relevant memories from memento knowledge graph at task start
---

# Memory Retrieval Skill

Use this skill at the **start of every task** to retrieve relevant context from
the memento knowledge graph. This provides "mid-term memory" - knowledge acquired
between your training data cutoff and the current session.

## When to Use

- At the start of any new task or conversation
- When encountering unfamiliar parts of the codebase
- Before making significant architectural decisions
- When asked about past work or decisions

## Retrieval Procedure

### Step 1: Identify Search Queries

Construct 2-4 semantic search queries based on:

1. **Project context**: Always include the current project name (e.g., "rizer")
2. **Task domain**: Key concepts from the current task (e.g., "authentication",
   "database schema", "API design")
3. **Technical patterns**: Relevant patterns or technologies (e.g., "Rust async",
   "error handling", "testing strategy")

### Step 2: Execute Semantic Searches

Use `memento_semantic_search` with these parameters:

```
query: "<your search query>"
limit: 10
min_similarity: 0.6
hybrid_search: true
```

Example searches for a task about adding authentication:

```
memento_semantic_search(query: "rizer authentication")
memento_semantic_search(query: "rizer user security")
memento_semantic_search(query: "Rust authentication patterns")
```

### Step 3: Filter by Project Relevance

Check the first observation of each entity for project association:

- **Project-specific**: First observation contains
  `Project: rizer | Path: /home/jwilger/projects/rizer | Scope: PROJECT_SPECIFIC`
- **General knowledge**: First observation contains `Scope: GENERAL` or no
  project prefix

Prioritize project-specific memories, but include relevant general knowledge.

### Step 4: Expand Context (Graph Traversal)

If relations exist, use `memento_open_nodes` to retrieve related entities:

1. Note any entity names mentioned in observations
2. Open those nodes to gather connected context
3. Stop expanding when entities become tangentially relevant

Since relations may be sparse, focus on entity observations which often contain
references to related concepts.

### Step 5: Synthesize Retrieved Knowledge

Organize retrieved memories into categories:

- **Decisions**: Past architectural/design decisions and their rationale
- **Patterns**: Established patterns and conventions for this project
- **Context**: Background information relevant to the current task
- **Warnings**: Past issues, bugs, or pitfalls to avoid

## Output Format

After retrieval, briefly summarize what you found:

```
## Retrieved Memories

### Relevant to Current Task
- [Entity Name]: Key insight or decision
- [Entity Name]: Relevant pattern or convention

### Project Context
- [Brief summary of project-specific knowledge that applies]

### Potential Considerations
- [Any warnings or past issues relevant to this task]
```

## Example Retrieval Session

For a task "Add health check endpoint to rizer":

```
1. Search: "rizer health check API"
   → Found: "Rizer API Design Decisions" (ADR about REST conventions)

2. Search: "Rust health endpoint patterns"
   → Found: "Axum Health Check Pattern" (general knowledge)

3. Search: "rizer monitoring observability"
   → Found: "Rizer Observability Strategy" (project decision)

4. Expand: Open "Rizer API Design Decisions"
   → Observations mention "REST conventions", "error handling"
   → Note: Uses standard HTTP status codes

Summary: Project uses REST with standard HTTP codes. Health endpoints
should follow /health convention returning 200 OK with JSON body.
```

## Important Notes

- Always search even if you think you know the answer - memories may contain
  recent decisions that override older patterns
- If no relevant memories found, proceed with the task but note this for
  potential recording later
- Keep retrieval focused - don't spend excessive time searching if initial
  queries yield no results
