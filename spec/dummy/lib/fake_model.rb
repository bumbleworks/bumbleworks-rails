class FakeModel
  attr_reader :id

  def initialize(id)
    @id = id
    self.class.all << self
  end

  def to_param
    id
  end

  class << self
    def all
      FAKE_DATABASE[name] ||= []
    end

    def count
      all.count
    end

    def first_by_identifier(id)
      all.detect { |member| member.id == id.to_i }
    end
  end
end