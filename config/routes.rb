Rails.application.routes.draw do
	scope "(:locale)", :locale => /en|de/ do
		root  'pages#index'
		get   'favicon',          to: 'pages#favicon'
		match 'submit',           to: 'pages#submit', via: 'post'
		match 'faq',              to: 'pages#faq',    via: 'get'
		match 'donation_request', to: 'pages#donation_request', via: 'get'
		match 'results',          to: 'pages#results',          via: 'get'
		match 'info',             to: 'pages#info',             via: 'get'
	end
end
