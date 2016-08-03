class Hasher
  attr_reader :size, :hash

  def initialize(size)
    @size = size
    @hash = Hash.new.tap { |h| (0..size).each { |k| h[k] = nil} }
  end

  # Insert multiple items - pass an array as the arg.
  def insert(items)
    items.each do |item|
      insert_item(item)
    end
  end

  def item_present?(item)
    new_value = asciify(item)
    remainder = new_value % size

    if hash[remainder] && hash[remainder] == new_value
      puts "Found item at #{hash.key(remainder)}"
      true
    elsif hash[remainder] && hash[remainder] != new_value
      # What key did we expect it to be?
      key = hash.key(new_value)

      # Create an array of the values until the end.
      # Ideally we should loop around back to zero but this is a rudimentary implementation.
      # [nil, 101119114101101114103101103114101103101114, 72103102103, 100101119114101116101103101102115100118]
      part_to_search = hash.values.last(size - (key - 1))

      if part_to_search.include?(new_value)
        puts "Found item at #{key + part_to_search.index(new_value)}"
        true
      end
    else
      puts "Item not found"
      false
    end
  end

  def get_words
    words = []

    hash.each do |key, value|
      # Only run the process for slots of the hash that have a value.
      if value
        arr = value.to_s.reverse.scan(/.{1,3}/).reverse
        arr = arr.map { |code| code.reverse }
        words << build_word(arr)
      end
    end

    words
  end

  private

  def asciify(item)
    # Convert integer's to string and then use the chars ASCII code formatted to 3 digits.
    # 3 digits required for consistency in unhashing.
    item = item.to_s if item.is_a?(Integer)

    # Build string build up in chunks of 3 chars based on the ASCII code.
    tmp = ""
    item.chars.each do |char|
      tmp << (sprintf '%03i', char.ord)
    end

    # Convert to an integer to allow us to modulo against `size`
    # This has the potential to strip a zero (or 2) at the front of the string.
    # I.e. => "0970" to => 970
    tmp.to_i
  end

  # Using simple remainder method hash function
  def insert_item(item)
    new_value = asciify(item)

    remainder = new_value % size

    if hash[remainder]
      # Insert into next open slot if slot is taken.
      (remainder..size).each do |slot|
        if hash[slot] == nil
          hash[slot] = new_value
          break
        end
      end
    else
      # Go ahead and insert it.
      hash[remainder] = new_value
    end
  end

  # "123456789".scan(/.{1,3}/)
  # => ["123", "456", "789"]
  def build_word(arr)
    word = ""

    arr.each do |ascii_code|
      word << ascii_code.to_i.chr
    end
    word
  end
end