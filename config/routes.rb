
  # releases
#  resources :projects do
#    resources :releases, :only => [:index, :new,:show, :edit, :destroy, :snapshot], :controller => :rb_releases  do
#      get 'snapshot', :on => :member
#      post 'edit', :on => :member
#      post 'new', :on => :member
#    end
#  end

match 'releases/:project_id', :to => 'rb_releases#index', :via => [:get]
match 'release/:project_id/new', :to => 'rb_releases#new', :via => [:get, :post]
match 'release/:release_id', :to => 'rb_releases#show', :via => [:get]
match 'release/:release_id', :to => 'rb_releases#destroy', :via => [:delete]
match 'release/:release_id/edit', :to => 'rb_releases#edit', :via => [:get, :post]
match 'release/:release_id/update', :to => 'rb_releases#update', :via => [:put]
match 'release/:release_id/shapshot', :to => 'rb_releases#snapshot', :via => [:get]

match 'releases_multiview/:project_id/new', :to => 'rb_releases_multiview#new', :via => [:get, :post]
match 'releases_multiview/:release_multiview_id', :to => 'rb_releases_multiview#show', :via => [:get]
match 'releases_multiview/:release_multiview_id', :to => 'rb_releases_multiview#destroy', :via => [:delete]
match 'releases_multiview/:release_multiview_id/edit', :to => 'rb_releases_multiview#edit', :via => [:get, :post]

match 'updated_items/:project_id', :to => 'rb_updated_items#show', :via => [:get]
match 'wikis/:sprint_id', :to => 'rb_wikis#show', :via => [:get]
match 'wikis/:sprint_id/edit', :to => 'rb_wikis#edit', :via => [:get]
match 'issues/backlog/product/:project_id', :to => 'rb_queries#show', :via => [:get]
match 'issues/backlog/sprint/:sprint_id', :to => 'rb_queries#show', :via => [:get]
match 'issues/impediments/sprint/:sprint_id', :to => 'rb_queries#impediments', :via => [:get]
match 'statistics', :to => 'rb_all_projects#statistics', :via => [:get]

match 'server_variables/sprint/:sprint_id.js', :to => 'rb_server_variables#sprint', :format => 'js', :via => [:get]
match 'server_variables/sprint/:sprint_id.js', :to => 'rb_server_variables#sprint', :format => nil, :via => [:get]
match 'server_variables.js', :to => 'rb_server_variables#index', :via => [:get]
# match 'server_variables.js', :to => 'rb_server_variables#index', :format => nil, :via => [:get]
match 'server_variables/project/:project_id.js', :to => 'rb_server_variables#project', :format => 'js', :via => [:get]
match 'server_variables/project/:project_id.js', :to => 'rb_server_variables#project', :format => nil, :via => [:get]

match 'master_backlog/:project_id', :to => 'rb_master_backlogs#show', :via => [:get]
match 'master_backlog/:project_id/menu', :to => 'rb_master_backlogs#menu', :via => [:get]
match 'master_backlog/:project_id/closed_sprints', :to => 'rb_master_backlogs#closed_sprints', :via => [:get]

match 'impediment/create', :to => 'rb_impediments#create', :via => [:get, :post]
match 'impediment/update/:id', :to => 'rb_impediments#update', :via => [:get, :put]

match 'sprint/create', :to => 'rb_sprints#create', :via => [:get, :post]
match 'sprint/:sprint_id/update', :to => 'rb_sprints#update', :via => [:get, :put]
match 'sprint/:sprint_id/close', :to => 'rb_sprints#close', :via => [:get, :put]
match 'sprint/:sprint_id/reset', :to => 'rb_sprints#reset', :via => [:get, :put]
match 'sprint/download/:sprint_id.xml', :to => 'rb_sprints#download', :format => 'xml', :via => [:get]
match 'sprints/:project_id/close_completed', :to => 'rb_sprints#close_completed', :via => [:put]

match 'stories/:project_id/:sprint_id.pdf', :to => 'rb_stories#index', :format => 'pdf', :via => [:get]
match 'stories/:project_id.pdf', :to => 'rb_stories#index', :format => 'pdf', :via => [:get]
match 'story/create', :to => 'rb_stories#create', :via => [:get, :post]
match 'story/update/:id', :to => 'rb_stories#update', :via => [:get, :put]
match 'story/:id/tooltip', :to => 'rb_stories#tooltip', :via => [:get]

match 'calendar/:key/:project_id.ics', :to => 'rb_calendars#ical', :format => 'xml', :via => [:get]

match 'burndown/:sprint_id',         :to => 'rb_burndown_charts#show', :via => [:get]
match 'burndown/:sprint_id/embed',   :to => 'rb_burndown_charts#embedded', :via => [:get]
match 'burndown/:sprint_id/print',   :to => 'rb_burndown_charts#print', :via => [:get]

match 'hooks/sidebar/project/:project_id', :to => 'rb_hooks_render#view_issues_sidebar', :via => [:get]
match 'hooks/sidebar/project/:project_id/:sprint_id', :to => 'rb_hooks_render#view_issues_sidebar', :via => [:get]

match 'project/:project_id/backlogs', :to => 'rb_project_settings#project_settings', :via => [:get]

resources :task, :except => :index, :controller => :rb_tasks
match 'tasks/:story_id', :to => 'rb_tasks#index', :via => [:get]

match 'taskboards/:sprint_id', :to => 'rb_taskboards#show', :via => [:get]
match 'projects/:project_id/taskboard', :to => 'rb_taskboards#current', :via => [:get]
