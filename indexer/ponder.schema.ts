import { onchainTable } from "ponder";

export const round = onchainTable("round", (t) => ({
  id: t.text().primaryKey(),
  roundNumber: t.bigint().notNull(),
  winner: t.hex(),
  prizePool: t.bigint().notNull(),
  completedAt: t.bigint().notNull(),
}));

export const roundPlayer = onchainTable("round_player", (t) => ({
  id: t.text().primaryKey(),
  roundNumber: t.bigint().notNull(),
  player: t.hex().notNull(),
  entryCount: t.integer().notNull(),
}));
