class StaticPagesController < ApplicationController
    skip_before_action :require_login
    def top; end

    def explanation; end

    def privacy; end

    def condition; end
end
