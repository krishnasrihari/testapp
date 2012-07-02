Mycucumber::Application.routes.draw do
	match "index" => "home#index"	
	match "withdraw" => "home#withdraw", :as => "withdraw"
	resources :users do
		resources :messages
	end
	resource :search, :only => :show
	root to: "welcome#index"
end
