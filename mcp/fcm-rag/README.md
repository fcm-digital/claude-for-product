# fcm-rag

## Purpose

Connects Claude to the FCM knowledge base. Allows asking questions about internal processes, policies, onboarding docs, and any indexed content.

## Requirements

- Claude Desktop or Claude Code installed
- Node.js LTS ([nodejs.org](https://nodejs.org))
- The RAG API URL — ask @jeiker26. They need to have the mnemos stack running locally with ngrok active.

## Inputs

- Natural language question

## Outputs

- Answer based on indexed FCM documents, with sources

## Usage

Run via the root installer or directly:

```bash
bash mcp/fcm-rag/run.sh
```

To point to a custom RAG API URL:

```bash
FCM_RAG_URL=https://your-url.ngrok-free.dev/query bash mcp/fcm-rag/run.sh
```

## Examples

> "What is the process for requesting PTO?"
> "How do I onboard a new supplier?"

## Owner

@jeiker26

## Status

Ready
