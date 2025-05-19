require 'json'
require 'yaml'

class EventOrganizer
  def initialize
    @events = {}
    @next_id = 1
  end

  def run
    loop do
      puts "\nОберіть опцію:"
      puts "1. Додати подію"
      puts "2. Редагувати подію"
      puts "3. Видалити подію"
      puts "4. Пошук подій"
      puts "5. Показати всі події"
      puts "6. Зберегти у JSON"
      puts "7. Завантажити з JSON"
      puts "8. Зберегти у YAML"
      puts "9. Завантажити з YAML"
      puts "0. Вийти"

      print "> "
      choice = gets.chomp

      case choice
      when "1" then add_event_cli
      when "2" then edit_event_cli
      when "3" then delete_event_cli
      when "4" then search_event_cli
      when "5" then list_events
      when "6" then save_to_json
      when "7" then load_from_json
      when "8" then save_to_yaml
      when "9" then load_from_yaml
      when "0" then break
      else
        puts "Невідома команда!"
      end
    end
  end

  def add_event_cli
    print "Назва події: "
    name = gets.chomp
    print "Дата події (YYYY-MM-DD): "
    date = gets.chomp
    print "Учасники (через кому): "
    participants = gets.chomp.split(',').map(&:strip)
    print "Місця проведення (через кому): "
    locations = gets.chomp.split(',').map(&:strip)
    add_event(name, date, participants, locations)
    puts "Подію додано."
  end

  def edit_event_cli
    print "Введіть ID події для редагування: "
    id = gets.to_i
    print "Нова назва (або Enter щоб пропустити): "
    name = gets.chomp
    name = nil if name.empty?
    print "Нова дата (або Enter): "
    date = gets.chomp
    date = nil if date.empty?
    print "Нові учасники (через кому або Enter): "
    part = gets.chomp
    participants = part.empty? ? nil : part.split(',').map(&:strip)
    print "Нові місця (через кому або Enter): "
    locs = gets.chomp
    locations = locs.empty? ? nil : locs.split(',').map(&:strip)

    edit_event(id, name: name, date: date, participants: participants, locations: locations)
  end

  def delete_event_cli
    print "ID події для видалення: "
    id = gets.to_i
    delete_event(id)
  end

  def search_event_cli
    print "Введіть ключове слово: "
    keyword = gets.chomp
    search_events(keyword)
  end

  # Логіка органайзера
  def add_event(name, date, participants, locations)
    event = {
      id: @next_id,
      name: name,
      date: date,
      participants: participants,
      locations: locations
    }
    @events[@next_id] = event
    @next_id += 1
  end

  def edit_event(id, name: nil, date: nil, participants: nil, locations: nil)
    unless @events.key?(id)
      puts "Подію не знайдено."
      return
    end
    event = @events[id]
    event[:name] = name if name
    event[:date] = date if date
    event[:participants] = participants if participants
    event[:locations] = locations if locations
    puts "Подію оновлено."
  end

  def delete_event(id)
    if @events.delete(id)
      puts "Подію видалено."
    else
      puts "Подію не знайдено."
    end
  end

  def search_events(keyword)
    results = @events.values.select { |e| e[:name].downcase.include?(keyword.downcase) }
    if results.empty?
      puts "Подій не знайдено."
    else
      results.each { |e| print_event(e) }
    end
  end

  def list_events
    if @events.empty?
      puts "Список подій порожній."
    else
      @events.each_value { |e| print_event(e) }
    end
  end

  def save_to_json
    File.write("events.json", JSON.pretty_generate(@events))
    puts "Збережено у файл events.json"
  end

  def load_from_json
  if File.exist?("events.json")
    raw_data = JSON.parse(File.read("events.json"))
    @events = raw_data.transform_keys(&:to_i).transform_values do |event|
      {
        id: event["id"],
        name: event["name"],
        date: event["date"],
        participants: event["participants"] || [],
        locations: event["locations"] || []
      }
    end
    @next_id = @events.keys.max.to_i + 1
    puts "Завантажено з events.json"
  else
    puts "Файл не знайдено."
  end
end


  def save_to_yaml
    File.write("events.yaml", YAML.dump(@events))
    puts "Збережено у файл events.yaml"
  end

  def load_from_yaml
  if File.exist?("events.yaml")
    raw_data = YAML.load_file("events.yaml")
    @events = raw_data.transform_keys { |k| k.to_i }
    @next_id = @events.keys.max.to_i + 1
    puts "Завантажено з events.yaml"
  else
    puts "Файл не знайдено."
  end
end


  def print_event(e)
  puts "\nID: #{e[:id]}"
  puts "Назва: #{e[:name]}"
  puts "Дата: #{e[:date]}"
  puts "Учасники: #{Array(e[:participants]).join(', ')}"
  puts "Місця: #{Array(e[:locations]).join(', ')}"
  puts "-" * 30
end

end

# Запуск
organizer = EventOrganizer.new
organizer.run

