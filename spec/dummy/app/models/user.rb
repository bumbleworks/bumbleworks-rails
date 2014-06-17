class User
  include Bumbleworks::User

  attr_reader :username

  def initialize(username, roles = [])
    @username = username
    @roles = roles
  end

  def role_identifiers
    @roles
  end
end