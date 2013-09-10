Auth::Application.routes.draw do

  put "/cleanup" => "cleanup#update"

  scope "/v1" do

    resources :services, except: [:new, :edit] do
      member do
        get  'resources'
        post 'resources' => 'services#resource_create'
      end
    end
 
    resources :resources, except: [:create, :new, :edit] do
      member do
        get  'rights'
        post 'rights' => 'resources#right_create'
      end
    end
    
    resources :rights, except: [:create, :new, :edit] do
      member do
        get 'groups'
        get 'roles'
        put    'connect'
        delete 'connect' => 'rights#disconnect'
      end
    end

    resources :roles, except: [:new, :edit] do
      member do
        get 'api_users'
        get 'groups'
        get 'rights'
        put    'connect'
        delete 'connect' => 'roles#disconnect'
      end
    end

    resources :groups, except: [:new, :edit] do
      member do
        get 'api_users'
        get 'roles'
        get 'rights'
        put    'connect'
        delete 'connect' => 'groups#disconnect'
      end
    end

    resources :api_users, except: [:new, :edit] do
      member do
        get 'authentications'
        get 'roles'
        get 'groups'
        put    'connect'
        delete 'connect' => 'api_users#disconnect'
      end
    end

    resources :authentications, except: [:index, :new, :edit, :update], constraints: {id: /.+/}
    
  end
end
