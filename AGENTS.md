# Agent Instructions

## Communication Rules

### Asking Questions

You **MUST ALWAYS** use the `question` tool when you need to ask for information
from the user. Do not ask questions in plain text output - use the tool so the
user can respond through the structured interface.

## Memory System (Memento MCP)

This project uses the **memento MCP knowledge graph** to provide persistent
"mid-term memory" - knowledge that bridges the gap between your training data
cutoff and the current session.

### Prime Directive: Knowledge Acquisition

**Acquiring and preserving knowledge is a core responsibility.** You must:

1. **Retrieve** relevant memories at the start of every task
2. **Record** valuable new knowledge at appropriate checkpoints

### Memory Retrieval (Task Start)

At the **start of every task**, before doing any work:

1. Load the `memory-retrieval` skill for detailed instructions
2. Perform semantic searches with queries relevant to your task:
   ```
   memento_semantic_search(query: "rizer <task-relevant-terms>")
   ```
3. Review found entities for applicable decisions, patterns, or context
4. Incorporate relevant knowledge into your approach

**Always search even if you think you know the answer** - memories may contain
recent decisions that override older patterns.

### Memory Recording (Checkpoints)

Record new knowledge at these checkpoints:

- **End of every task**: After completing significant work
- **End of every session**: Before the conversation concludes
- **Before context compaction**: To preserve knowledge that would otherwise be lost
- **After important discoveries**: When learning something that should persist

#### What to Record

- Architectural and design decisions (and their rationale)
- Bug analyses and root causes
- Established patterns and conventions
- Configuration details requiring investigation
- User preferences and project requirements

#### Recording Format

Always include project metadata as the **first observation**:

```
Project: rizer | Path: /home/jwilger/projects/rizer | Scope: PROJECT_SPECIFIC
```

Load the `memory-recording` skill for detailed recording procedures.

### Quick Reference

| Action               | Tool                       | When                         |
| -------------------- | -------------------------- | ---------------------------- |
| Search memories      | `memento_semantic_search`  | Task start                   |
| Get specific entity  | `memento_open_nodes`       | Following references         |
| Create new knowledge | `memento_create_entities`  | Recording new info           |
| Update existing      | `memento_add_observations` | Appending to existing entity |
| Link entities        | `memento_create_relations` | Connecting related knowledge |

### Skills Available

- `memory-retrieval`: Detailed retrieval procedure and best practices
- `memory-recording`: Detailed recording procedure, entity types, and examples
