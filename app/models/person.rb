class Person < ApplicationRecord
	has_paper_trail

	# Constants

  PROTECTED_FIELDS = %w[email mobile_phone_number home_phone_number address]
end
