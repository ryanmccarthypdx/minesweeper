class Board < Array
  attr_reader :size
  def initialize(size, default_value = nil)
    @size = size
    super(size) { Array.new(size, default_value) } # block sets default value dynamically
  end


end
