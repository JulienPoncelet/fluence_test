require "test_helper"

class ImportFromOldAppJobTest < ActiveJob::TestCase
  setup do
    @building     = Building.find_by(reference: 1)
    @folder_path  = Rails.root.join('test','fixtures', 'files')
  end

  test "basic" do
    ImportFromOldAppJob.new.perform(@folder_path.join('imports_ok'))
    @building.reload

    building_2 = Building.find_by(reference: 2)

    assert_equal(@building.address, '10 Rue La bruyère')
    assert_equal(@building.zip_code, '75009')
    assert_equal(@building.city, 'Paris')
    assert_equal(@building.country, 'France')
    assert_equal(@building.manager_name, 'Martin Faure')

    assert_equal(building_2.address, '40 Rue René Clair')
    assert_equal(building_2.zip_code, '75018')
    assert_equal(building_2.city, 'Paris')
    assert_equal(building_2.country, 'France')
    assert_equal(building_2.manager_name, 'Martin Faure')

    @building.update_columns(address: '12 Rue La bruyère')
    building_2.update_columns(manager_name: 'John Doe')

    ImportFromOldAppJob.new.perform(@folder_path.join('imports_ok'))

    @building.reload
    building_2.reload

    assert_equal(@building.address, '10 Rue La bruyère')
    assert_equal(building_2.manager_name, 'John Doe')
  end

  test "Unknown Model" do
    @building = Building.find_by(reference: 1)

    error = assert_raises do
      ImportFromOldAppJob.new.import(@folder_path.join('imports_ko', 'unknown_models.csv'))
    end

    assert_equal 'Unknown model', error.message
  end

  test "Missing reference header" do
    @building = Building.find_by(reference: 1)

    error = assert_raises do
      ImportFromOldAppJob.new.import(@folder_path.join('imports_ko', 'buildings.csv'))
    end

    assert_equal 'Missing reference header', error.message
  end

  test "Unknown attributes" do
    @building = Building.find_by(reference: 1)

    error = assert_raises do
      ImportFromOldAppJob.new.import(@folder_path.join('imports_ko', 'people.csv'))
    end

    assert_equal 'Unknown attributes', error.message
  end
end
