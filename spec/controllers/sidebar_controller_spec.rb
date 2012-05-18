require 'spec_helper'

describe SidebarController do

  describe "GET 'all_tags'" do
    it "returns http success" do
      get 'all_tags'
      response.should be_success
    end
  end

end
