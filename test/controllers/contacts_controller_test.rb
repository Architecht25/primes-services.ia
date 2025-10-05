require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get contacts_new_url
    assert_response :success
  end

  test "should get create" do
    get contacts_create_url
    assert_response :success
  end

  test "should get show" do
    get contacts_show_url
    assert_response :success
  end

  test "should get index" do
    get contacts_index_url
    assert_response :success
  end

  test "should get particulier" do
    get contacts_particulier_url
    assert_response :success
  end

  test "should get acp" do
    get contacts_acp_url
    assert_response :success
  end

  test "should get entreprise_immo" do
    get contacts_entreprise_immo_url
    assert_response :success
  end

  test "should get entreprise_comm" do
    get contacts_entreprise_comm_url
    assert_response :success
  end
end
