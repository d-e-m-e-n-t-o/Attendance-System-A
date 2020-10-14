class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:show, :edit, :update, :index, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  
  def new
    @user = User.new
  end
  
  def show
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end
  
  def index
    @users = params[:search].present? ? 
    User.where('name LIKE ?', "%#{params[:search]}%").paginate(page: params[:page]) :
    User.paginate(page: params[:page])
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    # ↓ before_action_filter ↓
    
    def set_user
      @user = User.find(params[:id])
    end
    
    # ユーザーがログイン済みか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end
    
    # アクセスしたユーザーが現在ログイン中か確認。
    def correct_user
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者権限の有無を判断
    def admin_user
      redirect_to root_url unless current_user.admin?
    end
    
    # 上長権限の有無を判断
    def superior_user
      redirect_to root_url unless current_user.superior?
    end
end

