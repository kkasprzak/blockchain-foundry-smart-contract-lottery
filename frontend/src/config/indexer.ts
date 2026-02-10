import { env } from "./env";

export const INDEXER_URL = env.VITE_INDEXER_URL;

export const MOCK_SSE = env.VITE_MOCK_SSE === "true";
