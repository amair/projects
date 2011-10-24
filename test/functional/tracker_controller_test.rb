require 'test_helper'

class TrackerControllerTest < ActionController::TestCase

    def setup
    require 'active_resource/http_mock'
    ##rest of your code below....
    end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "get stories" do
    assert true
  end
end
