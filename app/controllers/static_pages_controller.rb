class StaticPagesController < ApplicationController
    skip_before_action :require_login, only: %i[top explanation]
    def top; end

    def explanation; end
end
