class MicropostsController < ApplicationController
  before_action :login_required, only: %i[create destroy]
  before_action :correct_user, only: %i[destroy]

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = t 'micropost.create_successful'
      redirect_to root_url
    else
      @pagy, @feed_items = pagy(current_user.feed, request_path: root_path)
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = t 'micropost.delete_successful'
    if request.referrer.nil?
      redirect_to root_url, status: :see_other
    else
      redirect_to request.referrer, status: :see_other
    end
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url, status: :see_other if @micropost.nil?
    end

end
