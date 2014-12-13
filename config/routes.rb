MyFr2::Application.routes.draw do
  mount Stylin::Engine => '/styleguides' if Rails.env.development?

  with_options(:quiet => true) do |esi|
    esi.match 'special/user_utils' => 'special#user_utils'
    esi.match 'special/shared_assets' => 'special#shared_assets'
    esi.match 'special/my_fr_assets' => 'special#my_fr_assets'
    esi.match 'special/fr2_assets' => 'special#fr2_assets'
    esi.match 'special/navigation' => 'special#navigation'
  end

  match 'status' => 'special#status'

  #
  # Document
  #

  get 'documents/:year/:month/:day',
      to: "documents#index",
      as: :documents,
      constraints: {
        :year        => /\d{4}/,
        :month       => /\d{1,2}/,
        :day         => /\d{1,2}/
      }

  get 'documents/:year/:month/:day/:document_number/:slug',
      to: "documents#show",
      as: :document,
      constraints: {
        year: /\d{4}/,
        month: /\d{1,2}/,
        day: /\d{1,2}/,
        slug: /[^\/]+/
      }

  # don't break old urls
  get '/a/:document_number',
      to: "documents#tiny_url"

  get '/d/:document_number',
      to: "documents#tiny_url",
      as: :short_document

  get 'documents/search',
    to: 'documents/search#show',
    as: 'documents_search'

  get 'documents/search/header',
    to: 'documents/search#header',
    as: 'documents_search_header'

  get 'documents/search/facets/:facet',
    to: 'documents/search#facets',
    as: 'documents_search_facets'

  get 'documents/search/results',
    to: 'documents/search#results',
    as: 'documents_search_results'

  get 'documents/search/suggestions',
    to: 'documents/search#suggestions',
    as: 'documents_search_suggestions'

  get 'documents/search/help',
    to: 'documents/search#help',
    as: 'documents_search_help'

  get 'public-inspection/search',
    to: 'public_inspection/search#show',
    as: 'public_inspection_search'

  get 'public_inspection/search/header',
    to: 'public_inspection/search#header',
    as: 'public_inspection_search_header'

  get 'public_inspection/search/results',
    to: 'public_inspection/search#results',
    as: 'public_inspection_search_results'

  get 'events/search',
    to: 'events/search#show',
    as: 'events_search'

  get 'regulatory_plans/search',
    to: 'regulatory_plans/search#show',
    as: 'regulatory_plans_search'

  #
  # ESI Routes
  #
  with_options(:quiet => true) do |esi|
    esi.get 'special/header/:type',
      to: 'special#header',
      constraints: {
        type: /(official|public-inspection|reader-aids)/
      }

    esi.get 'special/site_notifications/:identifier',
      to: 'special#site_notifications',
      as: :site_notification

    esi.get 'esi/reader_aids',
      to: 'special#reader_aids',
      as: :home_reader_aids

    esi.get 'esi/reader_aids/blog_highlights',
      to: 'reader_aids#blog_highlights',
      as: :reader_aids_blog_highlights

    esi.get 'esi/reader_aids/using_fr',
      to: 'reader_aids#using_fr',
      as: :reader_aids_using_fr

    esi.get 'esi/reader_aids/understanding_fr',
      to: 'reader_aids#understanding_fr',
      as: :reader_aids_understanding_fr

    esi.get 'esi/reader_aids/recent_updates',
      to: 'reader_aids#recent_updates',
      as: :reader_aids_recent_updates

    esi.get 'esi/reader_aids/videos_and_tutorials',
      to: 'reader_aids#videos_and_tutorials',
      as: :reader_aids_videos_and_tutorials

    esi.get 'esi/reader_aids/developer_tools',
      to: 'reader_aids#developer_tools',
      as: :reader_aids_developer_tools

    esi.get 'esi/layouts/navigation/sections',
      to: 'sections#navigation',
      as: :navigation_sections

    esi.get 'esi/layouts/navigation/reader-aids',
      to: 'reader_aids#navigation',
      as: :navigation_reader_aids

    esi.get 'esi/layout/footer',
      to: 'special#footer',
      as: :footer
  end


  #
  # Public Inspection
  #
  get 'public-inspection',
      to: 'public_inspection_documents#public_inspection',
      as: :public_inspection

  get 'public-inspection/current',
      to: 'public_inspection_documents#current',
      as: :current_public_inspection_documents

  get 'public-inspection/:year/:month/:day',
      to: 'public_inspection_documents#index',
      as: :public_inspection_documents,
      constraints: {
        year: /\d{4}/,
        month: /\d{1,2}/,
        day: /\d{1,2}/
      }

  #
  # Reader Aids
  #
  get 'reader-aids',
      to: 'reader_aids#index',
      as: :reader_aids

  get 'reader-aids/search',
      to: 'reader_aids#search',
      as: :reader_aids_search

  get 'reader-aids/:section',
      to: 'reader_aids#view_all',
      as: :reader_aids_section

  get 'reader-aids/:section/:item',
      to: 'reader_aids#show',
      as: :reader_aid

  #
  # Home
  #
  root to: 'special#home'
  match 'special/user_utils' => 'special#user_utils'
  match 'special/shared_assets' => 'special#shared_assets'
  match 'special/my_fr_assets' => 'special#my_fr_assets'

  scope 'my' do
    devise_for :users, :controllers => { :passwords => "users/passwords",
                                         :confirmations => "users/confirmations",
                                         :sessions => "users/sessions",
                                         :registrations => "users/registrations" } do
      get 'sign_in', :to => 'users/sessions#new', :as => :new_session
      get 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_session
      get 'sign_up', :to => 'users/registrations#new', :as => :user_registration
      post 'sign_up', :to => 'users/registrations#create', :as => :user_registration
      get 'resend_confirmation', :to => 'users/confirmations#resend', :as => :resend_confirmation
    end

    root :to => "clippings#index",
         :as => :my_root

    resources :topics, only: [:index, :show]

    get 'topics/:id/significant.:format',
      :controller => "topics",
      :action => "significant_entries",
      :conditions => { :method => :get },
      as: 'significant_entries_topic'

    resources :agencies, only: [:index, :show]

    get 'agencies/:id/significant.:format',
      :controller => "agencies",
      :action => "significant_entries",
      :conditions => { :method => :get },
      as: 'significant_entries_agency'

    match '/executive-orders', to: 'executive_orders#index'

    match '/executive-orders/:president/:year',
      to: 'executive_orders#by_president_and_year',
      as: 'executive_orders_by_president_and_year'

    match '/:section', to: 'sections#show', as: :section

    get 'sections/:id/significant.:format',
      :controller => "agencies",
      :action => "significant_entries",
      :conditions => { :method => :get },
      as: 'significant_entries_section'

    resources :clippings do
      collection do
        post 'bulk_create'
      end
    end

    match 'folders/my-clippings' => 'clippings#index'
    resources :folders
    resources :folder_clippings do
      collection do
        post 'delete'
      end
    end

    resources :comments, :only => [:index] do
      collection do
        post :persist_for_login
      end
    end

    get 'articles/:document_number/comments/new' => 'comments#new',
     :as => :new_comment
    post 'articles/:document_number/comments/reload' => 'comments#reload',
     :as => :reload_comment
    post 'articles/:document_number/comments' => 'comments#create',
     :as => :comment

    resources :comment_attachments,
      :only => [:create, :destroy]

    resource :comment_publication_notifications,
      :only => [:create, :destroy]

    resource :comment_followup_document_notifications,
      :only => [:create, :destroy]

    resources :subscriptions do
      member do
        get :unsubscribe
        get :confirm
      end
      match 'articles/:document_number/comments/new' => 'comments#new',
       :as => :new_comment,
       :via => :get
      match 'articles/:document_number/comments/reload' => 'comments#reload',
       :as => :reload_comment,
       :via => :post
      match 'articles/:document_number/comments' => 'comments#create',
       :as => :comment,
       :via => :post

      resources :comment_attachments,
        :only => [:create, :destroy]

      resource :comment_publication_notifications,
        :only => [:create, :destroy]

      resource :comment_followup_document_notifications,
        :only => [:create, :destroy]

      resources :subscriptions do
        member do
          get :unsubscribe
          get :confirm
        end

        collection do
          get :confirmation_sent
          get :confirmed
          get :unsubscribed
        end
      end
    end
  end

  match "/404", :to => "errors#record_not_found"
  match "/405", :to => "errors#not_authorized"
  match "/500", :to => "errors#server_error"

  if Rails.env.development?
    mount FRMailer::Preview => 'fr_mail_view'
    mount SubscriptionMailer::Preview => 'subscription_mail_view'
    mount CommentMailer::Preview => 'comment_mail_view'
  end
end
