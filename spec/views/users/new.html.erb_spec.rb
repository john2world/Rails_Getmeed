require 'spec_helper'

describe "users/create_question" do
  before(:each) do
    assign(:users, stub_model(User).as_new_record)
  end

  it "renders create_question user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", users_path, "post" do
    end
  end
end
