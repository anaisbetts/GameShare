class UsersController < Clearance::UsersController
 #before_filter :authenticate, :unless => [:new, :create]
 before_filter :can_only_edit_self, :only => [:edit, :update]

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /groups/1/edit
  def edit
    @user = User.find(params[:id])
  end
end
