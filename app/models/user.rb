class User < ActiveRecord::Base

  has_secure_password

  validates :email, :password_digest, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  
  validates :password, length: { minimum: 5 }

  has_many :expenses
  
  belongs_to :role

  ROLES = {
    REGULAR: 1,
    ADMIN: 2,
    MANAGER: 3
  }

  def isRegular
    self.id_role == ROLES[:REGULAR]
  end

  def isAdmin
    self.id_role == ROLES[:ADMIN]
  end
  
  def isManager
    self.id_role == ROLES[:MANAGER]
  end

end
