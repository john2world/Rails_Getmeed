require 'test_helper'

class CrmResultsControllerTest < ActionController::TestCase
  setup do
    @crm_result = crm_results(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:crm_results)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create crm_result" do
    assert_difference('CrmResult.count') do
      post :create, crm_result: {  }
    end

    assert_redirected_to crm_result_path(assigns(:crm_result))
  end

  test "should show crm_result" do
    get :show, id: @crm_result
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @crm_result
    assert_response :success
  end

  test "should update crm_result" do
    put :update, id: @crm_result, crm_result: {  }
    assert_redirected_to crm_result_path(assigns(:crm_result))
  end

  test "should destroy crm_result" do
    assert_difference('CrmResult.count', -1) do
      delete :destroy, id: @crm_result
    end

    assert_redirected_to crm_results_path
  end
end
