require 'test_helper'

class TrackerControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "get stories" do
    assert true
  end
end
