# frozen_string_literal: true

require_relative "lib/our_web_gem/bot/app"

token = ENV["TELEGRAM_BOT_TOKEN"]

if token.nil? || token.empty?
  puts "Ошибка: не задан TELEGRAM_BOT_TOKEN"
  puts "Для PowerShell используй:"
  puts '$env:TELEGRAM_BOT_TOKEN="твой_токен"'
  puts "bundle exec ruby bot.rb"
  exit 1
end

puts "Бот запущен..."

OurWebGem::Bot::App.new(token).run