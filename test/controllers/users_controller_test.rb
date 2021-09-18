require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { area_id: @user.area_id, business_unite_id: @user.business_unite_id, city_id: @user.city_id, company_id: @user.company_id, country_id: @user.country_id, email: @user.email, encrypted_password: @user.encrypted_password, gender: @user.gender, group_id: @user.group_id, identity: @user.identity, last_name: @user.last_name, localization_id: @user.localization_id, name: @user.name, position_id: @user.position_id, since_date: @user.since_date, status: @user.status, username: @user.username }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: { area_id: @user.area_id, business_unite_id: @user.business_unite_id, city_id: @user.city_id, company_id: @user.company_id, country_id: @user.country_id, email: @user.email, encrypted_password: @user.encrypted_password, gender: @user.gender, group_id: @user.group_id, identity: @user.identity, last_name: @user.last_name, localization_id: @user.localization_id, name: @user.name, position_id: @user.position_id, since_date: @user.since_date, status: @user.status, username: @user.username }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
