class Account < ApplicationRecord
  enum :role, ['worker', 'bookkeeper', 'manager', 'admin'].index_by(&:itself), prefix: true, default: :worker
end
