import { onchainTable } from "ponder";

export const round = onchainTable("round", (t) => ({
  id: t.text().primaryKey(),
  roundNumber: t.bigint().notNull(),
  winner: t.hex(),
  prizePool: t.bigint().notNull(),
  completedAt: t.bigint().notNull(),
}));
