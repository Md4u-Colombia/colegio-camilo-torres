Rails.application.routes.draw do

  scope "(:locale)", locale: /es|en/ do
    root 'home#index'

    #devise_for :users
    devise_for :users, :controllers => {:sessions => "devise/sessions"}
    resources :average_student_sub_grades
    post "users/import_data" => "users#import_data"
    post "educational_areas/new" => "educational_areas#new"
    post "educational_performances/new" => "educational_performances#new"
    post "educational_periods/new" => "educational_periods#new"
    post "sd_details/new" => "sd_details#new"
    post "sub_grades/new" => "sub_grades#new"
    post "sub_grade_teachers/new" => "sub_grade_teachers#new"
    post "student_sub_grades/new" => "student_sub_grades#new"
    post "educational_asignatures/new" => "educational_asignatures#new"
    post "grade_asignatures/new" => "grade_asignatures#new"
    post "teacher_asignatures/new" => "teacher_asignatures#new"


    devise_scope :user do
      get 'users/sign_out' => 'devise/sessions#destroy'
      get  'users/new' => 'users#new'
      post '/users/new'
      post 'users/create' => 'users#create'
      get  'users/change_password' => 'users#change_password'
      post 'users/change_password' => 'users#change_password'
      get 'users/automatic_avatar'
    end

    get "/students_grades/student_sub_grade"
    post "/students_grades/new"
    get "/students_grades/new"
    get "/students_grades/update_students"
    get "/students_grades/update_student_list"
    resources :students_grades

    resources :users
    resources :areas
    resources :business_units
    resources :cities
    resources :countries
    resources :companies
    resources :education_levels
    get "/eduper_score_details/update_percentage_performance"
    get 'eduper_score_details/update_asignatures' => 'eduper_score_details#update_asignatures'
    get 'eduper_score_details/update_field_form' => 'eduper_score_details#update_field_form'
    get 'eduper_score_details/update_score_detail' => 'eduper_score_details#update_score_detail'
    get 'eduper_score_details/delete_register' => 'eduper_score_details#delete_register'
    resources :eduper_score_details
    get 'export_pdf/final_value_record_pdf'
    get 'export_pdf/student_report_individual'
    post 'final_value_records/save_recovered', as: "fv_save_recovered_score"
    resources :final_value_records
    resources :groups
    resources :localizations
    resources :positions
    resources :position_levels
    resources :roles
    resources :educational_periods
    resources :performances
    resources :grades
    resources :grade_asignatures do
      collection do
        post "duplicate_grade_asignatures"
      end
    end
    resources :sub_grades
    resources :educational_areas
    get 'student_trackings/update_asignatures' => 'student_trackings#update_asignatures'
    get 'student_trackings/update_field_form' => 'student_trackings#update_field_form'
    get 'student_trackings/save_data' => 'student_trackings#save_data'
    get 'student_trackings/update_scores_finals' => 'student_trackings#update_scores_finals'
    get 'student_trackings/student_comment' => 'student_trackings#student_comment'
    post 'student_trackings/student_comment' => 'student_trackings#student_comment'
    get 'student_trackings/save_comment' => 'student_trackings#save_comment'
    post 'student_trackings/new'
    get 'student_trackings/score_tracking_report' => "student_trackings#score_tracking_report"
    post 'student_trackings/score_tracking_report' => "student_trackings#score_tracking_report"
    resources :student_trackings
    get 'educational_performances/update_educational_asignature' => 'educational_performances#update_educational_asignature'
    get 'educational_performances/update_performances_lists'
    resources :educational_performances
    get 'educational_performance_grades/update_educational_asignature'
    get 'educational_performance_grades/update_performances_lists'
    post 'educational_performance_grades/new'

    get 'educational_performance_grades/duplicate_educational_performance_grades'
    post 'educational_performance_grades/duplicate_educational_performance_grades'

    resources :educational_performance_grades
    post "educational_performances_lists/new" => "educational_performances_lists#new"
    get 'educational_performances_lists/update_educational_asignature' => 'educational_performances_lists#update_educational_asignature'
    resources :educational_performances_lists
    get 'student_progresses/save_data' => 'student_progresses#save_data'
    get "student_progresses/generate_pdf" => "student_progresses#generate_pdf"
    post 'student_progresses/new'
    resources :student_progresses
    resources :educational_asignatures
    get 'score_details/update_asignatures' => 'score_details#update_asignatures'
    get 'score_details/update_field_form' => 'score_details#update_field_form'
    get 'score_details/update_score_detail' => 'score_details#update_score_detail'
    get 'score_details/delete_register' => 'score_details#delete_register'
    resources :score_details
    resources :sd_details
    get 'student_sub_grades/add_score' => 'student_sub_grades#add_score'
    post 'student_sub_grades/add_score' => 'student_sub_grades#add_score'
    resources :student_sub_grades
    post '/school_years/new'
    resources :school_years
    resources :sub_grade_teachers
    get 'period_notes_details/create' => "period_notes_details#new"
    get 'period_notes_details/period_notes_details' => "period_notes_details#period_notes_details"
    get 'period_notes_details/:id/period_notes_details' => "period_notes_details#period_notes_details"
    resources :period_notes_details
    get 'teacher_asignatures/update_sub_grade' => 'teacher_asignatures#update_sub_grade'
    get 'teacher_asignatures/update_asignatures' => 'teacher_asignatures#update_asignatures'
    resources :teacher_asignatures
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
