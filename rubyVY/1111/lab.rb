require 'json'
require 'yaml'

class EventManager
  def initialize
    @events = {}
  end

  def create_event(title, info)
    return puts " Подія '#{title}' вже існує." if @events.key?(title)

    @events[title] = info
    puts " Додано подію '#{title}'."
  end

  def update_event(title, new_info)
    unless @events.key?(title)
      puts " Подія '#{title}' не знайдена."
      return
    end

    @events[title] = new_info
    puts " Подію '#{title}' оновлено."
  end

  def remove_event(title)
    if @events.delete(title)
      puts " Подію '#{title}' видалено."
    else
      puts " Подія '#{title}' не знайдена."
    end
  end

  def find_events(keyword)
    key = keyword.downcase
    results = @events.select do |title, info|
      title.downcase.include?(key) ||
      info[:description].to_s.downcase.include?(key) ||
      (info[:participants] || []).any? { |p| p.downcase.include?(key) } ||
      (info[:locations] || []).any? { |l| l.downcase.include?(key) }
    end

    if results.empty?
      puts " Нічого не знайдено за ключовим словом '#{keyword}'."
    else
      puts " Знайдено #{results.size} подій:"
      results.each { |title, info| show_event(title, info) }
    end
  end

  def show_all
    if @events.empty?
      puts " Немає жодної події."
    else
      puts " Усі події:"
      @events.each { |title, info| show_event(title, info) }
    end
  end

  def export(filename, format)
    case format.downcase
    when 'json'
      File.write(filename, JSON.pretty_generate(@events))
      puts " Збережено у '#{filename}' як JSON."
    when 'yaml'
      File.write(filename, @events.to_yaml)
      puts " Збережено у '#{filename}' як YAML."
    else
      puts " Невідомий формат '#{format}'."
    end
  end

  def import(filename)
    unless File.exist?(filename)
      puts " Файл '#{filename}' не знайдено."
      return
    end

    case File.extname(filename)
    when '.json'
      @events = JSON.parse(File.read(filename), symbolize_names: true)
      puts " Завантажено з JSON-файлу '#{filename}'."
    when '.yaml', '.yml'
      @events = YAML.load_file(filename)
      puts " Завантажено з YAML-файлу '#{filename}'."
    else
      puts " Непідтримуваний формат файлу '#{filename}'."
    end
  end

  private

  def show_event(title, info)
    puts "\n Назва: #{title}"
    puts " Дата: #{info[:date]}"
    puts " Учасники: #{Array(info[:participants]).join(', ')}"
    puts " Локації: #{Array(info[:locations]).join(', ')}"
    puts " Опис: #{info[:description]}"
  end
end


manager = EventManager.new

manager.create_event("Гараж", {
  date: "2025-09-10",
  participants: ["Саня", "Богдан"],
  locations: ["Київ", "Одеса"],
  description: "Ремонт Афто"
})

manager.update_event("Гараж", {
  date: "1111",
  participants: ["Саня", "Богдан"],
  locations: ["Київ", "Одеса","Саня"],
  description: "Ремонт Афто"
})



manager.show_all

manager.export("events.yaml", "yaml")

manager.export("events.json", "json")

manager.import("events.yaml")

manager.remove_event("Гараж")

manager.show_all
