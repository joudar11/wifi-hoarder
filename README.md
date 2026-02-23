# wifi-hoarder

Bash skript pro inteligentní a persistentní deautentizaci Wi-Fi klientů. **wifi-hoarder** si pamatuje všechny cíle, které kdy naskenoval, a útočí na ně paralelně v každém cyklu, čímž zabraňuje jejich opětovnému připojení.

## Hlavní funkce

* **Persistentní paměť:** Jednou naskenovaný klient zůstává na seznamu cílů až do restartu skriptu.
* **Multi-threaded útok:** Všechny cíle jsou deautentizovány současně (na pozadí), což zvyšuje efektivitu u vytížených sítí.
* **Robustní Whitelist:** Podpora pole MAC adres, které skript ignoruje.
* **Automatické skenování:** V každém cyklu hledá nové cíle pomocí `airodump-ng` a doplňuje svou databázi.

## Požadavky

* Linux
* Sada nástrojů **Aircrack-ng** (`airodump-ng`, `aireplay-ng`)
* Wi-Fi karta s podporou monitor módu a packet injection (např. TP-Link s příslušným chipsetem)
* Práva uživatele `root`

## Instalace a spuštění

1. Klonuj repozitář nebo stáhni skript:
   ```Shell
   git clone https://github.com/joudar11/wifi-hoarder.git
   cd wifi-hoarder
   chmod +x wifi-hoarder.sh
   ```
2. Nastav monitor mód na své kartě:
   ```Shell
   sudo airmon-ng start wlan0
   ```
3. Uprav konfiguraci přímo ve skriptu (proměnné `INTERFACE`, `BSSID_AP`, `WHITELIST`).
4. Spusť skript:
   ```Shell
   sudo ./wifi-hoarder.sh
   ```

## Konfigurace

Ve skriptu můžete upravit následující parametry:

* `INTERFACE`: Název vaší karty v monitor módu (např. `wlan_tplinkmon`).
* `BSSID_AP`: MAC adresa cílového přístupového bodu.
* `CHANNEL`: Kanál, na kterém AP vysílá.
* `RAMCU`: Počet deauth paketů odeslaných v jednom vlákně pro jednoho klienta.
* `SLEEP_INTERVAL`: Prodleva mezi útočnými cykly.

## Upozornění

Tento nástroj slouží výhradně pro edukativní účely a testování zabezpečení vlastních sítí (penetrační testování). Autor nenese odpovědnost za jakékoli zneužití nebo škody způsobené provozem tohoto skriptu v cizích sítích bez souhlasu majitele.
