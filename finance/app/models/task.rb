class Task < ApplicationRecord
  enum :status, ['in_progress', 'completed'].index_by(&:itself), prefix: true, default: 'in_progress'
end
