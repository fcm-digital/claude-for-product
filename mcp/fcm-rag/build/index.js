#!/usr/bin/env node
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
const API_URL = process.env.FCM_RAG_URL || "http://localhost:3000/query";
const DEFAULT_TOP_K = 5;
const server = new McpServer({
    name: "mcp-fcm-rag",
    version: "1.0.0",
});
server.tool("query", "Ask a question to the FCM RAG knowledge base. Use this tool to search for information about FCM processes, policies, onboarding, and any other company knowledge.", {
    question: z.string().describe("The question to ask the FCM knowledge base"),
}, async ({ question }) => {
    try {
        const response = await fetch(API_URL, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                question,
                topK: DEFAULT_TOP_K,
            }),
        });
        if (!response.ok) {
            const errorText = await response.text();
            return {
                content: [
                    {
                        type: "text",
                        text: `Error from FCM RAG API (${response.status}): ${errorText}`,
                    },
                ],
                isError: true,
            };
        }
        const data = await response.json();
        return {
            content: [
                {
                    type: "text",
                    text: JSON.stringify(data, null, 2),
                },
            ],
        };
    }
    catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        return {
            content: [
                {
                    type: "text",
                    text: `Failed to connect to FCM RAG API at ${API_URL}: ${message}`,
                },
            ],
            isError: true,
        };
    }
});
async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error("mcp-fcm-rag server running on stdio");
}
main().catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
});
