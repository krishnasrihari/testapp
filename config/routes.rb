Mycucumber::Application.routes.draw do
	match "index" => "home#index"	
	match "withdraw" => "home#withdraw", :as => "withdraw"
	root to: "welcome#index"
end
