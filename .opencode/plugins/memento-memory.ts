import type { Plugin } from "@opencode-ai/plugin"

/**
 * Memento Memory Plugin
 *
 * Injects memory retrieval and recording reminders at key points in the
 * agent lifecycle to ensure consistent use of the memento knowledge graph.
 */

const PROJECT_NAME = "rizer"
const PROJECT_PATH = "/home/jwilger/projects/rizer"

const COMPACTION_CONTEXT = `
## Memento Memory State

Before compacting, ensure any valuable knowledge from this session has been
recorded to the memento knowledge graph. Knowledge not recorded will be lost
during compaction.

Priority items to record before compaction:
1. Any decisions made and their rationale
2. Bug analyses or debugging insights
3. Patterns or conventions established
4. Configuration or setup details discovered

Use the "memory-recording" skill if needed.

Project context for recordings:
- Project: ${PROJECT_NAME}
- Path: ${PROJECT_PATH}
- Scope: PROJECT_SPECIFIC
`

const SUBAGENT_MEMORY_INJECTION = `

<system-reminder>
## Subagent Memory Context

You have access to the memento knowledge graph for persistent memory.

Before starting work:
1. Search for relevant memories: memento_semantic_search(query: "${PROJECT_NAME} <your-task-topic>")
2. Review any found entities for applicable context

Before completing:
1. If you discovered anything valuable, record it using memento_create_entities
2. First observation must include: "Project: ${PROJECT_NAME} | Path: ${PROJECT_PATH} | Scope: PROJECT_SPECIFIC"
</system-reminder>
`

export const MementoMemoryPlugin: Plugin = async () => {
  // No async work during initialization - just return the hooks
  return {
    // Inject memory context into compaction prompt
    "experimental.session.compacting": async (_input, output) => {
      output.context.push(COMPACTION_CONTEXT)
    },

    // Inject memory instructions into subagent Task tool calls
    "tool.execute.before": async (input, output) => {
      if (input.tool === "task") {
        const originalPrompt = output.args.prompt as string
        if (originalPrompt && !originalPrompt.includes("memento")) {
          output.args.prompt = originalPrompt + SUBAGENT_MEMORY_INJECTION
        }
      }
    },
  }
}
