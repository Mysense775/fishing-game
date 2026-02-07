#!/bin/bash
# Скрипт для запуска игры "Поймай рыбку" с HTTPS через ngrok

cd /root/.openclaw/workspace/fishing_game

echo "🎣 Запуск сервера игры 'Поймай рыбку'..."
echo ""

# Проверяем установлен ли ngrok
if ! command -v ngrok &> /dev/null; then
echo "⚠️ ngrok не найден. Устанавливаю..."
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt update && sudo apt install -y ngrok
fi

# Проверяем authtoken
if ! ngrok config check &>/dev/null; then
echo "⚠️ Нужно настроить ngrok authtoken!"
echo "Получи токен на https://dashboard.ngrok.com/get-started/your-authtoken"
echo "И выполни: ngrok config add-authtoken YOUR_TOKEN"
exit 1
fi

# Запускаем Python HTTP сервер в фоне
echo "🚀 Запуск HTTP сервера на порту 8080..."
python3 -m http.server 8080 &
SERVER_PID=$!

sleep 2

# Запускаем ngrok
echo "🌐 Запуск ngrok туннеля..."
ngrok http 8080 --log=stdout &
NGROK_PID=$!

echo ""
echo "✅ Сервер запущен!"
echo ""
echo "📋 Для остановки выполни:"
echo "   kill $SERVER_PID $NGROK_PID"
echo ""
echo "🔗 URL будет показан в логах ngrok (обычно https://xxxx.ngrok.io)"
echo "   Открой https://dashboard.ngrok.com/endpoints чтобы увидеть URL"

# Ждем Ctrl+C
trap "kill $SERVER_PID $NGROK_PID 2>/dev/null; exit" INT
wait