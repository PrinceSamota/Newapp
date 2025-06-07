require "test_helper"

class BomsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get boms_index_url
    assert_response :success
  end

  test "should get new" do
    get boms_new_url
    assert_response :success
  end

  test "should get create" do
    get boms_create_url
    assert_response :success
  end
end
