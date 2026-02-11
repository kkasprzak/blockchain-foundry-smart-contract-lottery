/**
 * ⚠️  CRITICAL: MANUAL SYNC REQUIRED ⚠️
 *
 * This schema MUST exactly match: indexer/ponder.schema.ts
 *
 * If you modify the indexer schema, you MUST update this file!
 * Failure to sync will cause runtime errors without TypeScript warnings.
 *
 * Last synced: 2026-02-10
 */

import { onchainTable } from "ponder";

export const round = onchainTable("round", (t) => ({
  id: t.text().primaryKey(),
  roundNumber: t.bigint().notNull(),
  winner: t.hex(),
  prizePool: t.bigint().notNull(),
  completedAt: t.bigint().notNull(),
}));

export const schema = { round };
