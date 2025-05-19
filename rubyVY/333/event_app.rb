require 'json'
require 'yaml'

# Клас події
class Event
  attr_accessor :title, :date, :participants, :locations, :description

  def initialize(title:, date:, participants: [], locations: [], description: "")
    @title = title
    @date = date
    @participants = participants
    @locations = locations
    @description = description
  end

  def to_hash
    {
      title: @title,
      date: @date,
      participants: @participants,
      locations: @locations,
      description: @description
    }
  end

  def self.from_hash(hash)
    Event.new(
      title: hash[:title] || hash["title"],
      date: hash[:date] || hash["date"],
      participants: hash[:participants] || hash["participants"] || [],
      locations: hash[:locations] || hash["locations"] || [],
      description: hash[:description] || hash["description"]
    )
  end

  def to_s
    <<~EVENT
    Назва: #{@title}
    Дата: #{@date}
    Учасники: #{@participants.join(', ')}
    Локації: #{@locations.join(', ')}
    Опис: #{@description}
    EVENT
  end
end

# Клас-менеджер подій
class EventManager
  def initialize
    @events = []
  end

  def add_event(event)
    if @events.any? { |e| e.title == event.title }
      puts " Подія з назвою '#{event.title}' вже існує."
    else
      @events << event
      puts " Подію '#{event.title}' додано."
    end
  end

  def update_event(title, new_event)
    index = @events.find_index { |e| e.title == title }
    if index
      @events[index] = new_event
      puts " Подію '#{title}' оновлено."
    else
      puts " Подія '#{title}' не знайдена."
    end
  end

  def delete_event(title)
    if @events.reject! { |e| e.title == title }
      puts " Подію '#{title}' видалено."
    else
      puts " Подія '#{title}' не знайдена."
    end
  end

  def find_events(keyword)
    key = keyword.downcase
    results = @events.select do |e|
      e.title.downcase.include?(key) ||
      e.description.downcase.include?(key) ||
      e.participants.any? { |p| p.downcase.include?(key) } ||
      e.locations.any? { |l| l.downcase.include?(key) }
    end

    if results.empty?
      puts " Нічого не знайдено за ключовим словом '#{keyword}'."
    else
      results.each { |e| puts "\n#{e}" }
    end
  end

  def list_all
    if @events.empty?
      puts " Немає жодної події."
    else
      @events.each { |e| puts "\n#{e}" }
    end
  end

  def export(filename, format)
    data = @events.map(&:to_hash)

    serialized = case format.downcase
                 when 'json' then JSON.pretty_generate(data)
                 when 'yaml' then data.to_yaml
                 else
                   puts "❗ Невідомий формат '#{format}'."
                   return
                 end

    File.write(filename, serialized)
    puts " Збережено у '#{filename}' як #{format.upcase}."
  end

  def import(filename)
    unless File.exist?(filename)
      puts " Файл '#{filename}' не знайдено."
      return
    end

    data = case File.extname(filename)
           when '.json'
             JSON.parse(File.read(filename), symbolize_names: true)
           when '.yaml', '.yml'
             YAML.load_file(filename)
           else
             puts " Непідтримуваний формат."
             return
           end

    @events = data.map { |e| Event.from_hash(e) }
    puts " Завантажено подій: #{@events.size}"
  end
end

# --- Консольний інтерфейс ---

manager = EventManager.new

loop do
  puts "\n--- Меню ---"
  puts "1. Переглянути усі події"
  puts "2. Додати подію"
  puts "3. Оновити подію"
  puts "4. Видалити подію"
  puts "5. Пошук подій"
  puts "6. Зберегти у файл"
  puts "7. Завантажити з файлу"
  puts "0. Вийти"
  print "Обери опцію: "
  case gets.chomp
  when "1"
    manager.list_all
  when "2"
    print "Назва: "; title = gets.chomp
    print "Дата: "; date = gets.chomp
    print "Учасники (через кому): "; participants = gets.chomp.split(',').map(&:strip)
    print "Локації (через кому): "; locations = gets.chomp.split(',').map(&:strip)
    print "Опис: "; description = gets.chomp
    event = Event.new(title: title, date: date, participants: participants, locations: locations, description: description)
    manager.add_event(event)
  when "3"
    print "Назва події для оновлення: "; old_title = gets.chomp
    print "Нова назва: "; title = gets.chomp
    print "Дата: "; date = gets.chomp
    print "Учасники: "; participants = gets.chomp.split(',').map(&:strip)
    print "Локації: "; locations = gets.chomp.split(',').map(&:strip)
    print "Опис: "; description = gets.chomp
    event = Event.new(title: title, date: date, participants: participants, locations: locations, description: description)
    manager.update_event(old_title, event)
  when "4"
    print "Назва події: "; title = gets.chomp
    manager.delete_event(title)
  when "5"
    print "Ключове слово: "; keyword = gets.chomp
    manager.find_events(keyword)
  when "6"
    print "Ім'я файлу: "; filename = gets.chomp
    print "Формат (json/yaml): "; format = gets.chomp
    manager.export(filename, format)
  when "7"
    print "Ім'я файлу: "; filename = gets.chomp
    manager.import(filename)
  when "0"
    puts "До побачення!"
    break
  else
    puts "❗ Невірна опція."
  end
end
