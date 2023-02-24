class Building < ApplicationRecord
  has_paper_trail

	# Constants

  PROTECTED_FIELDS = %w[manager_name]
end
