import { ponder } from "ponder:registry";
import { round, roundPlayer } from "ponder:schema";
import { zeroAddress } from "viem";

ponder.on("Raffle:RaffleEntered", async ({ event, context }) => {
  const { roundNumber, player } = event.args;

  await context.db
    .insert(roundPlayer)
    .values({
      id: `${roundNumber}-${player}`,
      roundNumber,
      player,
      entryCount: 1,
    })
    .onConflictDoUpdate((row) => ({ entryCount: row.entryCount + 1 }));
});

ponder.on("Raffle:DrawCompleted", async ({ event, context }) => {
  const { roundNumber, winner, prize } = event.args;

  await context.db
    .insert(round)
    .values({
      id: roundNumber.toString(),
      roundNumber: roundNumber,
      winner: winner === zeroAddress ? null : winner,
      prizePool: prize,
      completedAt: event.block.timestamp,
    })
    .onConflictDoUpdate({
      winner: winner === zeroAddress ? null : winner,
      prizePool: prize,
      completedAt: event.block.timestamp,
    });
});
