module Api
  class ExpensesController < Api::BaseController
    before_action :set_expense, only: [:show, :edit, :update, :destroy]
    before_action :is_authorized?
    rescue_from ActiveRecord::RecordNotFound, with: :invalid_expense

    def index
      @expenses = findByDateFromAndTo params[:datefrom], params[:dateto], :desc
    end

    def show
    end

    def edit
    end

    def create
      @expense = @current_user.expenses.build(expense_params)

      if @expense.save
        render status: :created
      else
        #@expense.errors.each { |key, value| puts key.to_s + ': ' + value.to_s }
        render json: @expense.errors, status: :unprocessable_entity
      end
    end

    def update
      if @expense.update(expense_params)
        render status: :no_content
      else
        render json: @expense.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @expense.destroy
      head :no_content
    end

    def weekly
      expenses = findByDateFromAndTo params[:datefrom], params[:dateto], :asc
      my_json = {}

      add_minutes =  - params[:timezone].to_i.minutes

      expenses.each do |expense|
        year, month, week = (expense.for_timeday + add_minutes).strftime('%Y'), (expense.for_timeday + add_minutes).strftime('%m'), (expense.for_timeday + add_minutes).strftime('%V')
        year = (year.to_i + 1).to_s if month.to_i == 12 && week.to_i == 1
        key = year + '.' + week

        analytics = my_json[key] || {}
        analytics[:expense] = analytics[:expense] || []
        analytics[:total] = expense.amount + (analytics[:total] || 0)
        analytics[:items] = 1 + (analytics[:items] || 0)
        analytics[:start] = Date.commercial(year.to_i, week.to_i, 1).to_s
        analytics[:end] = Date.commercial(year.to_i, week.to_i, 7).to_s

        my_expense = {for_timeday: expense.for_timeday, amount: expense.amount, description: expense.description, comment: expense.comment}
        analytics[:expense].push my_expense

        my_json[key] = analytics
      end

      #puts JSON.pretty_generate my_json.values

      render json: my_json.values
    end

    private

      def is_authorized?
        if @current_user.is_manager
          render json: { error: "Doesn't have permissions" }, status: :forbidden
          return
        end
      end

      def set_expense
        @expense = Expense.find(params[:id])
        if @expense.user != @current_user && @current_user.is_regular
          render json: { error: "Doesn't have permissions" }, status: :forbidden
          return
        end
      end

      def expense_params
        params.require(:expense).permit(:amount, :for_timeday, :description, :comment)
      end

      def invalid_expense
        @expense = nil
      end

      def findByDateFromAndTo(from, to, order)
        scope = @current_user.expenses if @current_user.is_regular
        scope = Expense.all if @current_user.is_admin
        scope = scope.greaterThanTime(Time.parse(from)) if from.present?
        scope = scope.lessThanTime(Time.parse(to)) if to.present?

        scope.includes(:user).order(for_timeday: order)
      end

  end
end