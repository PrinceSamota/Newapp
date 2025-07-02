require "test_helper"

class DispatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get dispatches_new_url
    assert_response :success
  end

  test "should get create" do
    get dispatches_create_url
    assert_response :success
  end

  test "should get index" do
    get dispatches_index_url
    assert_response :success
  end

  test "should get show" do
    get dispatches_show_url
    assert_response :success
  end
end
