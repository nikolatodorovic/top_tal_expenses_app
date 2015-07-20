puts "creating roles"

role = Role.new
role.name = "regular"
role.save!

role = Role.new
role.name = "admin"
role.save!

role = Role.new
role.name = "manager"
role.save!

#---------------------------------------------------------

puts "creating user Sima Simic with regular role"

user = User.new
user.first_name = 'Sima'
user.last_name = 'Simic'
user.email = 'sima@simic.com'
user.password = 'simasimic'
user.id_role = 1
user.save!


puts "creating 18 expenses for user Sima Simic"

expense = Expense.new
expense.user = user
expense.amount = 713.54
expense.for_timeday = '2015-04-28 11:35'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 18.09
expense.for_timeday = '2015-06-30 17:45'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 22
expense.for_timeday = '2015-07-01 23:05'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 5
expense.for_timeday = '2014-12-30 20:05'
expense.description = 'Some unimportant description'
expense.comment = 'Some comment'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 123.99
expense.for_timeday = '2015-07-07 15:00'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 22.89
expense.for_timeday = '2015-01-01 6:45'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 221
expense.for_timeday = '2015-02-03 3:15'
expense.description = 'Some unimportant description'
expense.comment = 'Some comment'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 43
expense.for_timeday = '2015-03-11 13:45'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 23.76
expense.for_timeday = '2015-05-31 18:05'
expense.description = 'Some unimportant description'
expense.comment = 'Some comment'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 12.8
expense.for_timeday = '2015-03-31 22:05'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 10.14
expense.for_timeday = '2015-02-20 11:05'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 17
expense.for_timeday = '2015-01-07 12:05'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 52.9
expense.for_timeday = '2015-02-17 23:55'
expense.description = 'Some unimportant description'
expense.comment = 'Some comment'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 69
expense.for_timeday = '2015-01-27 22:25'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 83.62
expense.for_timeday = '2014-12-01 9:55'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 22
expense.for_timeday = '2015-07-02 03:45'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 22
expense.for_timeday = '2015-07-03 23:55'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 22
expense.for_timeday = '2015-07-04 12:30'
expense.description = 'Some unimportant description'
expense.comment = 'Some comment'
expense.save!

#---------------------------------------------------------

puts "creating user Pera Peric with admin role"

user = User.new
user.first_name = 'Pera'
user.last_name = 'Peric'
user.email = 'pera@peric.com'
user.password = 'peraperic'
user.id_role = 2
user.save!


puts "creating 2 expenses for user Pera Peric"

expense = Expense.new
expense.user = user
expense.amount = 150.35
expense.for_timeday = '2015-06-01 20:30'
expense.description = 'Some unimportant description'
expense.save!

expense = Expense.new
expense.user = user
expense.amount = 5.4
expense.for_timeday = '2015-05-30 10:00'
expense.description = 'Some unimportant description'
expense.save!

#---------------------------------------------------------

puts "creating user Mika Mikic with manager role"

user = User.new
user.first_name = 'Mika'
user.last_name = 'Mikic'
user.email = 'mika@mikic.com'
user.password = 'mikamikic'
user.id_role = 3
user.save!

#---------------------------------------------------------

