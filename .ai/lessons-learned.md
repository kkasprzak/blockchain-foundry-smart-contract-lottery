# Lessons Learned

Notatki z pracy nad projektem - rzeczy, które warto pamiętać.

---

## 2025-02-01

### Deployment i konfiguracja

- **Deploy na Anvil:** `make deploy-local` - wdraża kontrakt i zapisuje adres w `broadcast/DeployRaffle.s.sol/31337/run-latest.json`
- **Adres kontraktu dla frontendu:** ustawić `VITE_RAFFLE_CONTRACT_ADDRESS` w `frontend/.env.local`
- **Po zmianie .env:** trzeba zrestartować frontend (Vite nie przeładowuje .env automatycznie)

### Zakończenie rundy loterii (lokalnie)

- **Komenda:** `make complete-draw`
- **Co robi:**
  1. `performUpkeep()` - rozpoczyna losowanie
  2. `fulfillRandomWords()` - symuluje callback VRF (tylko na Anvil z mockiem)
- **Gracze nie są wymagani** - runda zamknie się nawet bez graczy (emituje `DrawCompleted` z `winner=address(0)`)

### Logowanie frontendu

- **Logi zapisywane do:** `frontend/dev.log` (przez `tee` w Makefile)
- **Pozwala:** innemu Claude Code czytać logi i pomagać z debugowaniem
