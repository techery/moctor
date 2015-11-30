require_relative '../lib/moctor'

Moctor.define do
  validation :username do
    not_empty
    min_length(8)
    match_regex(/\A\w/)
  end

  interface :Loadable do
    prop :isLoading, :bool
    prop :error,     :Error
  end

  enum :LoadingState do
    opt :NotStarted, 1
    opt :Started,    2
  end

  type :User => :BaseModel do
    implements :Loadable

    prop :name,  :string, validate: username
    prop :email, :string, validate: [not_empty, min_length(8)]
  end

  type :Session => :BaseModel do
    prop :token, :string, validate: not_empty
  end

  actor :UserSessionActor do
    use :NetworkActor

    action :Login => :Session do
      prop :username, :string
      prop :password, :string
      prop :age,      :int
    end

    action :Logout do
      prop :session, :Session
    end
  end

  actor :NetworkActor do
    use :LoggingActor
  end

  actor :LoggingActor do
    action :Log do
      prop :message, :string
    end
  end

  type :Error do
    prop :message, :string
  end
end
