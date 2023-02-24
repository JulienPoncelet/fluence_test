require 'csv'

class ImportFromOldAppJob < ApplicationJob
  queue_as :default

  def perform
    CSV.parse(File.read(Rails.root.join('public', 'buildings.csv')), headers: true).each do |row|
      if row['reference'].blank?
        # Handle no reference
      end

      building = Building.find_or_initialize_by(reference: row['reference'])
      (row.headers - ['reference']).each do |header|
        value = row[header]

        next if building.send(header) == value

        if (Building::PROTECTED_FIELDS.include? header)
          # has to be a proper way
          previous_version_with_value = PaperTrail::Version
            .where(item_type: 'Building')
            .where("object ILIKE ?", "%#{header}: #{value}%")
          next if previous_version_with_value.any?
        end

        building.send("#{header}=", value)
      end

      next if !building.changed?
      
      if !building.save
        # Handle errors
      end
    end
  end
end
