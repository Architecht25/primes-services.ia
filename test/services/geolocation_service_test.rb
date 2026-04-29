require "test_helper"

class GeolocationServiceTest < ActiveSupport::TestCase
  setup do
    @wallonie_contact = ParticulierContact.new(
      name: "Test", email: "t@t.com", region: "wallonie",
      postal_code: "4000", city: "Liège", address: "Rue de la Paix 1",
      status: "pending"
    )
    @bruxelles_contact = ParticulierContact.new(
      name: "Test", email: "t@t.com", region: "bruxelles",
      postal_code: "1000", city: "Bruxelles", address: "Rue Royale 1",
      status: "pending"
    )
    @flandre_contact = ParticulierContact.new(
      name: "Test", email: "t@t.com", region: "flandre",
      postal_code: "9000", city: "Gent", address: "Korenmarkt 1",
      status: "pending"
    )
  end

  # --- analyze_location ---

  test "analyze_location returns hash with region key" do
    result = GeolocationService.analyze_location(@wallonie_contact)
    assert_kind_of Hash, result
    assert_equal "wallonie", result[:region]
  end

  test "analyze_location returns empty hash when no address or postal code" do
    contact = ParticulierContact.new(region: "wallonie", status: "pending")
    result = GeolocationService.analyze_location(contact)
    assert_equal({}, result)
  end

  test "wallonie location includes correct authority" do
    result = GeolocationService.analyze_location(@wallonie_contact)
    assert_match(/SPW/i, result[:authority])
  end

  test "bruxelles location includes Bruxelles Environnement" do
    result = GeolocationService.analyze_location(@bruxelles_contact)
    assert_match(/Bruxelles/i, result[:authority])
  end

  test "flandre location includes VEA" do
    result = GeolocationService.analyze_location(@flandre_contact)
    assert_match(/VEA|Vlaams/i, result[:authority])
  end

  # --- get_local_specifics ---

  test "get_local_specifics returns array" do
    result = GeolocationService.get_local_specifics(@wallonie_contact)
    assert_kind_of Array, result
  end

  test "get_local_specifics returns unique values" do
    result = GeolocationService.get_local_specifics(@wallonie_contact)
    assert_equal result.uniq, result
  end

  test "get_local_specifics returns results for all regions" do
    [ @wallonie_contact, @bruxelles_contact, @flandre_contact ].each do |contact|
      result = GeolocationService.get_local_specifics(contact)
      assert_kind_of Array, result, "Expected array for region #{contact.region}"
    end
  end

  # --- get_local_authorities ---

  test "get_local_authorities returns hash with regional key" do
    result = GeolocationService.get_local_authorities(@wallonie_contact)
    assert_kind_of Hash, result
    assert result.key?(:regional)
  end
end
