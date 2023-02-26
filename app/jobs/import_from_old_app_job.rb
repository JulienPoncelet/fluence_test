require 'csv'

class ImportFromOldAppJob < ApplicationJob
  queue_as :default

  def perform(folder_path = nil)
    folder_path ||= Rails.root.join('public', 'imports')

    Dir.glob(folder_path.join('*.csv')) do |filepath|
      import(filepath) rescue nil
    end
  end

  def import(filepath)
      begin
        target = File.basename(filepath, '.*').singularize.capitalize.constantize
      rescue NameError
        raise 'Unknown model'
      end

      CSV.parse(File.read(filepath), headers: true).each do |row|
        if row['reference'].blank?
          raise 'Missing reference header'
        end

        building = target.find_or_initialize_by(reference: row['reference'])
        (row.headers - ['reference']).each do |header|

          if !(building.attributes.keys - %w(id created_at updated_at)).include? header
            raise 'Unknown attributes'
          end

          value = row[header]
          next if building.send(header) == value

          if target.const_defined?(:PROTECTED_FIELDS) and (target::PROTECTED_FIELDS.include? header)
            # has to be a proper way
            previous_version_with_value = PaperTrail::Version
              .where(item_type: target.to_s)
              .where("object ILIKE ?", "%#{header}: #{value}%")
            return if previous_version_with_value.any?
          end

          building.send("#{header}=", value)
        end

        return if !building.changed?

        if !building.save
          # Handle errors
        end
      end    
  end
end
