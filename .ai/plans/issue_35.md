# Plan implementacji US-012: View Round Information

## Kontekst

**Issue #35:** US-012 - View Round Information
**Branch:** `feature/issue-35-frontend-initialization`

## Acceptance Criteria (AC)

- **AC1:** Entrance fee displayed in ETH (page load)
- **AC2:** Prize pool displayed (accumulated entrance fees)
- **AC3:** Number of players in current round
- **AC4:** Time remaining until drawing (countdown)
- **AC5:** Data refreshes automatically when new player enters

## Architektura danych

| Dane | Źródło | Uzasadnienie |
|------|--------|--------------|
| Entrance Fee | Kontrakt (cache) | Immutable → cache w localStorage |
| Interval | Kontrakt (cache) | Immutable → cache w localStorage |
| Prize Pool | Ponder | Agregacja, real-time |
| Liczba graczy | Ponder | Count, real-time |
| Last Timestamp | Ponder | Dynamiczne, real-time |

---

## Sesje robocze

### ✅ Sesja 1: Inicjalizacja projektów - UKOŃCZONA

**Cel:** Struktura monorepo z frontend i indexer

**Spełnia AC:** Podstawa infrastruktury dla wszystkich AC

**Status:** 6 commitów (72bebb7 → e208fb6)

---

### Sesja 2: Ponder Schema + Anvil Config

**Cel:** Ponder działa lokalnie z Anvil

**Spełnia AC:**
- **AC2** (prize pool) - Round entity z prizePool
- **AC3** (liczba graczy) - Entry entity, playerCount w Round
- **AC4** (countdown) - lastTimeStamp w Round
- **AC5** (auto-refresh) - podstawa dla SSE

**Zadania:**
1. Skopiować ABI z `out/Raffle.sol/Raffle.json` do `indexer/abis/`
2. Skonfigurować `ponder.config.ts` dla Anvil (chain 31337, disableCache: true)
3. Zdefiniować schema w `ponder.schema.ts`:
   - `Round` - roundNumber, status, prizePool, playerCount, lastTimeStamp, winner
   - `Entry` - id, roundNumber, player, timestamp
4. Wygenerować typy: `pnpm ponder codegen`

**Pliki:**
- `indexer/abis/RaffleAbi.ts`
- `indexer/ponder.config.ts`
- `indexer/ponder.schema.ts`

**Kryterium ukończenia:**
- `pnpm dev` startuje bez błędów

---

### Sesja 3: Ponder Event Handlers

**Cel:** Indeksowanie eventów Raffle

**Spełnia AC:**
- **AC2** (prize pool) - handler aktualizuje prizePool przy RaffleEntered
- **AC3** (liczba graczy) - handler zwiększa playerCount
- **AC4** (countdown) - handler ustawia lastTimeStamp
- **AC5** (auto-refresh) - eventy triggerują aktualizację

**Zadania:**
1. Zaimplementować handlery w `src/index.ts`:
   - `Raffle:RaffleEntered` - utwórz/aktualizuj Round, utwórz Entry
   - `Raffle:DrawCompleted` - zamknij Round, ustaw winner
2. Logika:
   - Na RaffleEntered: prizePool += entranceFee, playerCount++
   - Na DrawCompleted: status = "completed", winner = event.winner

**Pliki:**
- `indexer/src/index.ts`

**Kryterium ukończenia:**
- Deploy kontrakt na Anvil, wykonaj enterRaffle, sprawdź czy Ponder indeksuje

---

### Sesja 4: Contract Read (Frontend)

**Cel:** Odczyt immutable z kontraktu + cache

**Spełnia AC:**
- **AC1** (entrance fee) - `getEntranceFee()` z kontraktu
- **AC4** (countdown) - `getInterval()` z kontraktu (potrzebny getter!)

**Zadania:**
1. Dodać `getInterval()` getter do kontraktu Raffle.sol
2. Skopiować ABI do `frontend/src/constants/`
3. Zainstalować viem
4. Utworzyć `useContractConfig()` hook:
   - Odczyt entranceFee i interval przy mount
   - Cache w localStorage
   - Zwraca cached values

**Pliki:**
- `src/Raffle.sol` - dodać `getInterval()`
- `frontend/src/constants/contracts.ts`
- `frontend/src/hooks/useContractConfig.ts`

**Kryterium ukończenia:**
- Hook zwraca entranceFee i interval
- Wartości cached w localStorage

---

### Sesja 5: Ponder Integration (Frontend)

**Cel:** Live data z Ponder indexera

**Spełnia AC:**
- **AC2** (prize pool) - query z Ponder
- **AC3** (liczba graczy) - query z Ponder
- **AC4** (countdown) - lastTimeStamp z Ponder
- **AC5** (auto-refresh) - SSE subscriptions

**Zadania:**
1. Zainstalować @ponder/react, @tanstack/react-query
2. Skonfigurować PonderProvider
3. Utworzyć `useCurrentRound()` hook:
   - Query: current round (status = "open")
   - Returns: prizePool, playerCount, lastTimeStamp
   - Live subscription (SSE)

**Pliki:**
- `frontend/src/lib/ponder.ts`
- `frontend/src/hooks/useCurrentRound.ts`

**Kryterium ukończenia:**
- Hook zwraca live data z Ponder
- Dane odświeżają się przy nowym wpisie

---

### Sesja 6: Round Info Panel (UI)

**Cel:** Wyświetlanie informacji o rundzie

**Spełnia AC:**
- **AC1** (entrance fee) - wyświetla z useContractConfig
- **AC2** (prize pool) - wyświetla z useCurrentRound
- **AC3** (liczba graczy) - wyświetla z useCurrentRound
- **AC4** (countdown) - komponent Countdown

**Zadania:**
1. Utworzyć `RoundInfoPanel` z shadcn/ui Card:
   - Entrance fee (ETH) - z useContractConfig
   - Prize pool (ETH) - z useCurrentRound
   - Players count - z useCurrentRound
   - Time remaining - Countdown component
2. Utworzyć `Countdown` component:
   - Props: lastTimeStamp, interval
   - Kalkulacja: interval - (now - lastTimeStamp)
   - Auto-update co sekundę

**Pliki:**
- `frontend/src/components/RoundInfoPanel.tsx`
- `frontend/src/components/Countdown.tsx`

**Kryterium ukończenia:**
- Panel wyświetla wszystkie 4 wartości
- Countdown tyka co sekundę
- Dane odświeżają się automatycznie

---

### Sesja 7: Local Testing (Full Stack)

**Cel:** E2E test na Anvil

**Spełnia AC:** Weryfikacja wszystkich AC

**Zadania:**
1. Test lokalny end-to-end:
   - Terminal 1: `anvil`
   - Terminal 2: `forge script script/DeployRaffle.s.sol --broadcast --rpc-url http://localhost:8545`
   - Terminal 3: `cd indexer && pnpm dev`
   - Terminal 4: `cd frontend && pnpm dev`
2. Scenariusze testowe:
   - **AC1:** Strona ładuje się, entrance fee widoczny
   - **AC2:** Po enterRaffle, prize pool się aktualizuje
   - **AC3:** Po enterRaffle, player count rośnie
   - **AC4:** Countdown tyka, pokazuje poprawny czas
   - **AC5:** Drugi gracz wchodzi → UI odświeża się automatycznie
3. Dodać `make dev-local` do Makefile

**Kryterium ukończenia:**
- Wszystkie AC zweryfikowane manualnie
- Dokumentacja testu w PR

---

## Kolejność sesji

```
✅ Sesja 1 (done)
      │
      ├──► Sesja 2 (Ponder Schema)     → AC2, AC3, AC4, AC5
      │         │
      │         ▼
      │    Sesja 3 (Ponder Handlers)   → AC2, AC3, AC4, AC5
      │         │
      │         ▼
      │    Sesja 5 (Ponder Frontend)   → AC2, AC3, AC4, AC5
      │         │
      └──► Sesja 4 (Contract Read)     → AC1, AC4
                │
                ▼
           Sesja 6 (UI Panel)          → AC1, AC2, AC3, AC4
                │
                ▼
           Sesja 7 (Testing)           → Weryfikacja wszystkich AC
```

**Ścieżka krytyczna:** 1 → 2 → 3 → 5 → 6 → 7

**Równoległa:** Sesja 4 może być robiona równolegle z 2-3

---

## Weryfikacja końcowa (Sesja 7)

| AC | Test | Expected |
|----|------|----------|
| AC1 | Załaduj stronę | Entrance fee: 0.01 ETH |
| AC2 | Po 2x enterRaffle | Prize pool: 0.02 ETH |
| AC3 | Po 2x enterRaffle | Players: 2 |
| AC4 | Odczekaj 10s | Countdown zmniejsza się |
| AC5 | Drugi terminal: enterRaffle | UI odświeża się <1s |

---

## Usunięte z planu (nie dotyczą US-012)

- ~~Sesja 2: Wallet Integration~~ → US-013: Connect Wallet
- ~~useEnterRaffle()~~ → US-014: Enter Raffle
- ~~useClaimPrize()~~ → US-017: Claim Prize
