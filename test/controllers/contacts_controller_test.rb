require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_contact_url
    assert_response :success
  end

  test "should get index" do
    get contacts_url
    assert_response :success
  end

  test "should get particulier" do
    get particulier_contacts_url
    assert_response :success
  end

  test "should get acp" do
    get acp_contacts_url
    assert_response :success
  end

  test "should get entreprise_immo" do
    get entreprise_immo_contacts_url
    assert_response :success
  end
end
